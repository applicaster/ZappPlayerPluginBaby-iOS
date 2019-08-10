//
//  APCustomPlayerResourceHelper.m
//  Pods
//
//  Created by Miri on 09/11/2016.
//
//

#import "APCustomPlayerResourceHelper.h"
@import ApplicasterSDK;

@interface APCustomPlayerResourceHelper ()
@property (nonatomic, strong) NSArray *bundlesArray;
@end

@implementation APCustomPlayerResourceHelper

+ (instancetype)sharedManager {
    static APCustomPlayerResourceHelper *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
    
}

+ (NSArray *)bundlesArray {
    NSArray *retVal = [[self sharedManager] bundlesArray];
    if (retVal == nil) {
        retVal = [NSArray arrayWithObject:[NSBundle mainBundle]];
    }
    return retVal;
}

+ (void)setBundelsArray:(NSArray *)bundlesArray {
    if (bundlesArray) {
        APCustomPlayerResourceHelper *resourceHelper = [self sharedManager];
        resourceHelper.bundlesArray = bundlesArray;
    }
}

+ (NSBundle *)defaultBundle{
    return [[self bundlesArray] firstObject];
}

+ (NSBundle *)bundleForNibNamed:(NSString *)nibName
{
    return [self bundleForResourceNamed:nibName
                                 ofType:@"nib"];
}

+ (UIImage *)imageNamed:(NSString *)imageName{
    UIImage *resultImage;
    
    for (NSBundle *bundle in [self bundlesArray]) {
        resultImage = [self imageNamed:imageName
                            fromBundle:bundle];
        if(resultImage != nil){
            break;
        }
    }
    
    return resultImage;
}

+ (UIImage *)imageNamed:(NSString *)imageName
             fromBundle:(NSBundle *)bundle {
    UIImage *image = [UIImage imageNamed:imageName];
    if (image == nil) {
        return [UIImage imageNamed:imageName
                          inBundle:bundle
     compatibleWithTraitCollection:nil];
    }
    return image;
}

+ (NSBundle *)bundleForResourceNamed:(NSString *)resourceName
                              ofType:(NSString *)type{
    NSBundle *resultBundle;
    
    for (NSBundle *bundle in [self bundlesArray]) {
        if ([bundle pathForResource:resourceName ofType:type] != nil) {
            resultBundle = bundle;
            break;
        }
    }
    
    return resultBundle;
}

@end
