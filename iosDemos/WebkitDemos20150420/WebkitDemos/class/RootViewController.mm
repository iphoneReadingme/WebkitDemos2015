//
//  RootViewController.m
//  WebkitDemos
//
//  Created by yangfs on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

//#import "UITestView.h"
#import "DemoIncludeHeaders.h"

//#import "FullScreenController.h"
#import "RootViewController.h"
//#import "MainFrameView.h"
////#import "NSObject_Event.h"
//#import "UIGlobal.h"


//UIView * g_rootView = nil;
//UIView * g_mainView = nil;
//UIView * g_webBackgroundView = nil;
//
//extern UIView * g_rootView;
//extern UIView * g_mainView;
//extern UIView * g_webBackgroundView;

@interface UCTableViewCell : UITableViewCell

@end

@implementation UCTableViewCell

- (void)setBackgroundView:(UIView *)backgroundView
{
	
}

@end

@interface UIViewController (Private)
+ (NSString *)displayName;
@end

@implementation RootViewController


#pragma mark -
#pragma mark View lifecycle
- (void)setViewColor:(UIView*)pView
{
	//pView.backgroundColor = [UIColor clearColor];
	
	// for test
//	pView.backgroundColor = [UIColor blueColor];
	pView.layer.borderWidth = 2;
	pView.layer.borderColor = [UIColor colorWithRed:1.0 green:0 blue:0.0 alpha:1.0].CGColor;
}

//=====================================================================
#pragma mark -
#pragma mark Table view data source

- (NSArray *)valuesForSection:(NSUInteger)section {
	NSDictionary *dictionary = [items objectAtIndex:section];
	NSString *key = [[dictionary allKeys] objectAtIndex:0];
	return [dictionary objectForKey:key];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[[items objectAtIndex:section] allKeys] objectAtIndex:0];	
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self valuesForSection:section] count];
}

- (void)setCellColor:(UITableViewCell*)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIColor* color = nil;
	
	NSUInteger nRow = [indexPath row];
	if (nRow %2==0)
	{
		color = [UIColor redColor];
	}
	else
	{
		color = [UIColor blueColor];
	}
	
	cell.backgroundColor = color;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
		CGRect rect = CGRectMake(10, 10, 320-20, 20);
		UIImageView* pView = [[UIImageView alloc] initWithFrame:rect];
		pView.backgroundColor = [UIColor redColor];

//		[self setCellColor:cell cellForRowAtIndexPath:indexPath];
    }
    
	
	NSArray *values = [self valuesForSection:indexPath.section];
	cell.textLabel.text = [[values objectAtIndex:indexPath.row] displayName];
	//cell.textLabel.backgroundColor = [UIColor redColor];
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	NSArray *values = [self valuesForSection:indexPath.section];
	Class clazz = [values objectAtIndex:indexPath.row];
	id controller = [[[clazz alloc] init] autorelease];
	[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    //CARelease(items);
    [super dealloc];
}

//=====================================================================
#pragma mark -
#pragma mark 实现

- (void)hiddenNavigationBar
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)showNavigationBar
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)popViewController
{
	// 弹出上一层的 controller, 功能就是返回
	[self.navigationController popViewControllerAnimated:YES];
}

- (UIView*)getRootView
{
	return nil;
//	g_rootView = nil;
//	UIView* pSuperView = [[[self navigationController] navigationBar] superview];
//	for (UIView* subView in [pSuperView subviews])
//	{
//		Class cl = [subView class];
//		NSString *desc = [cl description];
//		//NSLog(@"class name[%s] description[%@]", object_getClassName(subView), desc);
//		if ([desc compare:@"UINavigationTransitionView"] == NSOrderedSame)
//		{
//			g_rootView = subView;
//			break;
//		}
//	}
//	return g_rootView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.clipsToBounds = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	
	items = [[NSMutableArray alloc] init];
	
	//=====================================================================
	// 2012-02-06
	// 添加Flash播放功能
//	NSMutableArray *flashList = [NSMutableArray array];
//	[flashList addObject:[iUCFlashViewController class]];
	//[flashList addObject:[WebViewController class]];
	
//	NSDictionary *flashDic = [NSDictionary dictionaryWithObject:flashList forKey:@"Flash播放"];
//	[items addObject:flashDic];
	
	NSMutableArray *webkitList = [NSMutableArray array];
	
	///< 2015-04-23 正则表达式 demo
	[webkitList addObject:[DemoRegularExpController class]];
	
	///< 2015-03-23 消息通知 demo
	[webkitList addObject:[DemoMessageCenterController class]];
	

	///< 2015-03-18 设备摇一摇功能
	[webkitList addObject:[DemoShakeController class]];
	
	///< 2015-03-11 读写电话号码 demo
	[webkitList addObject:[DemoIphoneNumberController class]];
		///< 2015-01-13 关键帧动画测试demo
	[webkitList addObject:[DemoViewCAKeyAnimationController class]];
	
	///< 文字排版绘制
	[webkitList addObject:[DemoCoreTextDrawController class]];
	
#ifdef Disenbale_Add_Controller
	
//	[webkitList addObject:[WebViewController class]];
	[webkitList addObject:[AnimationViewController class]];
//	[webkitList addObject:[MapKitViewController class]];
	[webkitList addObject:[DemoViewCALayerController class]];
//	[webkitList addObject:[DemoUIPageViewController class]];
	[webkitList addObject:[PageAppViewController class]];
//	[webkitList addObject:[DemoUIDeviceVIewController class]];
	
#endif
	
	NSDictionary *webkitDic = [NSDictionary dictionaryWithObject:webkitList forKey:@"WebkitDemo20120418"];
	[items addObject:webkitDic];
	//=====================================================================
//	createGlobalEventConnection( @selector(popViewController), self, @selector(popViewController));
//	createGlobalEventConnection( @selector(hiddenNavigationBar), self, @selector(hiddenNavigationBar));
//	createGlobalEventConnection( @selector(showNavigationBar), self, @selector(showNavigationBar));
	
	//BOOL bwantsFullScreenLayout = self.wantsFullScreenLayout;
	//NSLog(@"bwantsFullScreenLayout=%d", bwantsFullScreenLayout);
	
	self.title = @"返回";
	
	[self setViewColor:self.view];
	CGRect rect = [self.view frame];
	rect = CGRectInset(rect, 20, 20);
	[self.view setFrame:rect];
//	[self.view addTitleView:@"[root view]"];
	
	self.navigationController.delegate = self;
//	UIView* pSuperView = [[[self navigationController] navigationBar] superview];
//	[pSuperView addTitleView:@"navigationBar superview"];
	
	[self getRootView];
//	[[MainFrameView shareInstance] showMainFrame:pSuperView];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
	NSLog(@"parent=%@", parent);
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
	BOOL bwantsFullScreenLayout = self.wantsFullScreenLayout;
	NSLog(@"parent=%@", parent);
	NSLog(@"bwantsFullScreenLayout=%d", bwantsFullScreenLayout);
}

// =================================================================
#pragma mark -
#pragma mark UIViewController delegate methods

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidAppear:(BOOL)animated
{
	//[self addSubViewObject];
	CGRect rect = [self.view frame];
	rect = CGRectInset(rect, 20, 20);
//	[self.view setFrame:rect];
	
	rect = [[self.navigationController navigationBar] frame];
	rect.origin.y += 10;
//	[[self.navigationController navigationBar] setFrame:rect];
	
	//[[MainFrameView shareInstance] showMainFrame:[self getRootView]];
}

- (void)viewWillDisappear:(BOOL)animated
{
	//[m_pSubView removeFromSuperview];
	//[self releaseObject];
}

- (void)viewDidDisappear:(BOOL)animated
{
	
}

- (void)viewWillLayoutSubviews
{
	
}

// =================================================================
#pragma mark -
#pragma mark 屏幕旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// TODO:xxx
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
#pragma mark-
#pragma mark UINavigationControllerDelegate
// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	;
}

#pragma mark - == UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	NSLog(@"===scrollViewDidScroll===");
}

@end

