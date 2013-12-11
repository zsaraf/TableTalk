//
//  JudgingSelectorChosenFriendCard.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 11/18/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JudgingSelectorChosenFriendCard : UIView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image playerFacebookId:(NSString *)pFacebookId chosenFacebookId:(NSString *)cFacebookId;

@property (nonatomic, assign) CGFloat blurredImageViewAlpha;

@end
