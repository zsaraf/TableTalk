//
//  PlayerJoinedGameView.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "PlayerJoinedGameView.h"
#import <QuartzCore/QuartzCore.h>

@interface PlayerJoinedGameView ()

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) UIImageView *circleImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation PlayerJoinedGameView

- (id)initWithFrame:(CGRect)frame andPlayer:(Player *)player
{
    self = [super initWithFrame:frame];
    if (self) {
        self.player = player;
        self.circleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.height, 0, self.frame.size.height, self.frame.size.height)];
        [self.circleImageView setImage:self.player.image];
        [self.circleImageView setClipsToBounds:YES];
        [self addSubview:self.circleImageView];
        [self.circleImageView setBackgroundColor:[UIColor blackColor]];
        self.circleImageView.layer.cornerRadius = self.frame.size.height/2;
        
        CGFloat padding = 15.0;
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.circleImageView.frame.size.width + padding + self.circleImageView.frame.origin.x, 0, self.frame.size.width - self.circleImageView.frame.size.width - self.circleImageView.frame.origin.x - padding, self.frame.size.height)];
        [self.nameLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self.nameLabel setTextColor:[UIColor whiteColor]];
        [self.nameLabel setText:self.player.name];
        [self addSubview:self.nameLabel];
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
