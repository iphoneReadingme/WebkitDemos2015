//
//  main.m
//  WebkitDemos
//
//  Created by yangfs on 15/4/20.
//  Copyright (c) 2015年 yangfs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
	@autoreleasepool {
		NSLog(@"【===NSHomeDirectory()===】\n%@", NSHomeDirectory());
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	}
}
