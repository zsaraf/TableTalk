//
//  JudgeViewController.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/18/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableTalkUtil.h"

@interface JudgeViewController : UIViewController <SocketUtilDelegate>

-(id)initWithPlayers:(NSArray *)players superlatives:(NSArray *)superlatives;

@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) NSArray *superlatives;

@end
