//
//  SocketUtil.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/14/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIOPacket.h"
#import "SocketIO.h"

@protocol SocketUtilDelegate <NSObject>

@optional
-(void)socketDidConnect;
-(void)socketDidReceiveEvent:(SocketIOPacket *)packet;

@end

@interface SocketUtil : NSObject <SocketIODelegate>

-(id)initWithDelegate:(id<SocketUtilDelegate>)delegate;
-(void)sendBeginGameMessage;
-(void)sendChoseFriendMessage:(NSString *)friendId;
-(void)sendChoseWinnerMessage:(NSString *)friendId;


@property (nonatomic, strong) id<SocketUtilDelegate> delegate;

@end
