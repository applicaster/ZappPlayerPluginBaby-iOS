//
//  ZPUICustomizationHelper.h
//  ModularAppSDK
//
//  Created by reuven levitsky on 2/4/14.
//  Copyright (c) 2014 Applicaster. All rights reserved.
//

@import UIKit;

@interface GALabelStyle : NSObject

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CGFloat minimumScaleFactor;
@end

@interface ZPUICustomizationHelper : NSObject

+ (UIColor *)colorForKey:(NSString *)colorKey;
+ (CGFloat)sizeForKey:(NSString *)key defaultSize:(CGFloat)defaultSize;

+ (GALabelStyle *)labelStyleForKey:(NSString *)labelKey;
+ (GALabelStyle *)labelStyleForKey:(NSString *)labelKey
       shouldUseMultiplerConverter:(BOOL)shouldUseMultiplerConverter;

@end
