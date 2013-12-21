//
//  JudgeChoosingWinnerPhotoScrollView.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JudgeChoosingWinnerPhotoScrollView : UIScrollView <UIScrollViewDelegate>

-(id)initWithFrame:(CGRect)frame
           choices:(NSArray *)choices withDesiredEndingBackgroundColor:(UIColor *)desiredEndingBackgroundColor;

@property (nonatomic, strong) NSArray *choices;

@end
