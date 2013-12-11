//
//  JudgingSelectorChosenFriendCard.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 11/18/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "JudgingSelectorChosenFriendCard.h"
#import "BlurUtils.h"

@interface JudgingSelectorChosenFriendCard ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *pFacebookId;
@property (nonatomic, strong) NSString *cFacebookId;
@property (nonatomic, strong) UIImageView *blurredImageView;

@end

@implementation JudgingSelectorChosenFriendCard

@synthesize blurredImageViewAlpha = _blurredImageViewAlpha;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image playerFacebookId:(NSString *)pFacebookId chosenFacebookId:(NSString *)cFacebookId
{
    if (self = [super initWithFrame:frame]) {
        self.image = image;
        
        // add regular image view
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imgView setImage:self.image];
        
        self.blurredImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        UIImage *blurredImg = [BlurUtils drawBlur:imgView size:self.bounds.size withBlurEffect:BlurUtilsLightEffect];
        [self.blurredImageView setImage:blurredImg];
        
        [self addSubview:imgView];
        [self addSubview:self.blurredImageView];
        self.pFacebookId = pFacebookId;
        self.cFacebookId = cFacebookId;
        NSLog(@"%@", self.subviews);
    }
    return self;
}

-(void)setBlurredImageViewAlpha:(CGFloat)blurredImageViewAlpha
{
    _blurredImageViewAlpha = blurredImageViewAlpha;
    [self.blurredImageView setAlpha:blurredImageViewAlpha];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
