//
//  AppDelegate.m
//  Simple Server Mess Around
//
//  Created by Zachary Waleed Saraf on 9/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "GamePhotoScrollViewController.h"
#import "JudgeViewController.h"
#import "DebugViewController.h"
#import "DebugScoresViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"3l5uX1fxPZfceCQ4SbOzgKNlra4DsJnXp7MUXFkE"
                  clientKey:@"89N3YtxLTtcDp8eBMHx2L8xmEGhTU7pGF8k4USpT"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    /*NSArray *players = [NSArray arrayWithObjects:@"521242550",@"521827780",@"524372404",@"524693200",@"524747587", @"588688409", @"1323098301", nil];
    NSArray *superlatives = [NSArray arrayWithObjects:@"Most likely to sleep with a stripper", @"Most likely to laugh at a midget", @"Most likely to twerk at her own wedding", @"Would make the best sandwich under pressure", nil];
    JudgeViewController *vc = [[JudgeViewController alloc] initWithPlayers:players superlatives:superlatives];
    [self.window setRootViewController:vc];*/
    /*NSArray *friendsArray = [NSArray arrayWithObjects:@"521242550",@"521827780",@"524372404",@"524693200",@"524747587", @"588688409", @"1323098301", nil];
    GamePhotoScrollViewController *vc = [[GamePhotoScrollViewController alloc] initWithCardFBIds:friendsArray superlative:@"Great dick."];
    [self.window setRootViewController:vc];*/
    
    //DebugViewController *vc = [[DebugViewController alloc] init];
    //[self.window setRootViewController:vc];
    
    /*DebugScoresViewController *vc = [[DebugScoresViewController alloc] init];
    [self.window setRootViewController:vc];*/
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

@end
