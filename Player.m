//
//  Player.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/15/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "Player.h"

@implementation Player

-(id)initWithFbId:(NSString *)fbId
{
    if (self = [super init]) {
        self.fbId = fbId;
    }
    return self;
}

@end
