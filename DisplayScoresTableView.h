//
//  DisplayScoresTableView.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/18/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableTalkUtil.h"

@interface DisplayScoresTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor winningPlayer:(Player *)winningPlayer;

@property (nonatomic, strong) Player *winningPlayer;

@end
