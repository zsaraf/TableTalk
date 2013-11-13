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

@interface MainMenuViewController ()

@property (nonatomic, strong) SocketIO *socketIO;
@property (nonatomic, strong) NSMutableArray *friendIds;
@property (nonatomic, strong) CLLocationManager *locationManager;

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
            NSLog(@"stored");
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

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"updating locations");
}

-(IBAction)goButtonPressed:(id)sender
{
    [TableTalkUtil appDelegate].socket = [[SocketUtil alloc] initWithDelegate:self];
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
