//
//  GamePieceController.h
//  TicTacToe
//
//  Created by Nicole Lehrer on 2/28/15.
//  Copyright (c) 2015 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GamePieceController : UIViewController

- (void)setEnabledStateForButton:(UIButton*)button;
- (void)resetDisabledStateForButtonIfTitleFilled:(UIButton*)button;
- (void)updatingDisplayFor:(UIButton*)button ForCurrentPlayer:(NSString*)currentPlayer;

@end
