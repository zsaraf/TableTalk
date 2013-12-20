//
//  ViewController.h
//  Simple Server Mess Around
//
//  Created by Zachary Waleed Saraf on 9/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "TableTalkUtil.h"
#import "Player.h"
#import "Card.h"

@interface MainMenuViewController : UIViewController <SocketUtilDelegate, CLLocationManagerDelegate, PlayerDelegate, CardDelegate>

@property (nonatomic, weak) IBOutlet UITextField *groupID;
@property (nonatomic, strong) UIButton *goButton;

@end
