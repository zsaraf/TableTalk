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
#import <QuartzCore/QuartzCore.h>
#import "GamePhotoScrollViewController.h"
#import "LoginViewController.h"
#import "JudgeViewController.h"

@interface MainMenuViewController ()

@property (nonatomic, strong) SocketIO *socketIO;
@property (nonatomic, strong) NSMutableArray *friendIds;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIImageView *bckgdImageView;
@property (nonatomic, strong) UIImageView *blurredBckgdImageView;
@property (nonatomic, strong) NSArray *superlatives;
@property (nonatomic, strong) NSMutableArray *playerBlurbs;
@property (nonatomic, strong) UILabel *labelView;
@property (nonatomic) BOOL hasFinishedAnimatingToLookingForGame;

@property (nonatomic, strong) UIButton *readyToPlayButton;

// This is if this player will play, not judge.
@property (nonatomic, strong) NSString *superlative;
@property (nonatomic) NSInteger numCardDataRetrieved;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic) BOOL isReadyToDisplayFriendCards;

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
    
    self.playerBlurbs = [[NSMutableArray alloc] init];
    
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (error) {
            [PFUser logOut];
            
            LoginViewController *lvc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginViewController"];
            [self.navigationController pushViewController:lvc animated:NO];
            
        } else {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            [[PFUser currentUser] setObject:userData forKey:@"profile"];
            [[PFUser currentUser] setObject:userData[@"id"] forKey:@"fbId"];
            [[PFUser currentUser] saveInBackground];
            
            NSString *facebookID = userData[@"id"];
            Player *me = [[Player alloc] initWithFbId:facebookID];
            me.delegate = self;
            [TableTalkUtil instance].me = me;
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
            NSLog(@"NUM FRIENDS: %ld", self.friendIds.count);
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
    self.goButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    [self.goButton setBackgroundImage:[UIImage imageNamed:@"TableTalkButton2.png"] forState:UIControlStateNormal];
    [self.goButton setCenter:CGPointMake(self.view.frame.size.width/2, 3.5*self.view.frame.size.height/4)];
    [self.goButton setAlpha:0.];
    [self.goButton addTarget:self action:@selector(goButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
        [self.view addSubview:self.goButton];
        [self.view addSubview:label];
        [UIView animateWithDuration:.6 animations:^{
            [self.blurredBckgdImageView setAlpha:.6];
            [self.goButton setAlpha:1.];
            [label setAlpha:1.];
        }];
    }];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //NSLog(@"updating locations");
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(IBAction)goButtonPressed:(id)sender
{
    [self.goButton setUserInteractionEnabled:NO];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            [PFCloud callFunctionInBackground:@"findNearestGameOrMake"
                               withParameters:[NSDictionary dictionaryWithObjectsAndKeys:geoPoint, @"location", nil]
                                        block:^(id object, NSError *error) {
                                            NSLog(@"%@ %@", object, error);
                                            [TableTalkUtil appDelegate].socket = [[SocketUtil alloc] initWithDelegate:  self andGroupId:object];
                                        }];
        }
    }];
    
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectOffset(self.view.bounds, 0, 0)];
    // 34495e
    [blueView setBackgroundColor:[UIColor colorWithRed:88/255. green:169/255. blue:220/255. alpha:1.]];//[UIColor colorWithRed:116/255. green:194/255. blue:255/255. alpha:1.]];
    [blueView setAlpha:0.];
    [self.view insertSubview:blueView belowSubview:self.goButton];
    
    [self runSpinAnimationOnView:self.goButton duration:10 rotations:1 repeat:1];
    // create label
    UIFont *font = [UIFont fontWithName:@"Futura-Medium" size:25];
    NSString *labelString = @"Finding game...";
    CGSize size = [labelString sizeWithAttributes:@{NSFontAttributeName:font}];
    CGFloat padding = 15.;
    self.labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, size.height)];
    [self.labelView setFont:font];
    [self.labelView setText:labelString];
    [self.labelView setTextColor:[UIColor whiteColor]];
    [self.labelView setAlpha:0];
    [self.labelView setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.labelView];
    [UIView animateWithDuration:2.5 animations:^{
        [blueView setAlpha:1];
        [self.labelView setAlpha:1.0];
        CGFloat padding = 40;
        [self.goButton setFrame:CGRectMake(padding, self.view.frame.size.height/2 - self.view.frame.size.width/2 + padding, self.view.frame.size.width - 2* padding, self.view.frame.size.width - 2* padding)];
        [self.labelView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height -1 * (padding + self.labelView.frame.size.height/2))];
    } completion:^(BOOL finished) {
        //NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerCalled:) userInfo:Nil repeats:YES];
        self.hasFinishedAnimatingToLookingForGame = YES;
        if (self.playerBlurbs.count != 0) {
            [self reorganizeBlurbsWithCompletionHandler:^{
                for (UIImageView *playerBlurb in self.playerBlurbs) {
                    [self.view bringSubviewToFront:playerBlurb];
                    [UIView animateWithDuration:1 animations:^{
                        [playerBlurb setAlpha:1.0];
                    }];
                }
            }];
        }
    }];
}

-(IBAction)timerCalled:(id)sender
{
    static int counter = 0;
    NSArray *players = [NSArray arrayWithObjects:@"521242550",@"521827780",@"524372404",@"524693200",@"524747587", @"588688409", @"1323098301", nil];
    [self addPlayerToDictionary:[players objectAtIndex:counter]];
    
    
    
    counter ++;
    if (counter == 7) [(NSTimer *)sender invalidate];
}

-(void)socketDidConnect
{
    CATransform3D myTransform = [(CALayer*)[self.goButton.layer presentationLayer] transform];
    CGFloat rotation = atan2(myTransform.m11, myTransform.m12);
    NSLog(@"socket did connect...");
    //WaitForStartViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"waitForStartViewController"];
    //[TableTalkUtil appDelegate].socket.delegate = vc;
    //[self.navigationController pushViewController:vc animated:YES];
}

-(void)addPlayerToDictionary:(NSString *)fbId
{
    Player *player = [[Player alloc] initWithFbId:fbId];
    player.delegate = self;
    [[TableTalkUtil instance].players setObject:player forKey:fbId];
}

-(void)reorganizeBlurbsWithCompletionHandler:(void (^)())block;
{
    [UIView animateWithDuration:.5 animations:^{
        for (int i = 0; i < self.playerBlurbs.count; i++) {
            CGPoint center = CGPointMake(self.goButton.center.x + self.goButton.frame.size.width/2 * cos(i * 2 * M_PI/self.playerBlurbs.count + 3 * M_PI/2), self.goButton.center.y + self.goButton.frame.size.width/2 * sin(i * 2 * M_PI/self.playerBlurbs.count + 3 * M_PI/2));
            [[self.playerBlurbs objectAtIndex:i] setCenter:center];
        }
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
    }];
}

-(void)animateAddingGreenCircleAroundPlayer:(Player *)player
{
    UIImageView *theImgView;
    for (UIImageView *imgView in self.playerBlurbs) {
        if ([imgView.image isEqual:player.image]) {
            theImgView = imgView;
        }
    }
    
    // Set up the shape of the circle
    int radius = theImgView.frame.size.width/2 - 1;
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius].CGPath;
    // Center the shape in self.view
    circle.position = CGPointMake(CGRectGetMidX(theImgView.bounds)-radius,
                                  CGRectGetMidY(theImgView.bounds)-radius);
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor colorWithRed:46/255. green:244/255. blue:113/255. alpha:1.].CGColor;
    circle.lineWidth = 2;
    
    // Add to parent layer
    [theImgView.layer addSublayer:circle];
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 1; // "animate over 10 seconds or so.."
    drawAnimation.repeatCount         = 1.0;  // Animate only once..
    drawAnimation.removedOnCompletion = NO;   // Remain stroked after the animation..
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    
    // Experiment with timing to get the appearence to look the way you want
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // Add the animation to the circle
    [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    
    
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)playerDidFinishDownloadingImageAndName:(Player *)player
{
    static NSInteger counter = 0;
    counter ++;
    if (counter == [TableTalkUtil instance].players.count) {
        NSLog(@"good we can continue with judge");
    }
    
    for (int i = 0; i < self.playerBlurbs.count; i++) {
        UIImageView *playerBlurb = [self.playerBlurbs objectAtIndex:i];
        [playerBlurb.layer removeAllAnimations];
    }
    
    UIImageView *circleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-50, -50, 50, 50)];
    [circleImageView setImage:player.image];
    [circleImageView setClipsToBounds:YES];
    if (!self.hasFinishedAnimatingToLookingForGame) {
        [circleImageView setAlpha:0.];
    }
    [self.view addSubview:circleImageView];
    circleImageView.layer.cornerRadius = circleImageView.frame.size.height/2;
    [self.playerBlurbs addObject:circleImageView];
    
    [self reorganizeBlurbsWithCompletionHandler:nil];
    
    if (counter == 2) {
        self.readyToPlayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 80)];
        UIImage *backgroundImage = [self imageWithColor:[UIColor colorWithRed:46/255. green:204/255. blue:113/255. alpha:1.]];
        UIImage *selectedBackgroundImage = [self imageWithColor:[UIColor colorWithRed:46/255. green:204/255. blue:113/255. alpha:.5]];
        
        [self.readyToPlayButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        [self.readyToPlayButton setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
        [[self.readyToPlayButton titleLabel] setTextColor:[UIColor whiteColor]];
        [[self.readyToPlayButton titleLabel] setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [[self.readyToPlayButton titleLabel] setTextAlignment:NSTextAlignmentCenter];
        [[self.readyToPlayButton titleLabel] setLineBreakMode:NSLineBreakByWordWrapping];
        [self.readyToPlayButton setAlpha:0.];
        [self.readyToPlayButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
        [self.readyToPlayButton setTitle:@"Tap when all of your friends are at the table" forState:UIControlStateNormal];
        [self.readyToPlayButton addTarget:self action:@selector(beginGameButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.readyToPlayButton];
        // rgb(46, 204, 113)
        [UIView animateWithDuration:.5 animations:^{
            [self.labelView setFrame:CGRectOffset(self.labelView.frame, 0, 100)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.5 animations:^{
                [self.readyToPlayButton setAlpha:1];
            }];
        }];
    }
}

-(void)cardDidFinishDownloadingImageAndName:(Card *)card
{
    self.numCardDataRetrieved ++;
    
    if (self.numCardDataRetrieved == self.friends.count && self.isReadyToDisplayFriendCards) {
        GamePhotoScrollViewController *vc = [[GamePhotoScrollViewController alloc] initWithCards:self.friends superlative:self.superlative];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(IBAction)beginGameButtonTapped:(UIButton *)sender
{
    if (self.goButton.alpha != 0) {
        [UIView animateWithDuration:.5 animations:^{
            [self.readyToPlayButton setFrame:CGRectOffset(self.readyToPlayButton.frame, 0, self.view.frame.size.height - self.readyToPlayButton.frame.origin.y)];
        } completion:^(BOOL finished) {
            [self.readyToPlayButton removeFromSuperview];
            [self.labelView setText:@"Waiting for other players to begin game..."];
            [self.labelView setLineBreakMode:NSLineBreakByWordWrapping];
            [self.labelView setNumberOfLines:2];
            [self.labelView setFont:[UIFont fontWithName:@"Futura-Medium" size:18]];
            CGFloat labelHeight = 100;
            [self.labelView setAlpha:0];
            [self.labelView setFrame:CGRectMake(0, self.view.frame.size.height -100, self.view.frame.size.width, labelHeight)];
            [UIView animateWithDuration:.5 animations:^{
                [self.labelView setAlpha:1];
            }];
        }];
    }
    [self animateAddingGreenCircleAroundPlayer:[TableTalkUtil instance].me];
    [[TableTalkUtil appDelegate].socket sendReadyToPlayMessage];
    
}

-(IBAction)judgeTappedOnScreen:(id)sender
{
    JudgeViewController *jvc = [[JudgeViewController alloc] initWithPlayers:nil superlatives:self.superlatives];
    
    CATransition *transition = [CATransition animation];
    
    transition.duration = .3;
    transition.type = kCATransitionFade;
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:jvc animated:NO];
}

-(void)animateShowingJudgeIsPickingSuperlative
{
    [self.labelView.layer removeAllAnimations];
    [UIView animateWithDuration:.5 animations:^{
        for (UIImageView *imgView in self.playerBlurbs) {
            [imgView setAlpha:0];
        }
        [self.goButton setAlpha:0];
    } completion:^(BOOL finished) {
        [self.labelView.layer removeAllAnimations];
        [UIView animateWithDuration:.5 animations:^{
            if (!self.superlatives) {
                [self.labelView setText:@"Judge is picking superlative"];
            } else {
                [self.labelView setText:@"You are the first judge. Tap anywhere to begin picking your superlative."];
            }
            [self.labelView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
        } completion:^(BOOL finished) {
            if (self.superlatives) {
                UITapGestureRecognizer *judgeTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(judgeTappedOnScreen:)];
                [self.view addGestureRecognizer:judgeTapRecognizer];
            }
        }];
    }];
}

-(void)socketDidReceiveEvent:(SocketIOPacket *)packet
{
    // ZWS-TODO: playerJoined:fbId
    if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"playerSentStartGame"]) {
        NSString *fbId = [[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0];
        Player *player = [[TableTalkUtil instance].players objectForKey:fbId];
        [self animateAddingGreenCircleAroundPlayer:player];
        NSLog(@"player %@ sent start game", fbId);
    } else if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"initialPlayers"]) {
        NSArray *players = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"otherPlayers"];
        self.superlatives = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"superlatives"];
        for (NSString *fbId in players) {
            [self addPlayerToDictionary:fbId];
        }
        // if judge you will receive superlatives
    } else if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"playerJoined"]) {
        [self addPlayerToDictionary:[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0]];
    } else if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"judgePickingSuperlative"]) {
        if (self.superlatives) {
            [self animateShowingJudgeIsPickingSuperlative];
        } else {
            [self animateShowingJudgeIsPickingSuperlative];
            
            self.friendIds = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"friends"];
            self.friends = [[NSMutableArray alloc] init];
            for (NSString *fbId in self.friendIds) {
                Card *card = [[Card alloc] initWithFbId:fbId];
                card.delegate = self;
                [self.friends addObject:card];
            }
            
        }
    } else if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"startRound"]) {
        NSString *superlative = [[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0];
        
        if (self.numCardDataRetrieved == self.friends.count) {
            GamePhotoScrollViewController *vc = [[GamePhotoScrollViewController alloc] initWithCards:self.friends superlative:superlative];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            self.superlative = superlative;
            self.isReadyToDisplayFriendCards = YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
