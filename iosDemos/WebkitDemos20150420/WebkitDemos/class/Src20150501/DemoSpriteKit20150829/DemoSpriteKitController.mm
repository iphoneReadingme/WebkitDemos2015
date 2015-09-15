

#import "DemoSpriteKitView.h"
#import "DemoSpriteKitController.h"


///< 私有方法
@interface DemoSpriteKitController()
{
	
}

@property (nonatomic, retain) DemoSpriteKitView *subDemoView;

- (void)releaseObject;
- (void)addSubViewObject;

@end

@implementation DemoSpriteKitController


+ (NSString *)displayName {
	return @"20150829_SpriteKit Demo";
}

- (void)dealloc
{
	[self releaseObject];
	
	[self performSelector:@selector(dump)
			   withObject:nil
			   afterDelay:0.5];
	[super dealloc];
}

- (void)dump
{
	NSLog(@"hello");
}

- (void)releaseObject
{
	self.subDemoView = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self addSubViewObject];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_5_1  ///<ios6
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	// release and set to nil
}
#endif

#pragma mark -
#pragma mark UIViewController delegate methods

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_subDemoView removeFromSuperview];
	[self releaseObject];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

// 屏幕即将旋转 layoutSubviews执行之前发生
// Notifies when rotation begins, reaches halfway point and ends.
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	
}

// 屏幕即将旋转 layoutSubviews执行之后发生
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
}

// 屏幕旋转完毕
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//NSLog(@"g_rootView=%@", g_rootView);
	//emitEvent(nil, @selector(willAnimateRotationToInterfaceOrientation:duration:), fromInterfaceOrientation, 0);
}

// =================================================================
#pragma mark -
#pragma mark 子视图对象

- (CGRect)getViewRect
{
	CGRect frame = [self.view bounds];
	
	frame.origin.y += 64;
	frame.size.height -= frame.origin.y;
	
	return frame;
}

- (void)addSubViewObject
{
	CGRect frame = [self getViewRect];
	
	self.subDemoView = [[[DemoSpriteKitView alloc] initWithFrame:frame] autorelease];
	[self.view addSubview:_subDemoView];
}

- (void)viewDidLayoutSubviews
{
	;
}

@end

