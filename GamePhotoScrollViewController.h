//
//  GamePhotoScrollViewController.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/14/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableTalkUtil.h"

@interface GamePhotoScrollViewController : UIViewController <UIScrollViewDelegate, SocketUtilDelegate>

-(id)initWithCardFBIds:(NSArray *)fbIDs isJudge:(BOOL)isJudge;

@end
