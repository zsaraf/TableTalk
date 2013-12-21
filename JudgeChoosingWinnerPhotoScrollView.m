//
//  JudgeChoosingWinnerPhotoScrollView.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "JudgeChoosingWinnerPhotoScrollView.h"
#import "Choice.h"
#import "DisplayScoresTableView.h"

#define SIZE_OF_LABEL 44

@interface JudgeChoosingWinnerPhotoScrollView ()

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) NSMutableArray *labelBackgroundViews;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIColor *desiredEndingBackgroundColor;


@property (nonatomic) BOOL hasPickedWinner;

@end

@implementation JudgeChoosingWinnerPhotoScrollView

-(id)initWithFrame:(CGRect)frame
           choices:(NSArray *)choices withDesiredEndingBackgroundColor:(UIColor *)desiredEndingBackgroundColor;
{
    if (self = [super initWithFrame:frame]) {
        self.choices = choices;
        self.imageViews = [[NSMutableArray alloc] init];
        self.labels = [[NSMutableArray alloc] init];
        self.labelBackgroundViews = [[NSMutableArray alloc] init];
        self.desiredEndingBackgroundColor = desiredEndingBackgroundColor;
        int counter = 0;
        self.scrollEnabled = YES;
        self.bounces = NO;
        self.delegate = self;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDoubleTapped:)];
        [tapRecognizer setNumberOfTapsRequired:2];
        [self addGestureRecognizer:tapRecognizer];
        
        self.contentSize = CGSizeMake(self.frame.size.width, self.choices.count * (SIZE_OF_LABEL + self.frame.size.width));
        for (Choice *choice in self.choices) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, counter *(SIZE_OF_LABEL + self.frame.size.width), self.frame.size.width, SIZE_OF_LABEL)];
            [label setBackgroundColor:[UIColor colorWithRed:212/255. green:235/255. blue:247/255. alpha:.9]];
            [label setText:choice.name];
            [label setTextColor:[UIColor colorWithRed:48/255. green:65/255. blue:155/255. alpha:1.]];
            [label setFont:[UIFont fontWithName:@"Futura-Medium" size:25]];
            [self addSubview:label];
            
            UIView *v = [[UIView alloc] initWithFrame:label.frame];
            [v setBackgroundColor:[UIColor colorWithRed:212/255. green:235/255. blue:247/255. alpha:.9]];
            [self addSubview:v];
            [self.labelBackgroundViews addObject:v];
            
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

-(IBAction)viewDoubleTapped:(UITapGestureRecognizer *)sender
{
    self.hasPickedWinner = YES;
    
    CGPoint location = [sender locationInView:self];
    NSInteger cardTapped = location.y / (SIZE_OF_LABEL + self.frame.size.width);
    NSLog(@"card tapped %ld", (long)cardTapped);
    NSLog(@"niiice");
    [self setScrollEnabled:NO];
    [sender setEnabled:NO];
    
    self.backgroundColor = self.desiredEndingBackgroundColor;
    
    [UIView animateWithDuration:.5 animations:^{
        for (int i  = 0; i < self.imageViews.count; i++) {
            if (i != cardTapped) {
                UIImageView *imgView = [self.imageViews objectAtIndex:i];
                [imgView setAlpha:0];
            }
        }
        for (UILabel *label in self.labels) {
            [label setAlpha:0];
        }
        for (UIView *view in self.labelBackgroundViews) {
            [view setAlpha:0];
        }
    } completion:^(BOOL finished) {
        UIImageView *winnerImgView = [self.imageViews objectAtIndex:cardTapped];
        CGFloat offsetY = self.contentOffset.y;
        CGFloat padding = 44;
 
        Choice *winningChoice = [self.choices objectAtIndex:cardTapped];
        Player *player = [[TableTalkUtil instance].players objectForKey:winningChoice.chosenByFbId];
        player.score ++;
        
        CGFloat newSquareWidth = self.frame.size.width - 2 *padding;
        
        // SCORES label
        UILabel *scoresLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY + newSquareWidth + padding, self.frame.size.width, 44)];
        [scoresLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:24]];
        [scoresLabel setTextColor:[UIColor whiteColor]];
        [scoresLabel setText:@"SCORE"];
        [scoresLabel setTextAlignment:NSTextAlignmentCenter];
        [scoresLabel setAlpha:0];
        
        /*CALayer *borderLayer = [CALayer layer];
        CGFloat scoresBorderPadding = 5;
        [borderLayer setFrame:CGRectMake(scoresBorderPadding, scoresLabel.layer.frame.size.height - 2, scoresLabel.layer.frame.size.width - 2 * scoresBorderPadding, 2)];
        [borderLayer setBackgroundColor:[[UIColor whiteColor] CGColor]];
        [scoresLabel.layer addSublayer:borderLayer];*/
        
        [self addSubview:scoresLabel];
        
        // scores table view
        DisplayScoresTableView *tv = [[DisplayScoresTableView alloc] initWithFrame:CGRectMake(0, scoresLabel.frame.origin.y + scoresLabel.frame.size.height + 2, self.frame.size.width, self.frame.size.height - newSquareWidth - padding - scoresLabel.frame.size.height - 2) backgroundColor:self.backgroundColor textColor:[UIColor whiteColor] winningPlayer:player];
        [tv setAlpha:0];
        [self addSubview:tv];
        
        // winner label
        UILabel *winnerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY + newSquareWidth, self.frame.size.width, padding)];
        [winnerLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:15]];
        [winnerLabel setText:[NSString stringWithFormat:@"Winner: %@", winningChoice.name]];
        [winnerLabel setTextColor:[UIColor whiteColor]];
        [winnerLabel setTextAlignment:NSTextAlignmentCenter];
        [winnerLabel setAlpha:0];
        [self addSubview:winnerLabel];
        
        
        [UIView animateWithDuration:.5 animations:^{
            [winnerImgView setFrame:CGRectMake(padding, offsetY, newSquareWidth, newSquareWidth)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.5 animations:^{
                [tv setAlpha:1.0];
                [winnerLabel setAlpha:1.0];
                [scoresLabel setAlpha:1.0];
            }];
        }];
        
    }];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.hasPickedWinner) return;
    
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
    } else if (diff < SIZE_OF_LABEL + 10 || diff < self.frame.size.width) {
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
