//
//  BlurUtils.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 11/12/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "BlurUtils.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Crop.h"

@implementation BlurUtils

+(UIImage *)drawBlur:(UIImageView *)imgView size:(CGSize)size cropRect:(CGRect)cropRect withBlurEffect:(BlurUtilsEffect)effect
{
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    NSLog(@"%f %f", size.width, size.height);
    [imgView drawViewHierarchyInRect:imgView.frame afterScreenUpdates:YES];
    
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage;
    if (effect == BlurUtilsLightEffect) {
        blurredSnapshotImage = [snapshotImage applyLightEffect];
    } else if (effect == BlurUtilsExtraLightEffect) {
        blurredSnapshotImage = [snapshotImage applyLightEffect];
    }
    UIGraphicsEndImageContext();
    blurredSnapshotImage = [blurredSnapshotImage cropFromRect:CGRectMake(cropRect.origin.x * snapshotImage.size.width, cropRect.origin.y *snapshotImage.size.height, cropRect.size.width * snapshotImage.size.width, cropRect.size.height * snapshotImage.size.height)];
    
    return blurredSnapshotImage;
}

+(UIImage *)drawBlur:(UIImageView *)imgView size:(CGSize)size withBlurEffect:(BlurUtilsEffect)effect
{
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    NSLog(@"%f %f", size.width, size.height);
    [imgView drawViewHierarchyInRect:imgView.frame afterScreenUpdates:YES];
    
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage;
    if (effect == BlurUtilsLightEffect) {
        blurredSnapshotImage = [snapshotImage applyLightEffect];
    } else if (effect == BlurUtilsExtraLightEffect) {
        blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
    }
    UIGraphicsEndImageContext();
    
    return blurredSnapshotImage;
}

@end
