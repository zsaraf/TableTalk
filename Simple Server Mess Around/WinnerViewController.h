//
//  WinnerViewController.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/23/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableTalkUtil.h"

@interface WinnerViewController : UIViewController <SocketUtilDelegate>

-(id)initWithWinner:(NSString *)winner andSelectedFriend:(NSString *)selectedFriend andShouldSendMessage:(BOOL)shouldSendMessage;

@end
