//
//  GamePieceController.m
//  TicTacToe
//
//  Created by Nicole Lehrer on 2/28/15.
//  Copyright (c) 2015 Nicole Lehrer. All rights reserved.
//

#import "GamePieceController.h"
#import "Constants.h"

@implementation GamePieceController

-(id)init{

    if (self=[super init]) {
    }
    return self;
}

- (void)setEnabledStateForButton:(UIButton *)button {
    button.enabled = YES;
    button.backgroundColor =  [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1];
    [button setTitle:EMPTY_GAME_PIECE_TITLE_STRING forState:UIControlStateNormal];
}

- (void)resetDisabledStateForButtonIfTitleFilled:(UIButton *)button {
        if (![button.currentTitle isEqualToString:EMPTY_GAME_PIECE_TITLE_STRING]) {
        button.enabled = NO;
    }
}

-(void)updatingDisplayFor:(UIButton*)button ForCurrentPlayer:(NSString*)currentPlayer{
    
    if ([currentPlayer isEqualToString:@"X"]) {
        [button setTitle:@"X" forState:UIControlStateNormal];
        button.backgroundColor =  [UIColor colorWithRed:236/256. green:93/256. blue:87/256. alpha: .7];
    }
    else{
        [button setTitle:@"O" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithRed:0.09375 green:0.56640625 blue:0.7617 alpha:.7];
    }
}


@end
