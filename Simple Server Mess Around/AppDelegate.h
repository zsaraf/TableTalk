//
//  AppDelegate.h
//  Simple Server Mess Around
//
//  Created by Zachary Waleed Saraf on 9/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SocketUtil.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SocketUtil *socket;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end
