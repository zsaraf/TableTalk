//
//  ViewController.m
//  Simple Server Mess Around
//
//  Created by Zachary Waleed Saraf on 9/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SocketIOPacket.h"
#include <FacebookSDK/FacebookSDK.h>
#include "TableTalkUtil.h"
#include "WaitForStartViewController.h"
#import "BlurUtils.h"

@interface MainMenuViewController ()

@property (nonatomic, strong) SocketIO *socketIO;
@property (nonatomic, strong) NSMutableArray *friendIds;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIImageView *bckgdImageView;
@property (nonatomic, strong) UIImageView *blurredBckgdImageView;

@end

@implementation MainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager =[[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager startUpdatingLocation];
    
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            [[PFUser currentUser] setObject:userData forKey:@"profile"];
            [[PFUser currentUser] setObject:userData[@"id"] forKey:@"fbId"];
            [[PFUser currentUser] saveInBackground];
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            NSString *relationship = userData[@"relationship_status"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSLog(@"%@", facebookID);
            NSLog(@"%@", name);
            NSLog(@"%@", location);
            NSLog(@"%@", gender);
            NSLog(@"%@", birthday);
            NSLog(@"%@", relationship);
            NSLog(@"%@", pictureURL);
            // Now add the data to the UI elements
            // ...
        }
    }];
    
    // Issue a Facebook Graph API request to get your user's friend list
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            self.friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [self.friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            NSLog(@"NUM FRIENDS: %d", self.friendIds.count);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.friendIds forKey:@"friendIds"];
            /*// Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"fbId" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            NSArray *friendUsers = [friendQuery findObjects];*/
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *img = [UIImage imageNamed:@"NewFriendsTablefeb25th.jpg"];
    self.bckgdImageView = [[UIImageView alloc] initWithImage:img];
    UIImage *blurredImg = [BlurUtils drawBlur:self.bckgdImageView size:self.view.bounds.size withBlurEffect:BlurUtilsExtraLightEffect];
    self.blurredBckgdImageView = [[UIImageView alloc] initWithImage:blurredImg];
    [self.blurredBckgdImageView setAlpha:0];
    [self.view addSubview:self.blurredBckgdImageView];
    [self.view addSubview:self.bckgdImageView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    [button setBackgroundImage:[UIImage imageNamed:@"TableTalkButton.png"] forState:UIControlStateNormal];
    [button setCenter:CGPointMake(self.view.frame.size.width/2, 3.5*self.view.frame.size.height/4)];
    [button setAlpha:0.];
    [button addTarget:self action:@selector(goButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 100)];
    [label setText:@"Table Talk"];
    [label setFont:[UIFont fontWithName:@"Futura-Medium" size:40]];
    [label setTextColor:[UIColor whiteColor]];
    [label setAlpha:0];
    [label setTextAlignment:NSTextAlignmentCenter];
    [UIView animateWithDuration:1 animations:^{
        CGFloat offset = self.bckgdImageView.frame.size.width - self.view.frame.size.width;
        CGRect frame = self.bckgdImageView.frame;
        [self.bckgdImageView setFrame:CGRectOffset(frame, -1 * offset, 0)];
        [self.blurredBckgdImageView setFrame:CGRectOffset(frame, -1 * offset, 0)];
    } completion:^(BOOL finished) {
        [self.view bringSubviewToFront:self.blurredBckgdImageView];
        [self.view addSubview:button];
        [self.view addSubview:label];
        [UIView animateWithDuration:.6 animations:^{
            [self.blurredBckgdImageView setAlpha:.6];
            [button setAlpha:1.];
            [label setAlpha:1.];
        }];
    }];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"updating locations");
}

-(IBAction)goButtonPressed:(id)sender
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            [PFCloud callFunctionInBackground:@"findNearestGameOrMake"
                               withParameters:[NSDictionary dictionaryWithObjectsAndKeys:geoPoint, @"location", nil]
                                        block:^(id object, NSError *error) {
                                            NSLog(@"%@ %@", object, error);
                                            [TableTalkUtil appDelegate].socket = [[SocketUtil alloc] initWithDelegate:self andGroupId:object];
                                        }];
        }
    }];
}

-(void)socketDidConnect
{
    WaitForStartViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"waitForStartViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
