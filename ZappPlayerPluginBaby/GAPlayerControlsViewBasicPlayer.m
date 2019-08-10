//
//  GAPlayerControlsViewBasicPlayer.m
//
//  Created by Guy Kogus on 6/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GAPlayerControlsViewBasicPlayer.h"
#import "APCustomPlayerResourceHelper.h"
#import "ZPUICustomizationHelper.h"
#import "UILabel+APBabyCustomization.h"

@import ZappPlugins;

static CGFloat const kAnimationTime = 0.25;

@interface GAPlayerControlsViewBasicPlayer ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *instructionViewTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *instructionViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *instructionViewCenterHorizontallyConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lockButtonTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lockButtonBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lockButtonTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lockButtonLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lockButtonWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lockButtonHeightConstraint;

- (void)tapRecognized:(UITapGestureRecognizer *)tgr;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)lpgr;

@end

@implementation GAPlayerControlsViewBasicPlayer

@synthesize stopButton=_stopButton;
@synthesize instructionsView=_instructionsView, instructionsLabel=_instructionsLabel;
@synthesize controlsView=_controlsView, lockButton=_lockButton;

#pragma mark - UIView

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self
																		  action:@selector(tapRecognized:)];
	[self.lockButton addGestureRecognizer:tgr];
	
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
																					   action:@selector(longPressRecognized:)];
	lpgr.minimumPressDuration = 1.0;
	[self.lockButton addGestureRecognizer:lpgr];
    [self setPlayerControles];
    [self updatebackgroundImages];
    
    self.lockButtonPosition = GAPlayerControlsLockButtonPositionTopRight;
    self.shouldCenterLockInstructionMessage = YES;
    self.shouldShowInstructionMessage = NO;
}

- (void)setPlayerControles {
    [self.stopButton setImage:[APCustomPlayerResourceHelper
                           imageNamed:@"baby_player_stop_btn"]
                 forState:UIControlStateNormal];
    [self.stopButton setImage:[APCustomPlayerResourceHelper
                               imageNamed:@"baby_player_stop_btn_selected"]
                     forState:UIControlStateHighlighted];
    [self.replayButton setImage:[APCustomPlayerResourceHelper
                               imageNamed:@"baby_player_replay_btn"]
                     forState:UIControlStateNormal];
    [self.replayButton setImage:[APCustomPlayerResourceHelper
                               imageNamed:@"baby_player_replay_btn_selected"]
                     forState:UIControlStateHighlighted];
    [self.lockButton setImage:[APCustomPlayerResourceHelper
                                 imageNamed:@"baby_player_btn"]
                       forState:UIControlStateNormal];
    [self.lockButton setImage:[APCustomPlayerResourceHelper
                                 imageNamed:@"baby_player_btn_selected"]
                       forState:UIControlStateHighlighted];
}

- (void)setConstraintsForCurrentConfiguration
{
    NSMutableArray *activatedConstaints = [NSMutableArray array];
    NSMutableArray *deactivatedConstaints = [NSMutableArray array];
    
    CGFloat lockButtonSpacing = [ZPUICustomizationHelper sizeForKey:@"ParentLockPlayerControlsViewInstructionHorizontalSpace" defaultSize:IS_IPAD() ? 17.0 : 13.0f];
    CGFloat lockButtonWidth = [ZPUICustomizationHelper sizeForKey:@"ParentLockPlayerControlsViewInstructionHorizontalSpace" defaultSize:64.0f];
    CGFloat lockButtonHeight = [ZPUICustomizationHelper sizeForKey:@"ParentLockPlayerControlsViewInstructionHorizontalSpace" defaultSize:64.0f];
    self.lockButtonWidthConstraint.constant = lockButtonWidth;
    self.lockButtonHeightConstraint.constant = lockButtonHeight;
    
    if (self.lockButtonPosition == GAPlayerControlsLockButtonPositionTopLeft)
    {
        [activatedConstaints addObject:self.lockButtonTopConstraint];
        self.lockButtonTopConstraint.constant = lockButtonSpacing;
        
        [activatedConstaints addObject:self.lockButtonLeadingConstraint];
        self.lockButtonLeadingConstraint.constant = lockButtonSpacing;
        
        [activatedConstaints addObject:self.instructionViewLeadingConstraint];
        self.instructionViewLeadingConstraint.constant = 0;
        
        [deactivatedConstaints addObject:self.lockButtonBottomConstraint];
        [deactivatedConstaints addObject:self.lockButtonTrailingConstraint];
        [deactivatedConstaints addObject:self.instructionViewTrailingConstraint];
    }
    else if (self.lockButtonPosition == GAPlayerControlsLockButtonPositionTopRight)
    {
        [activatedConstaints addObject:self.lockButtonTopConstraint];
        self.lockButtonTopConstraint.constant = lockButtonSpacing;
        
        [activatedConstaints addObject:self.lockButtonTrailingConstraint];
        self.lockButtonTrailingConstraint.constant = lockButtonSpacing;
        
        [activatedConstaints addObject:self.instructionViewTrailingConstraint];
        self.instructionViewTrailingConstraint.constant = 0;
        
        [deactivatedConstaints addObject:self.lockButtonBottomConstraint];
        [deactivatedConstaints addObject:self.lockButtonLeadingConstraint];
        [deactivatedConstaints addObject:self.instructionViewLeadingConstraint];
    }
    else if (self.lockButtonPosition == GAPlayerControlsLockButtonPositionBottomLeft)
    {
        [activatedConstaints addObject:self.lockButtonBottomConstraint];
        self.lockButtonBottomConstraint.constant = lockButtonSpacing;
        
        [activatedConstaints addObject:self.lockButtonLeadingConstraint];
        self.lockButtonLeadingConstraint.constant = lockButtonSpacing;
        
        [activatedConstaints addObject:self.instructionViewLeadingConstraint];
        self.instructionViewLeadingConstraint.constant = 0;
        
        [deactivatedConstaints addObject:self.lockButtonTopConstraint];
        [deactivatedConstaints addObject:self.lockButtonTrailingConstraint];
        [deactivatedConstaints addObject:self.instructionViewTrailingConstraint];
    }
    else if (self.lockButtonPosition == GAPlayerControlsLockButtonPositionBottomRight)
    {
        [activatedConstaints addObject:self.lockButtonBottomConstraint];
        self.lockButtonBottomConstraint.constant = lockButtonSpacing;
        
        [activatedConstaints addObject:self.lockButtonTrailingConstraint];
        self.lockButtonTrailingConstraint.constant = lockButtonSpacing;
        
        [activatedConstaints addObject:self.instructionViewTrailingConstraint];
        self.instructionViewTrailingConstraint.constant = 0;
        
        [deactivatedConstaints addObject:self.lockButtonTopConstraint];
        [deactivatedConstaints addObject:self.lockButtonLeadingConstraint];
        [deactivatedConstaints addObject:self.instructionViewLeadingConstraint];
    }
    
    if (self.shouldCenterLockInstructionMessage)
    {
        [activatedConstaints addObject:self.instructionViewCenterHorizontallyConstraint];

        [deactivatedConstaints addObject:self.instructionViewLeadingConstraint];
        self.instructionViewLeadingConstraint.constant = 0;
        
        [deactivatedConstaints addObject:self.instructionViewTrailingConstraint];
        self.instructionViewTrailingConstraint.constant = 0;
    }
    
    [NSLayoutConstraint activateConstraints:activatedConstaints];
    [NSLayoutConstraint deactivateConstraints:deactivatedConstaints];
}

- (void)updatebackgroundImages {
    self.playerBarImageView.image = [APCustomPlayerResourceHelper imageNamed:@"player_bar_background_image"];
    self.instuctionsImageView.image = [APCustomPlayerResourceHelper imageNamed:@"player_insructions_background_image"];
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
    self.size = self.superview.size;

    [self.instructionsLabel setLabelStyleForKey:@"ParentLockPlayerControlsViewInstructionLabel"];
	self.instructionsLabel.text = [@"Press and hold for 2 seconds" withKey:@"ParentLockPlayerInstructions"];
    
    [self setConstraintsForCurrentConfiguration];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *hitView = [super hitTest:point withEvent:event];
	
	// Make the view unhittable
	if (hitView == self)
		hitView = nil;
	
	return hitView;
}

#pragma mark - APPlayerControls

- (void)show:(BOOL)animated
{
	[UIView animateWithDuration:kAnimationTime
						  delay:0.0
						options:UIViewAnimationOptionCurveLinear
					 animations:^{
						 self.controlsView.alpha = 1.0;
					 }
					 completion:NULL];
}

- (void)hide:(BOOL)animated
{
	[UIView animateWithDuration:kAnimationTime
						  delay:0.0
						options:UIViewAnimationOptionCurveLinear
					 animations:^{
						 self.controlsView.alpha = 0.0;
					 }
					 completion:NULL];
}

- (BOOL)isVisible
{
	// Don't let the controls be auto-shown or dismissed. This is our business.
	return YES;
}

- (void)setPlaying:(BOOL)playing
{
}

- (NSTimeInterval)initialPlayerControlsHideDelay
{
    return 0.0;
}

#pragma mark - ParentLockPlayerControls

- (IBAction)replayButtonPressed:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:APApplicasterPlayerReloadNotification
														object:nil];
}

#pragma mark - Private

- (void)tapRecognized:(UITapGestureRecognizer *)tgr
{
	// If the tap gesture is recognized, the button wasn't held for long enough.
	// In this case we want to briefly show the controls instructions.
	if (tgr.state == UIGestureRecognizerStateEnded)
	{
		static NSTimeInterval const kAnimationTime = 0.25;
		[UIView animateWithDuration:kAnimationTime
						 animations:^{
                             if (self.shouldShowInstructionMessage) {
                                 self.instructionsView.alpha = 1.0;
                             }
						 }
						 completion:^(BOOL finished) {
							 double delayInSeconds = 2.0;
							 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
							 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
								 [UIView animateWithDuration:kAnimationTime
												  animations:^{
													  self.instructionsView.alpha = 0.0;
												  }];
							 });
						 }];
	}
}

- (void)longPressRecognized:(UILongPressGestureRecognizer *)lpgr
{
	if (lpgr.state == UIGestureRecognizerStateBegan)
	{
		[self show:YES];
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self hide:YES];
		});
	}
}

@end
