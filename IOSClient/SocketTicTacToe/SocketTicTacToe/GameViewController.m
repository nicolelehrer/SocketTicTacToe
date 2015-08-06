//
//  ViewController.m
//  TicTacToe
//
//  Created by Nicole Lehrer on 2/9/15.
//  Copyright (c) 2015 Nicole Lehrer. All rights reserved.
//

#import "GameViewController.h"
#import "GamePieceController.h"
#import "Constants.h"
#import "SocketTicTacToe-Swift.h"


@interface GameViewController ()
@property (nonatomic) NSMutableArray * gamePieceButtons;
@property (nonatomic) NSString * currentPlayer;
@property (nonatomic) GamePieceController * gamePieceController;
@property (nonatomic) InterfaceTag interfaceTag;
@property (nonatomic) SocketInterface * socket;
@end

@implementation GameViewController
@synthesize gamePieceButtons = _gamePieceButtons;
@synthesize currentPlayer = _currentPlayer;
@synthesize gamePieceController = _gamePieceController;
@synthesize interfaceTag = _interfaceTag;
@synthesize socket = _socket;

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.gamePieceController = [[GamePieceController alloc] init];
    
    self.gamePieceButtons = [[NSMutableArray alloc] init];
    [self createButtonMatrixWithRowCount:3 andColumnCount:3];
    [self shouldEnableGameButtonsWithFlag:NO];
    
    self.socket = [[SocketInterface alloc] init];
    [self.socket startConnection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievePlayerAssignment:) name:@"PlayerAssignmentNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveUpdateBoard:) name:@"UpdateBoardNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveEndGameNotification:) name:@"EndNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveResetGameNotification:) name:@"ResetNotification" object:nil];
}


-(void)shouldEnableGameButtonsWithFlag:(BOOL)flag{
    
    for (UIView * aView in self.view.subviews) {
       
        if ([aView isKindOfClass:[UIButton class]]) {
            
            //some view objects are of class _UILayoutGuide
            
            UIButton * aButton = (UIButton * )aView;
            
            if (flag) {
                aButton.enabled = YES;
                aButton.alpha = 1.0;
            }
            else{
                aButton.enabled = NO;
                aButton.alpha = 0.5;
            }
            
            //making this a separate operation because previous way of freezing screen is temporary
            [self.gamePieceController resetDisabledStateForButtonIfTitleFilled:aButton];
        }
    }
}


-(void)recievePlayerAssignment:(NSNotification *)notification {
    
    if([[notification object] isKindOfClass:[Game class]]){
        
        Game * game = [notification object];
        self.currentPlayer = game.currentPlayer;
        
        if ([self.currentPlayer isEqualToString:@"X"]){
            [self shouldEnableGameButtonsWithFlag:YES];
        }
    }
}

-(void)recieveEndGameNotification:(NSNotification *)notification {
    
    if([[notification object] isKindOfClass:[Game class]]){
        
        Game * game = [notification object];
        
        NSLog(@"gamestate is %ld", (long)game.gameState);
        
        if(game.gameState == StateWon){
            [self endGameWithAWinner:game.currentPlayer ifWon:YES];
        }
        else{
            [self endGameWithAWinner:game.currentPlayer ifWon:NO];
        }
    }
}

-(void)recieveResetGameNotification:(NSNotification *)notification {
    for (UIView * view in self.view.subviews) {
        if (view.tag==removeDuringPlay) {
            [view removeFromSuperview];
        }
        else if([view isKindOfClass:[UIButton class]]){
            UIButton * button = (UIButton*)view;
            [self.gamePieceController setEnabledStateForButton:button];
        }
    }
}

-(void)recieveUpdateBoard:(NSNotification *)notification {
    
    if([[notification object] isKindOfClass:[Game class]]){

        Game * game = [notification object];
        NSString * fromPlayer = game.currentPlayer;
        int tagID = (int)game.lastMove;
        
        if (tagID>0) {
            
            for (UIButton * abutton in self.view.subviews) {
                if (abutton.tag == tagID) {
                    [self.gamePieceController updatingDisplayFor:abutton ForCurrentPlayer:fromPlayer];
                }
            }
            if ([fromPlayer isEqualToString:self.currentPlayer]){
                [self shouldEnableGameButtonsWithFlag:NO];
            }
            else{
                [self shouldEnableGameButtonsWithFlag:YES];
            }
        }
    }
}


-(void)createButtonMatrixWithRowCount:(int)rowCount andColumnCount:(int)colCount {
    
    float buttonWidth = 70;
    float buttonHeight = buttonWidth;
    float colSpacer = 1.1*buttonWidth;
    float rowSpacer = colSpacer;
    float positionMatrixX = self.view.frame.size.width/2-3*colSpacer/2+(colSpacer-buttonWidth)/2;
    float positionMatrixY = 60;

    int counter = 0;
    for (int col = 0; col<colCount; col++) {
        for (int row = 0; row<rowCount; row++) {
            
            //make a button
            UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            //set its size and location with frame, title and font
            button.frame = CGRectMake(positionMatrixX + row*rowSpacer, positionMatrixY + col*colSpacer, buttonWidth, buttonHeight);
            button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
            [button setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];
            [button setTitle:EMPTY_GAME_PIECE_TITLE_STRING forState:UIControlStateNormal];

            //set tag
            counter++;
            button.tag = counter;
            
            //set its background color
            [self.gamePieceController setEnabledStateForButton:button];
            
            //associate a method with each button
            [button addTarget:self action:@selector(updateDisplayFor:) forControlEvents:UIControlEventTouchDown];
            
            //add button to the view, and to the buttons array which concatenates columns 1, 2, and 3
            [self.view addSubview:button];
            [self.gamePieceButtons addObject:button];
        }
    }
    
    NSLog(@"Size of buttons array is %lu", (unsigned long)[self.gamePieceButtons count]);
}

-(void)updateDisplayFor:(UIButton*)button{
    
    [self.gamePieceController updatingDisplayFor:button ForCurrentPlayer:self.currentPlayer];
    [self.socket sendMessage:@"move" playerID:self.currentPlayer moveID:button.tag];
  
}


-(void)endGameWithAWinner:(NSString*)winner ifWon:(BOOL)aPlayerWon{
    
    NSLog(@"endgamewithwinner called");
   // [self disableMoreMoves];
    
    NSString * message;
    
    if (aPlayerWon) {
        message = [NSString stringWithFormat:@"%@ is the winner", winner];
    }
    else{
        message = [NSString stringWithFormat:@"Cat's game"];
    }
    
    [self updateViewWithMessage:message];
    [self addButtonToPlayAgain];
    
}

-(void)updateViewWithMessage:(NSString*)message{
    
    CGRect referenceFrame = [[self.gamePieceButtons objectAtIndex:7] frame];
    
    float labelWidth = 250;
    float labelHeight = 50;
    float vertSpaceAfterReferenceFrame = 25;
    
    CGRect labelFrame = CGRectMake(referenceFrame.origin.x+referenceFrame.size.width/2-labelWidth/2,
                                   referenceFrame.origin.y+referenceFrame.size.height+vertSpaceAfterReferenceFrame,
                                   labelWidth,
                                   labelHeight);
    
    UILabel * label = [[UILabel alloc] initWithFrame:labelFrame];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = removeDuringPlay;
    label.text = message;
    
    [self.view addSubview:label];
    
}

-(void)addButtonToPlayAgain{
    
    CGRect referenceFrame = [[self.gamePieceButtons objectAtIndex:8] frame];
    
    float buttonWidth = 200;
    float buttonHeight = 50;
    float vertSpaceAfterReferenceFrame = 200;
    
    CGRect buttonFrame = CGRectMake(self.view.frame.size.width/2-buttonWidth/2, referenceFrame.origin.y+vertSpaceAfterReferenceFrame, buttonWidth, buttonHeight);
    
    UIButton * playAgainButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    playAgainButton.frame = buttonFrame;
    
    playAgainButton.tag = removeDuringPlay;
    playAgainButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1];
    [playAgainButton setTitle:@"Play again" forState:UIControlStateNormal];
    [playAgainButton setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    
    [self.view addSubview:playAgainButton];
    
    [playAgainButton addTarget:self action:@selector(resetGame:) forControlEvents:UIControlEventTouchDown];
}

-(void)resetGame:(id)sender
{
    for (UIView * view in self.view.subviews) {
        if (view.tag==removeDuringPlay) {
            [view removeFromSuperview];
        }
    }

    [self updateViewWithMessage:@"Waiting on other player"];
    [self.socket sendMessage:@"reset" playerID:@"-" moveID:0];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
