//
//  SuperlativeCardView.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 11/12/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuperlativeCardView : UIView

-(id)initWithFrame:(CGRect)frame superlative:(NSString *)superlative index:(NSInteger)index;
-(void)setHideAll;
-(void)setShowAll;

-(void)addRoundLabelAndNumFinishedLabelWithFinishedCompetionBlock:(void(^)(void))completionBlock;
-(void)hideRoundAndNumFinishedLabels;
-(void)setNumFinishedLabelTextWithNumFinished:(NSInteger)numFinished;


@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *superlative;

@end
