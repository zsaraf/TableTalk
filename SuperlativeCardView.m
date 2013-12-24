//
//  SuperlativeCardView.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 11/12/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "SuperlativeCardView.h"
#import "TableTalkUtil.h"

@interface SuperlativeCardView ()

@property (nonatomic, strong) UILabel *superlativeLabel;

// only if picked superlative
@property (nonatomic, strong) UILabel *roundLabel;
@property (nonatomic, strong) UILabel *numFinishedLabel;

@end

@implementation SuperlativeCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame superlative:(NSString *)superlative index:(NSInteger)index
{
    if (self = [super initWithFrame:frame]) {
        self.superlative = superlative;
        //CGSize size = [superlative sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
        UIFont *myFont = [UIFont fontWithName:@"Futura-Medium" size:20];
//        self.superlativeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/16, self.frame.size.height/2 - rect.size.height/2, 7*self.frame.size.width/8, rect.size.height)];
        self.superlativeLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self.superlativeLabel setFont:myFont];
        [self.superlativeLabel setNumberOfLines:0];
        [self.superlativeLabel setText:self.superlative];
        [self.superlativeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.superlativeLabel setTextColor:[UIColor whiteColor]];
        [self.superlativeLabel drawTextInRect:UIEdgeInsetsInsetRect(self.superlativeLabel.bounds, UIEdgeInsetsMake(0, 20, 0, 20))];
        [self.superlativeLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:self.superlativeLabel];
        
        self.index = index;
        
    }
    return self;
}

-(void)setHideAll
{
    [self.superlativeLabel setAlpha:0.];
}

-(void)setShowAll
{
    [self.superlativeLabel setAlpha:1.];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.superlativeLabel setFrame:self.bounds];
    
    [self fixRoundLabelToBeOnTopOfSuperlative];
}

-(void)fixRoundLabelToBeOnTopOfSuperlative
{
    if (self.roundLabel == nil) return;
    
    CGSize sizeOfSuperlative = [self.superlativeLabel.text sizeWithAttributes:@{NSFontAttributeName:self.superlativeLabel.font}];
    
    CGFloat padding = 15.;

    // size and font of round label
    CGSize sizeOfRoundLabel = [self.roundLabel.text sizeWithAttributes:@{NSFontAttributeName:self.roundLabel.font}];
    
    [self.roundLabel setFrame:CGRectMake(0, self.frame.size.height/2 - sizeOfSuperlative.height/2 - padding - sizeOfRoundLabel.height, self.frame.size.width, sizeOfRoundLabel.height)];
}

-(void)addRoundLabelAndNumFinishedLabelWithFinishedCompetionBlock:(void(^)(void))completionBlock
{
    NSString *roundString = [NSString stringWithFormat:@"ROUND %u", [TableTalkUtil instance].numRoundsPlayed];
    UIFont *roundFont = [UIFont fontWithName:@"Futura-Medium" size:25];
    
    self.roundLabel = [[UILabel alloc] init];
    [self.roundLabel setText:roundString];
    [self.roundLabel setTextAlignment:NSTextAlignmentCenter];
    [self.roundLabel setFont:roundFont];
    [self fixRoundLabelToBeOnTopOfSuperlative];
    [self.roundLabel setTextColor:[UIColor whiteColor]];
    [self.roundLabel setAlpha:0];
    [self addSubview:self.roundLabel];
    
    self.numFinishedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 64, self.frame.size.width, 64)];
    [self.numFinishedLabel setTextAlignment:NSTextAlignmentCenter];
    [self.numFinishedLabel setTextColor:[UIColor whiteColor]];
    [self.numFinishedLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:15]];
    [self.numFinishedLabel setAlpha:0];
    [self.numFinishedLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
    [self setNumFinishedLabelTextWithNumFinished:0];
    [self addSubview:self.numFinishedLabel];
    
    [UIView animateWithDuration:.5 animations:^{
        [self.numFinishedLabel setAlpha:1.0];
        [self.roundLabel setAlpha:1.0];
    } completion:^(BOOL finished) {
        completionBlock();
    }];
}

-(void)hideRoundAndNumFinishedLabels
{
    [self.roundLabel setAlpha:0];
    [self.numFinishedLabel setAlpha:0];
}

-(void)setNumFinishedLabelTextWithNumFinished:(NSInteger)numFinished
{
    [self.numFinishedLabel setText:[NSString stringWithFormat:@"%u/%d finished", numFinished, [TableTalkUtil instance].players.count]];
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
