//
//  BTVOfflineOverlayView.h
//  BabyTVHQME
//
//  Created by Tom Susel on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@import ApplicasterSDK;

#import <UIKit/UIKit.h>
#import "GAControlerSequencedButtonView.h"
#import "GAParentControlsViewBabyPlayer.h"

@class MPVolumeView;

@interface GAPlayerControlsViewBabyPlayer : APPlayerControlsView <BTVSequenceButtonViewDelegate, APPlayerControls>{
	IBOutlet GAControlerSequencedButtonView					*_sequenceButtonView;
	IBOutlet GAParentControlsViewBabyPlayer	*_parentControls;
}

@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (nonatomic, weak) IBOutlet UIButton *downloadButton;

@end
