//
//  ZPUICustomizationHelper.m
//  ModularAppSDK
//
//  Created by reuven levitsky on 2/4/14.
//  Copyright (c) 2014 Applicaster. All rights reserved.
//

#import "ZPUICustomizationHelper.h"
#import "APCustomPlayerResourceHelper.h"

@import ApplicasterSDK;
@import ZappPlugins;

static NSString *kUICustomizationPlistFileName = @"GAUICustomization";

static NSString *kiPhoneKey = @"iphone";
static NSString *kiPadKey = @"ipad";

static NSString *kCustomizationFontNameKey = @"fontname";
static NSString *kCustomizationFontSizeKey = @"fontsize";
static NSString *kCustomizationMinFontSizeKey = @"minScaleFactor";
static NSString *kCustomizationFontColorKey = @"fontcolor";

//static NSString *kCustomizationPlistFileName = @"GACustomization";

@implementation GALabelStyle

- (NSString *)description {
    NSMutableString *description = [NSMutableString new];
    [description appendFormat:@"Font name: %@\n", self.font.fontName];
    [description appendFormat:@"Font size: %f\n", self.font.pointSize];
    [description appendFormat:@"Font color: %@", self.color];
    return description;
}

@end

@implementation ZPUICustomizationHelper

static NSDictionary *customizationPlist;

+ (void)initialize{
    [super initialize];
    
    
    NSBundle *customizationBundle = [APCustomPlayerResourceHelper bundleForResourceNamed:kUICustomizationPlistFileName
                                                                                         ofType:@"plist"];
    customizationPlist = [NSMutableDictionary dictionaryWithContentsOfFile:[customizationBundle pathForResource:kUICustomizationPlistFileName
                                                                                                           ofType:@"plist"]];
}

+ (UIColor *)colorForKey:(NSString *)colorKey{
    UIColor *returnColor;
    id colorValue = [customizationPlist objectForKey:colorKey];

    if(colorValue != nil){
        if([colorValue isKindOfClass:[NSDictionary class]]){
            returnColor = [UIColor colorWithRGBAHexString:[colorValue objectForKey:(IS_IPAD() ? kiPadKey : kiPhoneKey)]];
        }
        else{
            returnColor = [UIColor colorWithRGBAHexString:colorValue];
        }
    }
    else{
        returnColor = [UIColor blackColor];
    }
    
    return returnColor;
}

+ (GALabelStyle *)labelStyleForKey:(NSString *)labelKey {
    return [self labelStyleForKey:labelKey shouldUseMultiplerConverter:NO];
}

+ (GALabelStyle *)labelStyleForKey:(NSString *)labelKey
       shouldUseMultiplerConverter:(BOOL)shouldUseMultiplerConverter {
    GALabelStyle *returnStyle = [GALabelStyle new];
    
    NSString *fontName = [self fontNameForKey:labelKey];
    CGFloat fontSize = [self fontSizeForKey:labelKey];
    
    if (shouldUseMultiplerConverter) {
        fontSize =  roundf([APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:fontSize]);
    }
    UIColor *colorHex = [self fontColorForKey:labelKey];
    
    UIFont *font = [UIFont fontWithName:fontName
                                   size:fontSize];
    
    returnStyle.minimumScaleFactor = [self fontMinimumScaleFactor:labelKey];
    returnStyle.font = font;
    returnStyle.color = colorHex;
    
    return returnStyle;
}

+ (NSString *)fontNameForKey:(NSString *)labelKey{
    NSString *fontName;
    
    NSString *fontnameKeyPath = [NSString stringWithFormat:@"%@.%@", labelKey, kCustomizationFontNameKey];
    id fontNameValue = nil;
    if ([[customizationPlist valueForKeyPath:labelKey] isKindOfClass:[NSDictionary class]]) {
        fontNameValue = [customizationPlist valueForKeyPath:fontnameKeyPath];
    }
    
    if(fontNameValue != nil){
        if([fontNameValue isKindOfClass:[NSDictionary class]]){
            fontName = [fontNameValue objectForKey:(IS_IPAD() ? kiPadKey : kiPhoneKey)];
        }
        else{
            fontName = fontNameValue;
        }
    }
    else{
        fontName = [UIFont systemFontOfSize:[UIFont systemFontSize]].fontName;
    }
    return fontName;
}

+ (CGFloat)fontSizeForKey:(NSString *)labelKey{
    CGFloat fontSize;
    
    NSString *fontsizeKeyPath = [NSString stringWithFormat:@"%@.%@", labelKey, kCustomizationFontSizeKey];
    id fontSizeValue = nil;
    if ([[customizationPlist valueForKeyPath:labelKey] isKindOfClass:[NSDictionary class]]) {
        fontSizeValue = [customizationPlist valueForKeyPath:fontsizeKeyPath];
    }
    
    if(fontSizeValue != nil){
        if([fontSizeValue isKindOfClass:[NSDictionary class]]){
            fontSize = [[fontSizeValue objectForKey:(IS_IPAD() ? kiPadKey : kiPhoneKey)] floatValue];
        }
        else{
            fontSize = [fontSizeValue floatValue];
        }
    }
    else {
        fontSize = [UIFont systemFontSize];
    }
    return fontSize;
}

+ (CGFloat)fontMinimumScaleFactor:(NSString *)labelKey {
    CGFloat minimumScaleFactor = 1;
    
    NSString *minScaleFactorKeyPath = [NSString stringWithFormat:@"%@.%@", labelKey, kCustomizationMinFontSizeKey];
    id minScaleFactorValue = nil;
    if ([[customizationPlist valueForKeyPath:labelKey] isKindOfClass:[NSDictionary class]]) {
        minScaleFactorValue = [customizationPlist valueForKeyPath:minScaleFactorKeyPath];
    }
    
    if(minScaleFactorValue != nil){
        if([minScaleFactorValue isKindOfClass:[NSDictionary class]]){
            minimumScaleFactor = [[minScaleFactorValue objectForKey:(IS_IPAD() ? kiPadKey : kiPhoneKey)] floatValue];
        }
        else{
            minimumScaleFactor = [minScaleFactorValue floatValue];
        }
    }
 
    return minimumScaleFactor;
}

+ (UIColor *)fontColorForKey:(NSString *)labelKey{
    UIColor *fontColor;
    
    NSString *fontcolorKeyPath = [NSString stringWithFormat:@"%@.%@", labelKey, kCustomizationFontColorKey];
    id fontColorValue = nil;
    if ([[customizationPlist valueForKeyPath:labelKey] isKindOfClass:[NSDictionary class]]) {
        fontColorValue = [customizationPlist valueForKeyPath:fontcolorKeyPath];
    }
    
    if(fontColorValue != nil){
        if([fontColorValue isKindOfClass:[NSDictionary class]]){
            fontColor = [UIColor colorWithRGBAHexString:[fontColorValue objectForKey:(IS_IPAD() ? kiPadKey : kiPhoneKey)]];
        }
        else{
            fontColor = [UIColor colorWithRGBAHexString:fontColorValue];
        }
    }
    else{
        return [UIColor blackColor];
    }
    return fontColor;
}

+ (CGFloat)sizeForKey:(NSString *)key defaultSize:(CGFloat)defaultSize {
    CGFloat result = defaultSize;
    
    id value = [customizationPlist valueForKey:key];
    if (value != nil) {
        if ([value isKindOfClass:[NSDictionary class]]){
            result = [[value objectForKey:(IS_IPAD() ? kiPadKey : kiPhoneKey)] floatValue];
        }
        else{
            result = [value floatValue];
        }
    }
    
    return result;
}

@end
