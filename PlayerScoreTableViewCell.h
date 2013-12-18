//
//  PlayerScoreTableViewCell.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/18/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

@interface PlayerScoreTableViewCell : UITableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)setTextColor:(UIColor *)textColor;
-(void)setPlayer:(Player *)player isWinningPlayer:(BOOL)isWinningPlayer;

@property (nonatomic, strong) UIImageView *blurbImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) Player *player;

@end
