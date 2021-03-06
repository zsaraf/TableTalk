//
//  TableTalkUtil.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/14/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketUtil.h"
#import "AppDelegate.h"
#import "Player.h"

#define GRAPH_SEARCH_URL_FORMAT @"https://graph.facebook.com/%@/picture?width=640&height=640&return_ssl_resources=1"

@interface TableTalkUtil : NSObject

+(TableTalkUtil *)instance;
+(AppDelegate *)appDelegate;
+(UILabel *)tableTalkLabelWithFrame:(CGRect)frame fontSize:(NSInteger)fontSize text:(NSString *)text;


@property (nonatomic, strong) NSMutableDictionary *players;
@property (nonatomic, strong) Player *me;
@property (nonatomic) NSInteger numRoundsPlayed;

@end
