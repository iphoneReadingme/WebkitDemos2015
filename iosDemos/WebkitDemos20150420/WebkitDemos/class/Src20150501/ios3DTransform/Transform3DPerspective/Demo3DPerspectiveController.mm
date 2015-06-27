

#import "Demo3DPerspectiveView.h"
#import "Demo3DPerspectiveController.h"
#import "DemoViewCoreTextDrawMacroDefine.h"


///< 私有方法
@interface Demo3DPerspectiveController()
{
	
}

@property (nonatomic, retain) Demo3DPerspectiveView * subDemoView;

- (void)releaseObject;
- (void)addSubViewObject;

@end

@implementation Demo3DPerspectiveController


+ (NSString *)displayName {
	return @"3D 透视投影变换矩阵";
}

- (void)dealloc
{
	[self releaseObject];
	
	[super dealloc];
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

// =================================================================
#pragma mark -
#pragma mark 子视图对象

- (CGRect)getViewRect
{
	CGRect frame = [self.view bounds];
	
	frame.origin.y += 44;
	frame.size.height -= frame.origin.y;
	
	return frame;
}

- (void)addSubViewObject
{
	CGRect frame = [self getViewRect];
	
	self.subDemoView = [[[Demo3DPerspectiveView alloc] initWithFrame:frame] autorelease];
	[self.view addSubview:_subDemoView];
}


@end

