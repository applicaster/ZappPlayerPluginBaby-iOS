//
//  BTVOfflineOverlayParentControlsView.h
//  BabyTVHQME
//
//  Created by Tom Susel on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@import ApplicasterSDK;

#import <UIKit/UIKit.h>

@interface GAParentControlsViewType1 : UIView {
	IBOutlet UIButton *_pausePlayButton;
	IBOutlet UIButton *_stopButton;
	IBOutlet UIButton *_replayButton;
	
	BOOL _isPaused;
}

- (IBAction)pausePlayTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)replayTapped:(id)sender;

- (void)setPlayPauseButtonAsPause:(BOOL)isPause;

@end
