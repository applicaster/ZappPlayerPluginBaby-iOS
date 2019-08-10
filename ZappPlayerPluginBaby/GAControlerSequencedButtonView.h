
//
//  Created by Tom Susel on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@import UIKit;
@import Foundation;

@class GAControlerSequencedButtonView;
@protocol BTVSequenceButtonViewDelegate

/**
 Informs the delegate when the animation duration is over.
 */
- (void)sequenceButtonViewDidManuallyComplete:(GAControlerSequencedButtonView*)sequenceButtonView;

/**
 Informs the delegate when the automatic animation sequence is over.
 */
- (void)sequenceButtonViewDidAutoComplete:(GAControlerSequencedButtonView*)sequenceButtonView;

/**
 Sent to the delegate when touch up during auto sequence.
 */
- (void)buttonTappedDuringAutoSequence:(GAControlerSequencedButtonView*)sequenceButtonView;

@optional
/**
 Informs the delegate when the animation duration is started.
 */
- (void)sequenceButtonViewDidManuallyStart:(GAControlerSequencedButtonView*)sequenceButtonView;
/**
 Informs the delegate when the animation duration is stopped.
 */
- (void)sequenceButtonViewDidManuallyStop:(GAControlerSequencedButtonView*)sequenceButtonView;
@end

@interface GAControlerSequencedButtonView : UIView{
	IBOutlet UIImageView					*_backgroundSequenceImage;
	IBOutlet UIButton						*_button;

	BOOL									_isInAutoSequenceMode;
}

@property (nonatomic, weak) NSObject<BTVSequenceButtonViewDelegate> *delegate;
- (IBAction)buttonTouchDown:(id)sender;
- (IBAction)buttonTouchUp:(id)sender;
- (IBAction)buttonTouchCancelled:(id)sender;

//Automatic sequence
- (void)startAutomaticSequence;
- (void)stopAutomaticSequence;

//Manual sequence
- (void)stopSequence;
- (void)startSequence;
- (void)manualSequenceEnded;
@end
