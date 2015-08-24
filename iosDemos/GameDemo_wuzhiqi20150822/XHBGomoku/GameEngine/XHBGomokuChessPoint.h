//
//  XHBGomokuChessPoint.h
//  XHBGomoku
//
//  Created by weqia on 14-9-1.
//  Copyright (c) 2014年 xhb. All rights reserved.
//

// 棋盘的某个棋子落子点

#import <Foundation/Foundation.h>
#import "XHBGomokuChessElement.h"

@class XHBGomokuChessPoint;

@protocol XHBGomokuChessPointProtocol <NSObject>

-(void)chessPointStatuChanged:(XHBGomokuChessPoint*)point;

@end

@interface XHBGomokuChessPoint : NSObject

@property(nonatomic,strong)XHBGomokuChessElement * chess; ///< 该位置上棋子对象
@property(nonatomic)XHBGomokuChessType  virtualChessType;  // 该位子上的虚拟棋子类型 （仅当chess 为空时有效）
@property(nonatomic,readonly)NSInteger row;   ///< 棋盘上的横线编号[1，15]
@property(nonatomic,readonly)NSInteger line;  ///< 棋盘上的列线编号[1，15]
@property(nonatomic)BOOL couldEnum;
@property(nonatomic,strong)id<XHBGomokuChessPointProtocol>delegate;
+(instancetype)pointAtRow:(NSInteger)row line:(NSInteger)row;

-(void)statuChanged;

@end
