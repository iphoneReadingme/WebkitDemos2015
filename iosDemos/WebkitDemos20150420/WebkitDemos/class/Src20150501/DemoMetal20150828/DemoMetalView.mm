

#import "DemoMetalView.h"

//#if !TARGET_IPHONE_SIMULATOR && __IPHONE_9_0
//#define Enable_Metal_CAMetalLayer
//#endif

#if Enable_Metal_CAMetalLayer
#import <simd/simd.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>

//@import Metal;
//@import simd;
//@import QuartzCore.CAMetalLayer;


static matrix_float4x4 rotation_matrix_2d(float radians)
{
	float cos = cosf(radians);
	float sin = sinf(radians);
	
	matrix_float4x4 m = {
		.columns[0] = {  cos, sin, 0, 0 },
		.columns[1] = { -sin, cos, 0, 0 },
		.columns[2] = {    0,   0, 1, 0 },
		.columns[3] = {    0,   0, 0, 1 }
	};
	return m;
}

static float quadVertexData[] =
{
	0.5, -0.5, 0.0, 1.0,     1.0, 0.0, 0.0, 1.0,
	-0.5, -0.5, 0.0, 1.0,     0.0, 1.0, 0.0, 1.0,
	-0.5,  0.5, 0.0, 1.0,     0.0, 0.0, 1.0, 1.0,
	
	0.5,  0.5, 0.0, 1.0,     1.0, 1.0, 0.0, 1.0,
	0.5, -0.5, 0.0, 1.0,     1.0, 0.0, 0.0, 1.0,
	-0.5,  0.5, 0.0, 1.0,     0.0, 0.0, 1.0, 1.0,
};

typedef struct
{
	matrix_float4x4 rotation_matrix;
} Uniforms;


///< DemoMetalView
#pragma mark - == DemoMetalView

@interface DemoMetalView()

// Long-lived Metal objects
@property (nonatomic, retain) CAMetalLayer *metalLayer;
@property (nonatomic, retain) id<MTLDevice> device;
@property (nonatomic, retain) id<MTLCommandQueue> commandQueue;
@property (nonatomic, retain) id<MTLLibrary> defaultLibrary;
@property (nonatomic, retain) id<MTLRenderPipelineState> pipelineState;

// Resources
@property (nonatomic, retain) id<MTLBuffer> uniformBuffer;
@property (nonatomic, retain) id<MTLBuffer> vertexBuffer;

// Transient objects
@property (nonatomic, retain) id<CAMetalDrawable> currentDrawable;

@property (nonatomic, retain) CADisplayLink *timer;

@property (nonatomic, assign) BOOL layerSizeDidUpdate;
@property (nonatomic, assign) Uniforms uniforms;
@property (nonatomic, assign) float rotationAngle;

@end

#endif  ///< #if Enable_Metal_CAMetalLayer

///< DemoMetalView
@implementation DemoMetalView

-(void)dealloc
{
	[self releaseImageViews];
	
#if Enable_Metal_CAMetalLayer
	[_timer invalidate];
#endif
	
	[super dealloc];
}

- (instancetype)initWithFrame:(CGRect)rect
{
	self = [super initWithFrame:rect];
	if (self)
	{
		self.accessibilityLabel = @"DemoMetalView";
		
		[self addsubViews];
		
		[self didThemeChange];
		[self onChangeFrame];
	}
	
	return self;
}

- (void)releaseImageViews
{
	
}

- (void)addsubViews
{
	
	//[self addButtonViews];
	
}

#pragma mark - ==按钮相关

- (void)addButtonViews
{
	UIButton* pButton = nil;
	
	CGRect btnRect = [self bounds];
	NSInteger nIndex = 0;
	
	///< ""
	pButton = [self createButton:nIndex withName:@"UC.NoImageEdu.startButton"];
	[pButton setFrame:btnRect];
	[pButton setTitle:@"开始" forState:UIControlStateNormal];
	//self.startButton = pButton;
	//[self addSubview:pButton];
	
	nIndex = 1;
	pButton = [self createButton:nIndex withName:@"UC.NoImageEdu.stopButton"];
	[pButton setFrame:btnRect];
	[pButton setTitle:@"停止" forState:UIControlStateNormal];
	//self.stopButton = pButton;
	//[self addSubview:pButton];
}

- (UIButton*)createButton:(NSInteger)nTag withName:(NSString*)pStrName
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button addTarget:self action:@selector(onButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
	button.tag = nTag;
	button.accessibilityLabel = pStrName;
	button.backgroundColor = [UIColor clearColor];
	
	return button;
}

- (void)onButtonClickEvent:(UIButton*)sender
{
	NSInteger nTag = sender.tag;
	if (nTag == 0)
	{
	}
	else if (nTag == 1)
	{
	}
}

- (void)didThemeChange
{
	self.backgroundColor = [UIColor lightGrayColor];
	
	//[_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	//[_stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
}

#define kImageViewWidth                       160
#define kImageViewTop                         50

- (void)onChangeFrame
{
	CGRect rect = CGRectMake(100, kImageViewTop, kImageViewWidth, 80);
	
	rect.size.height = 44;
	rect.size.width = 60;
	rect.origin.x = 100;
	rect.origin.y = 44;
	//[_startButton setFrame:rect];
	
	rect.origin.x += rect.size.width + 40;
	//[_stopButton setFrame:rect];
}

#if Enable_Metal_CAMetalLayer
#pragma mark - == metal 相关代码
- (void)didMoveToSuperview
{
	[self loadMetalDemo];
}

- (void)loadMetalDemo
{
	// Create the default Metal device, 使用MTLCreateSystemDefaultDevice 函数来获取默认设备: 注意 device 并不是一个详细具体的类，正如前面提到的，它是遵循 MTLDevice 协议的类。
	self.device = MTLCreateSystemDefaultDevice();
	if (!_device)
	{
		return;
	}
	
	[self setupMetal];
	[self buildPipeline];
	
	[self performSelectorOnMainThread:@selector(startCADisplayLink) withObject:nil waitUntilDone:NO];
}

- (void)startCADisplayLink
{
	// Set up the render loop to redraw in sync with the main screen refresh rate
	self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(redraw)];
	[self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)setupMetal
{
	///< 下面的代码展示了如何创建一个 Metal layer 并将它作为 sublayer 添加到一个 UIView 的 layer:
	/*
	 CAMetalLayer 是 CALayer 的子类，它可以展示 Metal 帧缓冲区的内容。我们必须告诉 layer 该使用哪个 Metal 设备 (我们刚创建的那个)，并通知它所预期的像素格式。我们选择 8-bit-per-channel BGRA 格式，即每个像素由蓝，绿，红和透明组成，值从 0-255。
	 */
	// Create, configure, and add a Metal sublayer to the current layer
	self.metalLayer = [CAMetalLayer layer];
	self.metalLayer.device = self.device;
	self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
	self.metalLayer.frame = self.bounds;
	[self.layer addSublayer:self.metalLayer];
	
	// Create a long-lived command queue
	self.commandQueue = [self.device newCommandQueue];
	
	///< 一个 Metal 库是一组函数的集合。你的所有写在工程内的着色器函数都将被编译到默认库中，这个库可以通过设备获得:
	// Get the library that contains the functions compiled into our app bundle
	self.defaultLibrary = [self.device newDefaultLibrary];
	
	self.contentScaleFactor = [UIScreen mainScreen].scale;
}

- (void)buildPipeline {
	// Generate a vertex buffer for holding the vertex data of the quad
	self.vertexBuffer = [self.device newBufferWithBytes:quadVertexData
												 length:sizeof(quadVertexData)
												options:MTLResourceOptionCPUCacheModeDefault];
	
	// Generate a buffer for holding the uniform rotation matrix
	self.uniformBuffer = [self.device newBufferWithLength:sizeof(Uniforms) options:MTLResourceOptionCPUCacheModeDefault];
	
	// Fetch the vertex and fragment functions from the library
	id<MTLFunction> vertexProgram = [self.defaultLibrary newFunctionWithName:@"vertex_function"];
	id<MTLFunction> fragmentProgram = [self.defaultLibrary newFunctionWithName:@"fragment_function"];
	
	// Build a render pipeline descriptor with the desired functions
	MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
	[pipelineStateDescriptor setVertexFunction:vertexProgram];
	[pipelineStateDescriptor setFragmentFunction:fragmentProgram];
	pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
	
	// Compile the render pipeline
	NSError* error = NULL;
	self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
	if (!self.pipelineState) {
		NSLog(@"Failed to created pipeline state, error %@", error);
	}
}

- (MTLRenderPassDescriptor *)renderPassDescriptorForTexture:(id<MTLTexture>) texture
{
	// Configure a render pass with properties applicable to its single color attachment (i.e., the framebuffer)
	MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
	renderPassDescriptor.colorAttachments[0].texture = texture;
	renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
	renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1);
	renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
	return renderPassDescriptor;
}

- (void)render {
	[self update];
	
	id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
	
	id<CAMetalDrawable> drawable = [self currentDrawable];
	
	// Set up a render pass to draw into the current drawable's texture
	MTLRenderPassDescriptor *renderPassDescriptor = [self renderPassDescriptorForTexture:drawable.texture];
	
	// Prepare a render command encoder with the current render pass
	id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
	
	// Configure and issue our draw call
	[renderEncoder setRenderPipelineState:self.pipelineState];
	[renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
	[renderEncoder setVertexBuffer:self.uniformBuffer offset:0 atIndex:1];
	[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
	
	[renderEncoder endEncoding];
	
	// Request that the current drawable be presented when rendering is done
	[commandBuffer presentDrawable:drawable];
	
	// Finalize the command buffer and commit it to its queue
	[commandBuffer commit];
}

- (void)update {
	// Generate a rotation matrix for the current rotation angle
	_uniforms.rotation_matrix = rotation_matrix_2d(self.rotationAngle);
	
	// Copy the rotation matrix into the uniform buffer for the next frame
	void *bufferPointer = [self.uniformBuffer contents];
	memcpy(bufferPointer, &_uniforms, sizeof(Uniforms));
	
	// Update the rotation angle
	_rotationAngle += 0.01;
}

- (void)redraw {
	//@autoreleasepool
	{
		if (self.layerSizeDidUpdate) {
			// Ensure that the drawable size of the Metal layer is equal to its dimensions in pixels
			CGFloat nativeScale = self.window.screen.nativeScale;
			CGSize drawableSize = self.metalLayer.bounds.size;
			drawableSize.width *= nativeScale;
			drawableSize.height *= nativeScale;
			self.metalLayer.drawableSize = drawableSize;
			
			self.layerSizeDidUpdate = NO;
		}
		
		// Draw the scene
		[self render];
		
		self.currentDrawable = nil;
	}
}

- (void)viewDidLayoutSubviews
{
	self.layerSizeDidUpdate = YES;
	
	// Re-center the Metal layer in its containing layer with a 1:1 aspect ratio
	CGSize parentSize = self.bounds.size;
	CGFloat minSize = MIN(parentSize.width, parentSize.height);
	CGRect frame = CGRectMake((parentSize.width - minSize) / 2,
							  (parentSize.height - minSize) / 2,
							  minSize,
							  minSize);
	[self.metalLayer setFrame:frame];
}

- (id <CAMetalDrawable>)currentDrawable
{
	// Our drawable may be nil if we're not on the screen or we've taken too long to render.
	// Block here until we can draw again.
	while (_currentDrawable == nil) {
		_currentDrawable = [self.metalLayer nextDrawable];
	}
	
	return _currentDrawable;
}
#else

- (void)viewDidLayoutSubviews
{
}

#endif ///< #if Enable_Metal_CAMetalLayer

@end
