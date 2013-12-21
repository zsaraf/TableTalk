//
//  FriendCardScrollView.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/29/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableTalkUtil.h"
#import "Card.h"

@interface FriendCardView : UIView

-(id)initWithFrame:(CGRect)frame card:(Card *)card andIndex:(NSInteger)index isLast:(BOOL)isLast;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIView *blurredImageViewWrapper;
@property (nonatomic, strong) Card *card;
@property (nonatomic, assign) CGFloat labelHeight;
@property (nonatomic, assign) CGFloat blurredImageViewAlpha;

@end
