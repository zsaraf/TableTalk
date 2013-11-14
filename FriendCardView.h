//
//  FriendCardScrollView.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/29/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableTalkUtil.h"

@protocol FriendCardViewDelegate

-(void)didFinishLoadingImage:(UIImage *)image forIndex:(NSInteger)index;

@end

@interface FriendCardView : UIView <NSURLConnectionDelegate>

-(id)initWithFBId:(NSString *)fbID andIndex:(NSInteger)index isLast:(BOOL)isLast;

@property (nonatomic, weak) id<FriendCardViewDelegate> delegate;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIView *blurredImageViewWrapper;
@property (nonatomic, strong) NSString *fbID;
@property (nonatomic, assign) CGFloat labelHeight;
@property (nonatomic, assign) CGFloat blurredImageViewAlpha;

@end
