//
//  XHBGomokuGameSencesViewController.m
//  XHBGomoku
//
//  Created by weqia on 14-9-1.
//  Copyright (c) 2014年 xhb. All rights reserved.
//

#import "XHBGomokuGameSencesViewController.h"
#import "XHBGomokuPieceView.h"
#import "HBPlaySoundUtil.h"
#import "UIColor+setting.h"
#import "XHBGomokuOverViewController.h"

@interface XHBGomokuGameSencesViewController ()

@property(nonatomic,retain) UIView *chessBoardView;
@property(nonatomic,retain) UIImageView * boardImageView;

@property(nonatomic,weak)IBOutlet UIView * boardView;
@property(nonatomic,strong)XHBGomokuGameEngine * game;
@property(nonatomic,weak)IBOutlet UIButton * btnSound;
@property(nonatomic,weak)IBOutlet UIButton * btnUndo;
@property(nonatomic,weak)IBOutlet UIButton * btnRestart;
@property(nonatomic,weak)IBOutlet UILabel * blackChessMan;
@property(nonatomic,weak)IBOutlet UILabel * whiteChessMan;
@property(nonatomic,weak)IBOutlet UIView * topView;
@property(nonatomic)BOOL soundOpen;
@property(nonatomic,strong)NSMutableArray * pieces;
@property(nonatomic)NSInteger undoCount;
@property(nonatomic,strong)XHBGomokuPieceView * lastSelectPiece;
@end

@implementation XHBGomokuGameSencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.accessibilityLabel = @"GameSencesViewController_View";
	
    [UIApplication sharedApplication].statusBarHidden=YES;
    // Do any additional setup after loading the view.
    //UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    //[self boardView addGestureRecognizer:tap];
	[self addChessBoardBackImage];
	
    self.game=[XHBGomokuGameEngine game];
    self.game.delegate=self;
    self.game.playerFirst=YES;
	self.view.backgroundColor=[UIColor colorWithIntegerValue:BACKGROUND_COLOR alpha:1];
	self.view.backgroundColor=[UIColor blueColor];  ///<
	
    UIColor * color=[UIColor colorWithPatternImage:[UIImage imageNamed:@"topbarbg_2"]];
    self.topView.backgroundColor=color;
	self.topView.accessibilityLabel=@"topView";
	
    self.blackChessMan.textColor=color;
    self.whiteChessMan.textColor=color;
    
    NSNumber* number=[[NSUserDefaults standardUserDefaults] objectForKey:@"soundOpen"];
    if (number) {
        [self.btnSound setSelected:!number.boolValue];
    }
    _pieces=[NSMutableArray array];
    number=[[NSUserDefaults standardUserDefaults] objectForKey:@"playerFirst"];
    if (number) {
        self.game.playerFirst=number.boolValue;
    }
    if (!self.game.playerFirst) {
        self.blackChessMan.text=@"Computer";
        self.whiteChessMan.text=@"Player";
	}else{
		//  playerFirst => YES : 玩家先手（黑棋）  NO :玩家后手(白棋)
        self.blackChessMan.text=@"Player";
        self.whiteChessMan.text=@"Computer";
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.game begin];
    });
}

- (void)addChessBoardBackImage
{
	//self.boardView.alpha = 0.0f;
	self.boardView.accessibilityLabel = @"self.board_View";
	
	///< 棋盘视图对象
	CGRect frame = CGRectMake(0, 156, 320, 320);
	UIView* chessBoard = [[UIView alloc] initWithFrame:frame];
	chessBoard.accessibilityLabel = @"self.chessBoardView";
	[self.view addSubview:chessBoard];
	chessBoard.layer.borderColor = [UIColor redColor].CGColor;
	chessBoard.layer.borderWidth = 2;
	_chessBoardView = chessBoard;
	
	///< 棋盘背景图
	CGRect rect = CGRectMake(0, 0, 320 ,320);
	UIImageView* imgView = [[UIImageView alloc] initWithFrame:rect];
	imgView.accessibilityLabel = @"my_ChessBoardBackImageView";
	[_chessBoardView addSubview:imgView];
	imgView.image = [UIImage imageNamed:@"gomokuboard"];
	_boardImageView = imgView;
	//<UIView: 0x7c291270; frame = (0 156; 320 320); autoresize = RM+BM; gestureRecognizers = <NSArray: 0x7c081120>; layer = <CALayer: 0x7c291400>>
	//| <UIImageView: 0x7c291450; frame = (0 0; 320 320); autoresize = RM+BM; userInteractionEnabled = NO; layer = <CALayer: 0x7c291620>>
	
	///< 点击手势
	UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
	[_chessBoardView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)tapAction:(UITapGestureRecognizer*)tap
{
	///< 通过落点位置，确定行、列编号
	CGPoint point= CGPointZero;
	//point = [tap locationInView:self boardView];
	point=[tap locationInView:_chessBoardView];
    NSInteger tapRow=0;
    NSInteger tapLine=0;
    for (NSInteger row=1; row<=15; row++) {
        if (point.y>(21*(row-1)+3)&&point.y<(21*(row-1)+23))
		{
            tapRow=row;
            break;
        }
    }
    for (NSInteger line=1; line<=15; line++)
	{
        if (point.x>(21*(line-1)+3)&&point.x<(21*(line-1)+23)) {
            tapLine=line;
            break;
        }
    }
    [self.game playerChessDown:tapRow line:tapLine];
}


-(IBAction)btnChangePlayChess:(id)sender
{
    if (self.game.gameStatu!=XHBGameStatuComputerChessing) {
        if (self.game.playerFirst) {
            self.game.playerFirst=NO;
            self.blackChessMan.text=@"Computer";
            self.whiteChessMan.text=@"Player";
        }else{
            self.game.playerFirst=YES;
            self.blackChessMan.text=@"Player";
            self.whiteChessMan.text=@"Computer";
        }
        NSNumber * number=[NSNumber numberWithBool:self.game.playerFirst];
        [[NSUserDefaults standardUserDefaults] setObject:number forKey:@"playerFirst"];
        [self.game reStart];
    }
}

-(IBAction)btnBackAction:(id)sender
{
}

-(IBAction)btnSoundAction:(id)sender
{
    self.btnSound.selected=!self.btnSound.selected;
    self.soundOpen=!self.btnSound.selected;
    NSNumber * number=[NSNumber numberWithBool:!self.btnSound.selected];
    [[NSUserDefaults standardUserDefaults] setObject:number forKey:@"soundOpen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

///< 重新开始
-(IBAction)btnRestartAction:(id)sender
{
    [self.game reStart];
}

///< 悔棋
-(IBAction)btnUndoAction:(id)sender
{
    if ([self.game undo]) {
        self.undoCount++;
        if (self.undoCount>=3) {
            self.btnUndo.enabled=NO;
            [self.btnUndo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }else{
            self.btnUndo.enabled=YES;
            [self.btnUndo setTitleColor:[self.btnRestart titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        }
        [self.btnUndo setTitle:[NSString stringWithFormat:@"UNDO(%ld)",(long)(3-self.undoCount)] forState:UIControlStateNormal];
    };
}


-(void)game:(XHBGomokuGameEngine*)game updateSences:(XHBGomokuChessPoint*)point
{
    XHBGomokuPieceView * view=[XHBGomokuPieceView piece:point];
    //[self.boardView addSubview:view];
	[_chessBoardView addSubview:view];
	
    [_pieces addObject:view];
    
    [view setSelected:YES];
    [self.lastSelectPiece setSelected:NO];
    self.lastSelectPiece=view;
}

-(void)game:(XHBGomokuGameEngine*)game finish:(BOOL)success
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.lastSelectPiece setSelected:NO];
        self.lastSelectPiece=nil;
        for (XHBGomokuChessPoint * point in game.chessBoard.successPoints) {
            for (XHBGomokuPieceView * view in self.pieces) {
                if (view.point==point) {
                    [view setSelected:YES];
                }
            }
        }
        UIStoryboard * story=[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        XHBGomokuOverViewController * controller=[story instantiateViewControllerWithIdentifier:@"XHBGomokuOverViewController"];
        controller.success=success;
        controller.backImage=[self  screenshot:[UIApplication sharedApplication].keyWindow];
        [controller setCallback:^{
            [self.game reStart];
        }];
        [self presentViewController:controller animated:NO completion:nil];
    });
}

-(void)game:(XHBGomokuGameEngine*)game error:(XHBGameErrorType)errorType
{}

-(void)game:(XHBGomokuGameEngine*)game playSound:(XHBGameSoundType)soundType
{
    if (self.soundOpen) {
        if (soundType==XHBGameSoundTypeStep) {
            [[HBPlaySoundUtil shareForPlayingSoundEffectWith:@"down.wav"] play];
        }else if(soundType==XHBGameSoundTypeError){
            [[HBPlaySoundUtil shareForPlayingSoundEffectWith:@"lost.wav"] play];
        }else if(soundType==XHBGameSoundTypeFailed){
            [[HBPlaySoundUtil shareForPlayingSoundEffectWith:@"au_gameover.wav"] play];
        }else if(soundType==XHBGameSoundTypeVictory){
            [[HBPlaySoundUtil shareForPlayingSoundEffectWith:@"au_victory.wav"] play];
        }else if(soundType==XHBGameSoundTypeTimeOver){
            [[HBPlaySoundUtil shareForPlayingSoundEffectWith:@""] play];
        }
    }
}

-(void)game:(XHBGomokuGameEngine *)game statuChange:(XHBGameStatu)gameStatu
{
}

-(void)gameRestart:(XHBGomokuGameEngine*)game
{
    self.undoCount=0;
    if (self.undoCount>=3) {
        self.btnUndo.enabled=NO;
        [self.btnUndo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }else{
        self.btnUndo.enabled=YES;
        [self.btnUndo setTitleColor:[self.btnRestart titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    }
    [self.btnUndo setTitle:[NSString stringWithFormat:@"UNDO(%ld)",(long)(3-self.undoCount)] forState:UIControlStateNormal];
    for (XHBGomokuPieceView * view in self.pieces) {
        [view removeFromSuperview];
    }
    self.pieces=[NSMutableArray array];
}

-(void)game:(XHBGomokuGameEngine*)game undo:(XHBGomokuChessPoint*)point
{
    XHBGomokuPieceView * deleteView=nil;
    for (XHBGomokuPieceView * view in self.pieces) {
        if (view.point==point) {
            [view removeFromSuperview];
            deleteView=view;
        }
    }
    if (deleteView) {
        [self.pieces removeObject:deleteView];
    }
}

-(UIImage*)screenshot:(UIView*)view
{
    CGSize imageSize =view.bounds.size;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    }
    else
    {
        UIGraphicsBeginImageContext(imageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[view layer] renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



@end
