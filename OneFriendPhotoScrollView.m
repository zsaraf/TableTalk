//
//  OneFriendPhotoScrollView.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/14/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "OneFriendPhotoScrollView.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface OneFriendPhotoScrollView ()

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation OneFriendPhotoScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andPhotoURL:(NSURL *)url
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.imgView setImageWithURL:url usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.imgView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:self.imgView];
        [self.imgView setBackgroundColor:[UIColor blackColor]];
    }
    return self;
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
