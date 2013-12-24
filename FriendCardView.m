//
//  FriendCardScrollView.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/29/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "FriendCardView.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Crop.h"
#import "SDWebImageManager.h"
#import "BlurUtils.h"

@interface FriendCardView ()

@property (nonatomic, strong) NSURLConnection *linkConnection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) BOOL isLast;
@property (nonatomic, strong) UIView *transparentNameView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation FriendCardView

@synthesize labelHeight = _labelHeight;
@synthesize blurredImageViewAlpha = _blurredImageViewAlpha;

- (id)initWithFrame:(CGRect)frame
{
    //NSAssert(0, @"dont use this");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame card:(Card *)card andIndex:(NSInteger)index isLast:(BOOL)isLast
{
    if (self = [super initWithFrame:frame])
    {
        self.clipsToBounds = YES;
        self.data = [[NSMutableData alloc] init];
        self.card = card;
        
        self.index = index;
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2* self.blurredImageViewAlpha, self.frame.size.width, self.frame.size.height)];
        [self.imgView setContentMode:UIViewContentModeScaleToFill];
        [self.imgView setImage:self.card.image];
        [self addSubview:self.imgView];
        
        UIImage *img = [BlurUtils drawBlur:self.imgView size:self.bounds.size withBlurEffect:BlurUtilsLightEffect];
        self.isLast = isLast;
        
        CGRect labelWrapperFrame = CGRectMake(0, self.frame.size.height - self.labelHeight, self.frame.size.width, self.labelHeight);
        
        self.transparentNameView = [[UIView alloc] initWithFrame:labelWrapperFrame];
        [self.transparentNameView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.3]];
        [self.transparentNameView setAlpha:1.];
        [self addSubview:self.transparentNameView];
        
        self.blurredImageViewWrapper = [[UIView alloc] initWithFrame:labelWrapperFrame];
        [self.blurredImageViewWrapper setClipsToBounds:YES];
        [self addSubview:self.blurredImageViewWrapper];
        
        self.blurredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -self.frame.size.height + self.frame.size.height/2* self.blurredImageViewAlpha + self.labelHeight, self.frame.size.width, self.frame.size.height)];
        [self.blurredImageViewWrapper addSubview:self.blurredImageView];
        
        
        CGRect labelFrame = self.nameLabel.frame;
        labelFrame.origin.y = self.frame.size.height - self.labelHeight;
        labelFrame.origin.x = (1 - self.blurredImageViewAlpha) * (self.frame.size.width - labelFrame.size.width);
        
        self.nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self.nameLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self fixNameLabelSizeForName];
        [self.nameLabel setTextColor:[UIColor whiteColor]];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setText:self.card.name];
        [self insertSubview:self.nameLabel aboveSubview:self.transparentNameView];
        
        [self.blurredImageView setImage:img];
        
    }
    return self;
}



-(void)fixNameLabelSizeForName
{
    if (self.nameLabel == nil || [self.card.name isEqualToString:@""]) {
        return;
    }
    
    CGSize size = [self.card.name sizeWithAttributes:@{NSFontAttributeName:self.nameLabel.font}];
    [self.nameLabel setFrame:CGRectMake((1 -self.blurredImageViewAlpha) * (self.frame.size.width - size.width), self.frame.size.height - self.labelHeight, size.width, self.labelHeight)];
    [self.nameLabel setText:self.card.name];
}

-(void)correctLabelViews
{
    CGRect frame = CGRectMake(0, self.frame.size.height - self.labelHeight, self.frame.size.width, self.labelHeight);
    [self.transparentNameView setFrame:frame];
    [self.blurredImageView setFrame:CGRectMake(0, -self.frame.size.height + self.frame.size.height/2* self.blurredImageViewAlpha + self.labelHeight, self.frame.size.width, self.frame.size.height)];
    [self.blurredImageViewWrapper setFrame:frame];
    
    CGRect labelFrame = self.nameLabel.frame;
    labelFrame.origin.y = self.frame.size.height - self.labelHeight;
    labelFrame.origin.x = (1 - self.blurredImageViewAlpha) * (self.frame.size.width - labelFrame.size.width);
    [self.nameLabel setFrame:labelFrame];
    
}

-(void)setLabelHeight:(CGFloat)labelHeight
{
    _labelHeight = labelHeight;
    [self fixNameLabelSizeForName];
    [self correctLabelViews];
}

-(void)setBlurredImageViewAlpha:(CGFloat)blurredImageViewAlpha
{
    _blurredImageViewAlpha = blurredImageViewAlpha;
    if (!self.blurredImageView || !self.imgView || CGSizeEqualToSize(self.bounds.size, CGSizeZero)) return;
    [self.blurredImageViewWrapper setAlpha:blurredImageViewAlpha];
    [self.imgView setFrame:CGRectMake(0, self.frame.size.height/2* blurredImageViewAlpha, self.frame.size.width, self.frame.size.height)];
    [self.blurredImageView setFrame:CGRectMake(0, -self.frame.size.height + self.frame.size.height/2* blurredImageViewAlpha + self.labelHeight, self.frame.size.width, self.frame.size.height)];
    if (blurredImageViewAlpha == 0) {
        [self bringSubviewToFront:self.nameLabel];
    }
    
    CGRect labelFrame = self.nameLabel.frame;
    labelFrame.origin.x = (1 - self.blurredImageViewAlpha) * (self.frame.size.width - labelFrame.size.width);
    [self.nameLabel setFrame:labelFrame];
}

@end
