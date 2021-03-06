//
//  TableTalkUtil.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/14/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "TableTalkUtil.h"

@implementation TableTalkUtil

+ (id)instance {
    static TableTalkUtil *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [[self alloc] init];
    });
    return inst;
}

-(id)init
{
    if (self = [super init]) {
        self.players = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+(UILabel *)tableTalkLabelWithFrame:(CGRect)frame fontSize:(NSInteger)fontSize text:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"Futura-Medium" size:fontSize]];
    [label setText:text];
    return label;
}

@end
