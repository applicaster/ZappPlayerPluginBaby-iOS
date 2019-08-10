//
//  UILabel+UILabel___Customization.m
//  ModularAppSDK
//
//  Created by reuven levitsky on 2/5/14.
//  Copyright (c) 2014 Applicaster. All rights reserved.
//

#import "UILabel+APBabyCustomization.h"
#import "ZPUICustomizationHelper.h"

@implementation UILabel (APBabyCustomization)

- (void)setLabelStyleForKey:(NSString *)labelKey{
    [self setLabelStyleForKey:labelKey shouldUseMultiplerConverter:NO];
}

- (void)setLabelStyleForKey:(NSString *)labelKey shouldUseMultiplerConverter:(BOOL)shouldUseMultiplerConverter {
    GALabelStyle *labelStyle = [ZPUICustomizationHelper labelStyleForKey:labelKey
                                             shouldUseMultiplerConverter:shouldUseMultiplerConverter];
    self.font = labelStyle.font;
    self.textColor = labelStyle.color;
}

@end
