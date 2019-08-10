//
//  ParentLockPlayerControls.h
//
//  Created by Guy Kogus on 6/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@import ApplicasterSDK;

typedef NS_ENUM(NSUInteger, GAPlayerControlsLockButtonPosition) {
    GAPlayerControlsLockButtonPositionTopLeft,
    GAPlayerControlsLockButtonPositionTopRight,
    GAPlayerControlsLockButtonPositionBottomLeft,
    GAPlayerControlsLockButtonPositionBottomRight
};

@interface GAPlayerControlsViewBasicPlayer : APPlayerControlsView <APPlayerControls>

@property (nonatomic, weak) IBOutlet UIView *instructionsView;
@property (nonatomic, weak) IBOutlet UILabel *instructionsLabel;
@property (nonatomic, weak) IBOutlet UIView *controlsView;
@property (nonatomic, weak) IBOutlet UIButton *lockButton;
@property (nonatomic, weak) IBOutlet UIButton *replayButton;
@property (nonatomic, weak) IBOutlet UIImageView *playerBarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *instuctionsImageView;

@property (nonatomic, assign) BOOL shouldCenterLockInstructionMessage;
@property (nonatomic, assign) BOOL shouldShowInstructionMessage;
@property (nonatomic, assign) GAPlayerControlsLockButtonPosition lockButtonPosition;

- (IBAction)replayButtonPressed:(id)sender;

@end
