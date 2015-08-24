//
//  XHBGomokuPieceView.m
//  XHBGomoku
//
//  Created by weqia on 14-9-1.
//  Copyright (c) 2014年 xhb. All rights reserved.
//

#import "XHBGomokuPieceView.h"


///< 棋子图片显示区域的大小
#define kPieceWidth        (22.0f)
#define kPieceHeight       (22.0f)


@interface XHBGomokuPieceView ()
@property(nonatomic,strong)UIImageView* backView;
@end

@implementation XHBGomokuPieceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
+(instancetype)piece:(XHBGomokuChessPoint*)point
{
    if (point.chess.type==XHBGomokuChessTypeEmpty) {
        return nil;
    }
	
	CGRect frame = CGRectMake(0, 0, kPieceWidth, kPieceHeight);
    XHBGomokuPieceView * piece=[[XHBGomokuPieceView alloc]initWithFrame:frame];
    piece.point=point;
    UIImageView * imageBackView=[[UIImageView alloc]initWithFrame:frame];
    [piece addSubview:imageBackView];
    piece.backView=imageBackView;
    
    UIImageView * view=[[UIImageView alloc]initWithFrame:frame];
    [piece addSubview:view];
    if (point.chess.type==XHBGomokuChessTypeBlack) {
        view.image=[UIImage imageNamed:@"stone_black"];
    }else{
        view.image=[UIImage imageNamed:@"stone_white"];
    }
    piece.center=[piece centerAt:point.row line:point.line];
    return piece;
}

-(CGPoint)centerAt:(NSInteger)row line:(NSInteger)line
{
    CGPoint point=CGPointMake(21*(line-1)+13, 21*(row-1)+13);
    return point;
}

-(void)setSelected:(BOOL)selected
{
    if (selected) {
        self.backView.image=[UIImage imageNamed:@"tips-hd"];
    }else{
        self.backView.image=nil;
    }
}


@end
