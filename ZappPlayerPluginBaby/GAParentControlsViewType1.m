//
//  BTVOfflineOverlayParentControlsView.m
//  BabyTVHQME
//
//  Created by Tom Susel on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GAParentControlsViewType1.h"
#import "APCustomPlayerResourceHelper.h"
@import ApplicasterSDK;

@implementation GAParentControlsViewType1

#pragma mark -
#pragma mark NSObject

#pragma mark -
#pragma mark UIView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		_isPaused = NO;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [_replayButton setImage:[APCustomPlayerResourceHelper
                             imageNamed:@"baby_player_replay_btn"]
                   forState:UIControlStateNormal];
    [_replayButton setImage:[APCustomPlayerResourceHelper
                             imageNamed:@"baby_player_replay_btn_selected"]
                   forState:UIControlStateHighlighted];
    
    [_stopButton setImage:[APCustomPlayerResourceHelper
                           imageNamed:@"baby_player_stop_btn"]
                 forState:UIControlStateNormal];
    [_stopButton setImage:[APCustomPlayerResourceHelper
                           imageNamed:@"baby_player_stop_btn_selected"]
                 forState:UIControlStateHighlighted];
    
    [_pausePlayButton setImage:[APCustomPlayerResourceHelper
                           imageNamed:@"baby_player_pause_btn"]
                 forState:UIControlStateNormal];
    [_pausePlayButton setImage:[APCustomPlayerResourceHelper
                                imageNamed:@"baby_player_pause_btn"]
                      forState:UIControlStateHighlighted];

}

- (void)pauseVideo{
	[self setPlayPauseButtonAsPause:NO];
}

- (void)resumeVideo{
	[self setPlayPauseButtonAsPause:YES];
}

#pragma mark -
#pragma mark BTVOfflineOverlayParentControlsView - public

- (IBAction)pausePlayTapped:(id)sender{
	if (_isPaused){
		[self resumeVideo];
		[[NSNotificationCenter defaultCenter] postNotificationName:APApplicasterPlayerResumePlaybackNotification
															object:self];
	}
	else {
		[self pauseVideo];
		[[NSNotificationCenter defaultCenter] postNotificationName:APApplicasterPlayerPausePlaybackNotification
															object:self];
	}

}

- (IBAction)stopTapped:(id)sender{
    [self setPlayPauseButtonAsPause:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:APApplicasterPlayerStopNotification
                                                        object:self];
}

- (IBAction)replayTapped:(id)sender{
    [self setPlayPauseButtonAsPause:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:APApplicasterPlayerReloadNotification
                                                        object:self];
}

- (IBAction)forwardTapped:(id)sender{
    [self setPlayPauseButtonAsPause:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:APApplicasterPlayerForwardPlaybackNotification
                                                        object:self];
}

- (IBAction)backwardTapped:(id)sender{
    [self setPlayPauseButtonAsPause:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:APApplicasterPlayerBackwardPlaybackNotification
                                                        object:self];
}

- (void)setPlayPauseButtonAsPause:(BOOL)isPause{
    if (isPause == YES){
        [_pausePlayButton setImage:[APCustomPlayerResourceHelper
                        imageNamed:@"baby_player_pause_btn"]
                          forState:UIControlStateNormal];
        [_pausePlayButton setImage:[APCustomPlayerResourceHelper
                                    imageNamed:@"baby_player_pause_btn"]
                          forState:UIControlStateHighlighted];
    }
    else {
        [_pausePlayButton setImage:[APCustomPlayerResourceHelper
                        imageNamed:@"baby_player_play_btn"]
                          forState:UIControlStateNormal];
        [_pausePlayButton setImage:[APCustomPlayerResourceHelper
                                    imageNamed:@"baby_player_play_btn"]
                          forState:UIControlStateHighlighted];
    }
	_isPaused = !isPause;
}


#pragma mark -
#pragma mark NSCoding


- (id)initWithCoder:(NSCoder *)aDecoder{
	if (self = [super initWithCoder:aDecoder]){
		_isPaused = NO;
	}
	
	return self;
}

@end
