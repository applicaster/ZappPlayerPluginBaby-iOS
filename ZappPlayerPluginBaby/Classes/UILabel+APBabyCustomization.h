//
//  UILabel+UILabel___Customization.h
//  ModularAppSDK
//
//  Created by reuven levitsky on 2/5/14.
//  Copyright (c) 2014 Applicaster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (APBabyCustomization)

- (void)setLabelStyleForKey:(NSString *)labelKey;
- (void)setLabelStyleForKey:(NSString *)labelKey shouldUseMultiplerConverter:(BOOL)shouldUseMultiplerConverter;
@end
