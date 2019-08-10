//
//  BTVSequencedButton.m
//  BabyTVHQME
//
//  Created by Tom Susel on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define kSequenceButtonImagesCount 12
#define kSequenceAnimationDuration 1.0
#define kAutomaticSequenceAnimationDuration 7.0
#define kSequenceButtonImageNameFormat @"baby_player_cake_%i"

#import "GAControlerSequencedButtonView.h"
#import "APCustomPlayerResourceHelper.h"

@interface GAControlerSequencedButtonView ()

- (void)setupManualSequenceImage;
- (void)setupAutomaticSequence;


//Automatic sequence
- (void)automaticSequenceDidEnd;

@end

@implementation GAControlerSequencedButtonView
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark NSObject

- (void)awakeFromNib{
	[super awakeFromNib];
	[self setupManualSequenceImage];
	_isInAutoSequenceMode = NO;
}

#pragma mark -
#pragma mark UIView

- (id)initWithFrame:(CGRect)aFrame{
	if (self = [super initWithFrame:aFrame]){
		[self setupManualSequenceImage];
		_delegate = nil;
	}
	
	return self;
}
#pragma mark -
#pragma mark BTVSequencedButtonView - public

- (IBAction)buttonTouchDown:(id)sender{
	if (_isInAutoSequenceMode == YES){
		
		if ([_delegate respondsToSelector:@selector(buttonTappedDuringAutoSequence:)] == YES){
			[_delegate buttonTappedDuringAutoSequence:self];
		}
		
		[self stopAutomaticSequence];
	}
	else {
		[self startSequence];	
	}
}

- (IBAction)buttonTouchUp:(id)sender{
	if (_isInAutoSequenceMode == YES){
		//[self automaticSequenceDidEnd];
	}
	else {
		[self stopSequence];
	}
}

- (IBAction)buttonTouchCancelled:(id)sender{
	if (_isInAutoSequenceMode == NO){
		[self stopSequence];	
	}
}

#pragma mark -
#pragma mark BTVSequencedButtonView - private

- (void)setupManualSequenceImage{
    [_button setImage: [APCustomPlayerResourceHelper imageNamed:@"baby_player_btn"]
                      forState:UIControlStateNormal];

    if ([_backgroundSequenceImage.animationImages count] > 1  &&
		_backgroundSequenceImage.animationDuration == kSequenceAnimationDuration){
		return;
	}
	
	//Build an array of images
	NSMutableArray *imagesArray = [[NSMutableArray alloc] initWithCapacity:kSequenceButtonImagesCount];
	
	for (int i = 1; i <= kSequenceButtonImagesCount; i ++){
        UIImage *sequenceImage = [APCustomPlayerResourceHelper imageNamed:[NSString stringWithFormat:kSequenceButtonImageNameFormat, i]];
		
		if (sequenceImage != nil){
			[imagesArray addObject:sequenceImage];
		}
	}
	
	//Set the sequence
	_backgroundSequenceImage.animationImages = imagesArray;
	_backgroundSequenceImage.animationRepeatCount = 1;
	_backgroundSequenceImage.animationDuration = kSequenceAnimationDuration;
		 
}

- (void)setupAutomaticSequence{
	if ([_backgroundSequenceImage.animationImages count] > 1  && 
		_backgroundSequenceImage.animationDuration == kAutomaticSequenceAnimationDuration){
		return;
	}
	
	//Build an array of images
	NSMutableArray *imagesArray = [[NSMutableArray alloc] initWithCapacity:kSequenceButtonImagesCount];
	
	for (int i = kSequenceButtonImagesCount; i >= 1; i --){
        UIImage *sequenceImage = [APCustomPlayerResourceHelper imageNamed:[NSString stringWithFormat:kSequenceButtonImageNameFormat, i]];
		
		if (sequenceImage != nil){
			[imagesArray addObject:sequenceImage];
		}
	}
	
	//Set the sequence
	_backgroundSequenceImage.animationImages = imagesArray;
	_backgroundSequenceImage.animationRepeatCount = 1;
	_backgroundSequenceImage.animationDuration = kAutomaticSequenceAnimationDuration;
	
}

- (void)stopSequence{
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(manualSequenceEnded)
											   object:nil];

    //Inform delegate of sequence stop
    if ([_delegate respondsToSelector:@selector(sequenceButtonViewDidManuallyStop:)] == YES){
        [_delegate sequenceButtonViewDidManuallyStop:self];
    }

	[_backgroundSequenceImage stopAnimating];
}

- (void)startSequence{
	[self setupManualSequenceImage];
	[_backgroundSequenceImage startAnimating];

    //Inform delegate of sequence start
    if ([_delegate respondsToSelector:@selector(sequenceButtonViewDidManuallyStart:)] == YES){
        [_delegate sequenceButtonViewDidManuallyStart:self];
    }

	[self performSelector:@selector(manualSequenceEnded)
			   withObject:nil
			   afterDelay:kSequenceAnimationDuration];
}

- (void)manualSequenceEnded{
	//Stop animation
	[self stopSequence];
	
	//Unselect the button
	[_button setSelected:NO];
	
	//Inform delegate of sequence completion
	if ([_delegate respondsToSelector:@selector(sequenceButtonViewDidManuallyComplete:)] == YES){
		[_delegate sequenceButtonViewDidManuallyComplete:self]; 
	}
	
	[self performSelector:@selector(startAutomaticSequence)
			   withObject:nil
			   afterDelay:0.1];
}

- (void)startAutomaticSequence{
	if (_isInAutoSequenceMode == NO){
		[self performSelector:@selector(automaticSequenceDidEnd)
				   withObject:nil
				   afterDelay:kAutomaticSequenceAnimationDuration];
		
		[self setupAutomaticSequence];
		
		[_backgroundSequenceImage startAnimating];
		
		_isInAutoSequenceMode = YES;
	}
}

- (void)stopAutomaticSequence{
	if (_isInAutoSequenceMode == YES){
		[_backgroundSequenceImage stopAnimating];
		
		_isInAutoSequenceMode = NO;
	}
}

- (void)automaticSequenceDidEnd{
	if (_isInAutoSequenceMode == YES){
		//Announce end of sequence
		
		[self stopAutomaticSequence];
		
		if ([_delegate respondsToSelector:@selector(sequenceButtonViewDidAutoComplete:)] == YES){
			[_delegate sequenceButtonViewDidAutoComplete:self];
		}
	}
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder{
	if (self = [super initWithCoder:aDecoder]){
		[self setupManualSequenceImage];
		_delegate = nil;
	}
	
	return self;
}

@end
