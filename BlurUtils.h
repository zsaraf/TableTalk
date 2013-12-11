//
//  BlurUtils.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 11/12/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BlurUtilsLightEffect = 0,
    BlurUtilsExtraLightEffect = 1
} BlurUtilsEffect;

@interface BlurUtils : NSObject

+(UIImage *)drawBlur:(UIImageView *)imgView size:(CGSize)size cropRect:(CGRect)cropRect withBlurEffect:(BlurUtilsEffect)effect;
+(UIImage *)drawBlur:(UIImageView *)imgView size:(CGSize)size withBlurEffect:(BlurUtilsEffect)effect;


@end
