//
//  SuperlativeCardView.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 11/12/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "SuperlativeCardView.h"

@interface SuperlativeCardView ()

@property (nonatomic, strong) NSString *superlative;
@property (nonatomic, strong) UILabel *superlativeLabel;

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
        UIFont *myFont = [UIFont fontWithName:@"Futura-Medium" size:22];
        CGRect rect = [superlative boundingRectWithSize:CGSizeMake(7*self.frame.size.width/8, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:myFont} context:nil];
        NSLog(@"%f %f %f %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        self.superlativeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/16, self.frame.size.height/2 - rect.size.height/2, 7*self.frame.size.width/8, rect.size.height)];
        [self.superlativeLabel setFont:myFont];
        [self.superlativeLabel setNumberOfLines:0];
        [self.superlativeLabel setText:self.superlative];
        [self.superlativeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.superlativeLabel setTextColor:[UIColor whiteColor]];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
