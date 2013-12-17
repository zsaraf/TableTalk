//
//  Player.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/15/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Player;

@protocol PlayerDelegate

-(void)playerDidFinishDownloadingImageAndName:(Player *)player;

@end

@interface Player : NSObject

-(id)initWithFbId:(NSString *)fbId;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fbId;
@property (nonatomic, weak) id<PlayerDelegate> delegate;

@end
