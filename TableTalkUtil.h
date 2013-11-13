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

#define GRAPH_SEARCH_URL_FORMAT @"https://graph.facebook.com/%@/picture?width=320&height=320&return_ssl_resources=1"

@interface TableTalkUtil : NSObject

+(AppDelegate *)appDelegate;

@end
