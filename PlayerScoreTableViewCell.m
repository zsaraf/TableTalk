//
//  PlayerScoreTableViewCell.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/18/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "PlayerScoreTableViewCell.h"

@implementation PlayerScoreTableViewCell
@synthesize player = _player;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat imageHorizontalPadding = 20;
        CGFloat imageVerticalPadding = 2;
        self.blurbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageHorizontalPadding, imageVerticalPadding, self.bounds.size.height - 2 * imageVerticalPadding, self.frame.size.height - 2 * imageVerticalPadding)];
        [self.blurbImageView setClipsToBounds:YES];
        self.blurbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.blurbImageView.layer.borderWidth = 1;
        
        [self addSubview:self.blurbImageView];
        self.blurbImageView.layer.cornerRadius = self.blurbImageView.frame.size.height/2;
        
        UIFont *scoreFont = [UIFont fontWithName:@"Futura-Medium" size:20];
        self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.height - imageHorizontalPadding/2, 0, self.frame.size.height, self.frame.size.height)];
        [self.scoreLabel setFont:scoreFont];
        [self.scoreLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.scoreLabel];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.blurbImageView.frame.size.width + imageHorizontalPadding, 0, self.frame.size.width - self.blurbImageView.frame.size.width - self.scoreLabel.frame.size.width - 1.5* imageHorizontalPadding, self.frame.size.height)];
        [self.nameLabel setFont:scoreFont];
        [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.nameLabel];
    }
    return self;
}

-(void)setTextColor:(UIColor *)textColor
{
    [self.nameLabel setTextColor:textColor];
    [self.scoreLabel setTextColor:textColor];
}

-(void)setPlayer:(Player *)player
{
    [self setPlayer:player isWinningPlayer:NO];
}

-(void)setPlayer:(Player *)player isWinningPlayer:(BOOL)isWinningPlayer;
{
    _player = player;
    NSLog(@"%@",player.name);
    [self.blurbImageView setImage:_player.image];
    [self.scoreLabel setText:[NSString stringWithFormat:@"%ld", (long)_player.score]];
    [self.nameLabel setText:_player.name];
    if (isWinningPlayer) {
        [self setBackgroundColor:[UIColor colorWithRed:46/255. green:204/255. blue:113/255. alpha:1.]];
        // rgb(46, 204, 113)
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }
}

-(Player *)player {return _player;}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
