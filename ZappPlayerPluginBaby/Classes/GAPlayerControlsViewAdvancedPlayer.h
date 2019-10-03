//
//  BTVOfflineOverlayView.h
//  BabyTVHQME
//
//  Created by Tom Susel on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//

#import "GAControlerSequencedButtonView.h"
#import "GAParentControlsViewBabyPlayer.h"
@import ApplicasterSDK;
@import ZappPlugins;
@class MPVolumeView;

@interface GAPlayerControlsViewAdvancedPlayer : APPlayerControlsView{
	IBOutlet GAControlerSequencedButtonView		*_sequenceButtonView;
	IBOutlet GAParentControlsViewBabyPlayer	*_parentControls;
}

@property (nonatomic, weak) IBOutlet UIView *instructionsView;
@property (nonatomic, weak) IBOutlet UILabel *instructionsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *instuctionsImageView;
@property (nonatomic, assign) IBOutlet MPVolumeView *volumeView;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (nonatomic, weak) IBOutlet UIButton *playerForwardButton;
@property (nonatomic, weak) IBOutlet UIButton *playerBackwardButton;
@property (weak, nonatomic) IBOutlet UIView *HqmeButtonContainerView;

@property (nonatomic, assign) BOOL shouldShowInstructionMessage;

@end
