//
//  BTVOfflineOverlayView.h
//  BabyTVHQME
//
//  Created by Tom Susel on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//

#import "GAControlerSequencedButtonView.h"
#import "GAParentControlsViewType1.h"
@import ApplicasterSDK;
@import ZappPlugins;
@class MPVolumeView;

@interface GAPlayerControlsViewAdvancedPlayer : APPlayerControlsView{
	IBOutlet GAControlerSequencedButtonView		*_sequenceButtonView;
	IBOutlet GAParentControlsViewType1	*_parentControls;
}

@property (nonatomic, weak) IBOutlet UIView *instructionsView;
@property (nonatomic, weak) IBOutlet UILabel *instructionsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *instuctionsImageView;
@property (nonatomic, assign) IBOutlet MPVolumeView *volumeView;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (nonatomic, weak) IBOutlet UIButton *playerForwardButton;
@property (nonatomic, weak) IBOutlet UIButton *playerBackwardButton;
@property (weak, nonatomic) IBOutlet UIView *downloadButtonContainerView;

@property (nonatomic, assign) BOOL shouldShowInstructionMessage;

@end
