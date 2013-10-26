//
//  SocketUtil.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/14/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "SocketUtil.h"
#import <Parse/Parse.h>

@interface SocketUtil ()

@property (nonatomic, strong) SocketIO *socketIO;

@end

@implementation SocketUtil

-(id)initWithDelegate:(id<SocketUtilDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.socketIO = [[SocketIO alloc] initWithDelegate:self];
        self.delegate = delegate;
        [self.socketIO connectToHost:@"54.213.192.50" onPort:80];
    }
    return self;
}

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"connected");
    
    [self.socketIO sendEvent:@"joinTable" withData:[NSDictionary dictionaryWithObjectsAndKeys: @"prat", @"groupID", [[NSUserDefaults standardUserDefaults] objectForKey:@"friendIds"], @"friends", [[PFUser currentUser] objectForKey:@"fbId"],@"userID", nil]];
    if ([self.delegate respondsToSelector:@selector(socketDidConnect)]) {
        [self.delegate socketDidConnect];
    }
}

-(void)sendBeginGameMessage
{
    [self.socketIO sendEvent:@"startGame" withData:nil];
}


-(void)sendChoseFriendMessage:(NSString *)friendId
{
    [self.socketIO sendEvent:@"didSelectFriend" withData:friendId];
}

-(void)sendChoseWinnerMessage:(NSString *)friendId
{
    [self.socketIO sendEvent:@"winner" withData:friendId];
}

-(void)socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
    NSLog(@"PACKET %@", packet);
}

-(void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"disconnected");
}

-(void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"EVENT: %@", packet.data);
    if ([self.delegate respondsToSelector:@selector(socketDidReceiveEvent:)]) {
        [self.delegate socketDidReceiveEvent:packet];
    }
}


@end
