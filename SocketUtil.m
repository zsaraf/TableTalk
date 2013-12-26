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

-(id)initWithDelegate:(id<SocketUtilDelegate>)delegate andGroupId:(NSString *)groupId
{
    self = [super init];
    if (self) {
        self.socketIO = [[SocketIO alloc] initWithDelegate:self];
        self.delegate = delegate;
        self.groupId = groupId;
        [self.socketIO connectToHost:@"54.213.192.50" onPort:80];
        //[self.socketIO connectToHost:@"54.209.180.200" onPort:8080];
    }
    return self;
}

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"connected");
    [self.socketIO sendEvent:@"joinTable" withData:[NSDictionary dictionaryWithObjectsAndKeys: self.groupId, @"groupID", [[NSUserDefaults standardUserDefaults] objectForKey:@"friendIds"], @"friends", [[PFUser currentUser] objectForKey:@"fbId"],@"fbID", nil]];
    if ([self.delegate respondsToSelector:@selector(socketDidConnect)]) {
        [self.delegate socketDidConnect];
    }
}

-(void)sendBeginGameMessageWithSuperlative:(NSString *)superlative
{
    [self.socketIO sendEvent:@"superlative" withData:superlative];
}

-(void)sendReadyToPlayMessage
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

-(void)sendJudgeCurrentlyLookingAtFbId:(NSString *)fbId
{
    [self.socketIO sendEvent:@"currentlyViewing" withData:fbId];
    NSLog(@"sent judge currently looking at fbId");
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
