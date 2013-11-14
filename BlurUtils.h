//
//  BlurUtils.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 11/12/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlurUtils : NSObject

+(UIImage *)drawBlur:(UIImageView *)imgView size:(CGSize)size cropRect:(CGRect)cropRect;
+(UIImage *)drawBlur:(UIImageView *)imgView size:(CGSize)size;


@end
