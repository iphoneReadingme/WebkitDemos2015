//
//  XHBGomokuBaseStack.h
//  XHBGomoku
//
//  Created by weqia on 14-9-1.
//  Copyright (c) 2014年 xhb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHBGomokuChessPoint.h"
@interface XHBGomokuBaseStack : NSObject

-(NSInteger)depth;

///< 入栈
-(void)push:(XHBGomokuChessPoint*)element;
///< 出栈
-(XHBGomokuChessPoint*)pop;

///< 悔棋
-(void)reuse;

-(XHBGomokuChessPoint*)getTopElement;

@end
