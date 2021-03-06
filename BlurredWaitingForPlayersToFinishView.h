//
//  BlurredWaitingForPlayersToFinishView.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 11/12/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

@interface BlurredWaitingForPlayersToFinishView : UIView

-(id)initWithFrame:(CGRect)frame player:(Player *)player;
-(void)changeToEnabledStateWithAnimation:(BOOL)animated;

@property (nonatomic, weak) Player *player;

@end
