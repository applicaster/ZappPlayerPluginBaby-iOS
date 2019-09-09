//
//  Created by Tom Susel on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@import ApplicasterSDK;

#import "GAPlayerControlsViewBabyPlayer.h"
#import <MediaPlayer/MediaPlayer.h>


@interface GAPlayerControlsViewBabyPlayer ()

@property (nonatomic,strong) NSMutableDictionary *currentPlayingItemDict;

- (void)hideParentControlls;
- (void)playerDidStop:(NSNotification*)aNotification;

@end


@implementation GAPlayerControlsViewBabyPlayer

//_volume view uses for airplay mode
@synthesize volumeView = _volumeView;

#pragma mark -
#pragma mark NSObject

- (void)awakeFromNib{
	[super awakeFromNib];
	_sequenceButtonView.delegate = self;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerDidStop:)
												 name:APApplicasterPlayerDidStopNotification
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFavoriteButton)
                                                 name:APLocalFavoritesDidRemoveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFavoriteButton)
                                                 name:APLocalFavoritesDidAddNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDownloadButton)
                                                 name:APHQMEDidRemoveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDownloadButton)
                                                 name:APHQMEDidAddNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                       selector:@selector(handleDownloadFinished)
                                           name:APVodItemDownloadFinished
                                         object:nil];

	
	[self show:NO];
    [self.stopButton setImage:[UIImage imageNamed:@"player_stop_unclicked"]
                     forState:UIControlStateNormal];
    [self.pauseButton setImage:[UIImage imageNamed:@"player_pause"]
                     forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"player_play"]
                     forState:UIControlStateNormal];

    self.volumeView.showsVolumeSlider = NO;
    [self.volumeView sizeToFit];
    [self.volumeView setRouteButtonImage:[UIImage imageNamed:@"player_airplay_off"] forState:UIControlStateNormal];
    [self.volumeView setRouteButtonImage:[UIImage imageNamed:@"player_airplay_clicked"] forState:UIControlStateHighlighted];
    [self.volumeView setRouteButtonImage:[UIImage imageNamed:@"player_airplay_on"] forState:UIControlStateSelected];
    
    for (id subView in self.volumeView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            [button addTarget:self action:@selector(airButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_sequenceButtonView.delegate = nil;
}

#pragma mark -
#pragma mark UIView

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *hitView = [super hitTest:point withEvent:event];
	if (hitView == self){
		//Hide the parent controlls if visible
		if (_parentControls.alpha > 0.0){
			[self hideParentControlls];	
		}
		
		// This makes the background view touchable
		hitView = nil;
	}
	
	return hitView;
}

#pragma mark - APPlayerControls

- (void)hide:(BOOL)animated {
	
}

- (void)show:(BOOL)animated {
    
}

- (BOOL)isVisible {
	return NO;
}

- (void)setBuffering:(BOOL)buffering {
    
}

#pragma mark - APPlayerControls Protocol

- (void)videoContentDidStartPlayingWithItem:(NSDictionary *)playingItemInfo{
    BOOL isLive = [[playingItemInfo objectForKey:kAPPlayerControlsPlayingItemIsLive] boolValue];
    if (isLive) {
        [self.favoriteButton setHidden:YES];
        [self.downloadButton setHidden:YES];
    } else {
        self.currentPlayingItemDict = [[NSMutableDictionary alloc] initWithDictionary:playingItemInfo];
        [self updateFavoriteImage];
        [self updateDownloadImage];
    }
}


#pragma mark - action buttons

- (IBAction)favoriteButtonTapped:(id)sender {
    if (self.currentPlayingItemDict) {
        if ([self isLocalFavorite]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:APPlayerControllerRemoveFromFavorites object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:APPlayerControllerAddToFavorites object:nil];
        }
    }
}

- (IBAction)downloadButtonTapped:(id)sender {
    if (self.currentPlayingItemDict) {
        if ([self isVodItemDownloaded] == NO && [self isDownloadingVodItem] == NO) {
            //add to download
            [[NSNotificationCenter defaultCenter] postNotificationName:APPlayerControllerMarkCurrentItemForDownloadNotification object:nil];
        } else if ([self isVodItemDownloaded]) {
            //remove from download
            [[NSNotificationCenter defaultCenter] postNotificationName:APPlayerControllerDeleteCurrentItemFromCacheNotification object:nil];
        } else if ([self isDownloadingVodItem]) {
            //cancel and remove the download
            [[NSNotificationCenter defaultCenter] postNotificationName:APPlayerControllerCancelCurrentItemFromDownloadNotification object:nil];
        }
    }
}

#pragma mark - private helper methods

- (void)updateFavoriteButton {
    if (self.currentPlayingItemDict) {
        //mark the vod as favorite only if it is not already been marked, we are doing that by checking the vod's old isFavorite state
        NSNumber *shouldMarkedAsLocalFavorite = [NSNumber numberWithBool:(![self isLocalFavorite])];
        //update the vod's isfavorite state to it's new state
        [self.currentPlayingItemDict setObject:shouldMarkedAsLocalFavorite forKey:kAPPlayerControllerPlayingItemIsFavorite];
        //update the favorite button's image according to the new state
        [self updateFavoriteImage];
    }
}

- (void)updateDownloadButton {
    if (self.currentPlayingItemDict) {
        //check if it is already been clicked
        NSNumber *shouldMarkForDownload =[NSNumber numberWithBool: (!([self isVodItemDownloaded] || [self isDownloadingVodItem]))];
        [self.currentPlayingItemDict setObject:shouldMarkForDownload forKey:kAPPlayerControllerPlayingItemIsDownloading];
        [self.currentPlayingItemDict setObject:[NSNumber numberWithBool:NO] forKey:kAPPlayerControllerPlayingItemIsDownloaded];
        [self updateDownloadImage];
    }
}

- (void)updateFavoriteImage {
    NSString *favoriteImageName = [self isLocalFavorite]? @"player_favorite_active": @"player_favorite_not_active";
    [self.favoriteButton setImage: [UIImage imageNamed:favoriteImageName] forState:UIControlStateNormal];
}

- (void)updateDownloadImage {
    BOOL shouldEnableButton = (([self isDownloadingVodItem] || [self isVodItemDownloaded])==NO
                               || ([self isDeletableVodItem]));
    self.downloadButton.userInteractionEnabled = shouldEnableButton;
    NSString *downloadImageName = ([self isDownloadingVodItem] || [self isVodItemDownloaded])? @"player_download_btn_active": @"player_download_btn";
    if (shouldEnableButton == NO) {
        downloadImageName = @"player_download_btn_disabled";
    }
    [self.downloadButton setImage:[UIImage imageNamed:downloadImageName] forState:UIControlStateNormal];

}


- (void)handleDownloadFinished {
    [self.currentPlayingItemDict setObject:[NSNumber numberWithBool:YES] forKey:kAPPlayerControllerPlayingItemIsDownloaded];
    [self.currentPlayingItemDict setObject:[NSNumber numberWithBool:NO]  forKey:kAPPlayerControllerPlayingItemIsDownloading];
    [self updateDownloadImage];
}

- (BOOL)isLocalFavorite {
    return [[self.currentPlayingItemDict objectForKey:kAPPlayerControllerPlayingItemIsFavorite] boolValue];
}

- (BOOL)isVodItemDownloaded {
    return [[self.currentPlayingItemDict objectForKey:kAPPlayerControllerPlayingItemIsDownloaded] boolValue];
}

- (BOOL)isDownloadingVodItem {
    return [[self.currentPlayingItemDict objectForKey:kAPPlayerControllerPlayingItemIsDownloading] boolValue];
}

- (BOOL)isDeletableVodItem {
    return [[self.currentPlayingItemDict objectForKey:kAPPlayerControllerPlayingItemIsDeletable] boolValue];
}

#pragma mark -
#pragma mark BTVOfflineOverlayView - private

- (void)hideParentControlls{

  
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(parentContrllsDidFade:finished:context:)];
	[UIView setAnimationDuration:0.3];
	
	_parentControls.alpha = 0.0;

	[UIView commitAnimations];
    
}

- (void)parentContrllsDidFade:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	//Show the parents controls

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelegate:self];
	
	_sequenceButtonView.alpha = 1.0;
	
	[UIView commitAnimations];	
}

- (void)playerDidStop:(NSNotification*)aNotification{
	if (_parentControls.alpha > 0.0){
		[self hideParentControlls];
	}
	
    [_sequenceButtonView stopAutomaticSequence]; //press stop and return to the vod fast (before 7 sec) the button is still animating
}

#pragma mark -
#pragma mark BTVSequenceButtonViewDelegate

- (void)sequenceButtonViewDidManuallyComplete:(GAControlerSequencedButtonView*)sequenceButtonView{
	[_sequenceButtonView startAutomaticSequence];
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.3];
	
	_parentControls.alpha = 1.0;
	
	[UIView commitAnimations];	
}

- (void)sequenceButtonViewDidAutoComplete:(GAControlerSequencedButtonView*)sequenceButtonView{
	[self hideParentControlls];
}

- (void)buttonTappedDuringAutoSequence:(GAControlerSequencedButtonView *)sequenceButtonView{
	[self hideParentControlls];
}

- (void)airButtonDidPushed {
    [_sequenceButtonView stopAutomaticSequence];
}
@end

