//
//  BlurredWaitingForPlayersToFinishView.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 11/12/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "BlurredWaitingForPlayersToFinishView.h"
#import "UIImage+Crop.h"
#import "BlurUtils.h"

@interface BlurredWaitingForPlayersToFinishView ()

@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) UIImage *blurredImg;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIImageView *blurredImgView;

@end

@implementation BlurredWaitingForPlayersToFinishView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame image:(UIImage *)img facebookID:(NSString *)facebookID
{
    if (self = [super initWithFrame:frame]) {
        self.img = img;
        self.facebookID = facebookID;
        CGFloat cropHeight = self.frame.size.height*(img.size.width/self.frame.size.width);
        self.img = [img cropFromRect:CGRectMake(0, img.size.height/2 - cropHeight/2, img.size.width, cropHeight)];
        self.imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.imgView setImage:self.img];
        self.blurredImg = [BlurUtils drawBlur:self.imgView size:self.bounds.size cropRect:CGRectMake(0, 0, 1, 1)];
        self.blurredImgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.blurredImgView setImage:self.blurredImg];
        [self addSubview:self.blurredImgView];
        [self addSubview:self.imgView];
        UIView *blueView = [[UIView alloc] initWithFrame:self.bounds];
        [blueView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1. alpha:.1]];
        [self addSubview:blueView];
        [self bringSubviewToFront:self.blurredImgView];
    }
    return self;
}

-(void)changeToEnabledStateWithAnimation:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            [self.blurredImgView setAlpha:0.];
        }];
    } else {
        [self.blurredImgView setAlpha:0.];
    }
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
