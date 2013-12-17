//
//  JudgeChoosingWinnerPhotoScrollView.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "JudgeChoosingWinnerPhotoScrollView.h"
#import "Choice.h"

#define SIZE_OF_LABEL 40

@interface JudgeChoosingWinnerPhotoScrollView ()

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation JudgeChoosingWinnerPhotoScrollView

-(id)initWithFrame:(CGRect)frame choices:(NSArray *)choices
{
    if (self = [super initWithFrame:frame]) {
        self.choices = choices;
        self.imageViews = [[NSMutableArray alloc] init];
        self.labels = [[NSMutableArray alloc] init];
        int counter = 0;
        self.scrollEnabled = YES;
        self.delegate = self;
        self.contentSize = CGSizeMake(self.frame.size.width, self.choices.count * (SIZE_OF_LABEL + self.frame.size.width));
        for (Choice *choice in self.choices) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, counter *(SIZE_OF_LABEL + self.frame.size.width), self.frame.size.width, SIZE_OF_LABEL)];
            [label setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.9]];
            [label setText:choice.name];
            [label setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
            [self addSubview:label];
            
            UIView *v = [[UIView alloc] initWithFrame:label.frame];
            [v setBackgroundColor:[UIColor whiteColor]];
            [self addSubview:v];
            
            [self.labels addObject:label];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, SIZE_OF_LABEL + counter *(SIZE_OF_LABEL + self.frame.size.width), self.frame.size.width, self.frame.size.width)];
            [imgView setImage:choice.image];
            [self addSubview:imgView];
            [self.imageViews addObject:imgView];
            counter ++;
        }
        for (UILabel *label in self.labels) {
            [self bringSubviewToFront:label];
        }
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat contentOffsetY = self.contentOffset.y;
    NSInteger currentPage = floor(contentOffsetY/(self.frame.size.width + SIZE_OF_LABEL));
    
    if (currentPage < 0) {
        return;
    }
    
    CGFloat mod = fmodf(contentOffsetY, (self.frame.size.width + SIZE_OF_LABEL));
    
    CGFloat diff = self.frame.size.width + SIZE_OF_LABEL - mod;
    if (diff < SIZE_OF_LABEL) {
        UILabel *nextLabel = [self.labels objectAtIndex:currentPage + 1];
        
        // correct current label to be directly above nextLabel (to handle this being called infrequently)
        UILabel *currentLabel = [self.labels objectAtIndex:currentPage];
        [currentLabel setCenter:CGPointMake(self.frame.size.width/2, nextLabel.frame.origin.y - SIZE_OF_LABEL/2)];
        return;
    } else if (diff < SIZE_OF_LABEL + 10) {
        for (int i = 0; i < self.labels.count; i++) {
            UILabel *label = [self.labels objectAtIndex:i];
            if (i == currentPage - 1) {
                [label setCenter:CGPointMake(self.frame.size.width/2, (currentPage) * (self.frame.size.width + SIZE_OF_LABEL) - SIZE_OF_LABEL/2)];
            } else if (i != currentPage) {
                [label setCenter:CGPointMake(self.frame.size.width/2, i * (self.frame.size.width + SIZE_OF_LABEL) + SIZE_OF_LABEL/2)];
            }
        }
    }
    UILabel *label = [self.labels objectAtIndex:currentPage];
    [label setCenter:CGPointMake(self.frame.size.width/2, contentOffsetY + SIZE_OF_LABEL/2)];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*CGFloat contentOffsetY = MIN(MAX(0, scrollView.contentOffset.y), (self.frame.size.width + SIZE_OF_LABEL) * self.choices.count);
    NSInteger currentPage = floor(contentOffsetY/(self.frame.size.width + SIZE_OF_LABEL));
    CGFloat mod = fmodf(contentOffsetY, (self.frame.size.width + SIZE_OF_LABEL));
    if (self.frame.size.width + SIZE_OF_LABEL - mod < SIZE_OF_LABEL) {
        
    } else if (currentPage != self.currentPage && currentPage != 0) {
        self.currentPage = currentPage;
        UILabel *aboveLabel = [self.labels objectAtIndex:currentPage - 1];
        [aboveLabel setCenter:CGPointMake(self.frame.size.width/2, (self.frame.size.width + SIZE_OF_LABEL) * currentPage - SIZE_OF_LABEL/2)];
    }
    UILabel *label = [self.labels objectAtIndex:currentPage];
    [label setCenter:CGPointMake(self.frame.size.width/2, scrollView.contentOffset.y + SIZE_OF_LABEL/2)];*/
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
