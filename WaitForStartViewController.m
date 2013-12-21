//
//  WaitForStartViewController.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/14/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "WaitForStartViewController.h"
#import "TableTalkUtil.h"
#import "GamePhotoScrollViewController.h"
#import "JudgeViewController.h"
#import "SDWebImageManager.h"
#import <AFNetworking.h>

@interface WaitForStartViewController ()

@property (nonatomic, strong) NSArray *superlatives;

@end

@implementation WaitForStartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)beginGameButtonPressed:(id)sender {
    //ZWS-TODO: get rid of it
    NSArray *players = [NSArray array];
    JudgeViewController *vc = [[JudgeViewController alloc] initWithPlayers:players superlatives:self.superlatives];
    [TableTalkUtil appDelegate].socket.delegate = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)addPlayerToDictionary:(NSString *)fbId
{
    Player *player = [[Player alloc] initWithFbId:fbId];
    [[TableTalkUtil instance].players setObject:player forKey:fbId];
}

-(void)playerDidFinishDownloadingImageAndName:(Player *)player
{
    static NSInteger counter = 0;
    counter ++;
    if (counter == [TableTalkUtil instance].players.count) {
        NSLog(@"good we can continue with judge");
    }
}

-(void)socketDidReceiveEvent:(SocketIOPacket *)packet
{
    // ZWS-TODO: playerJoined:fbId
    if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"initialPlayers"]) {
        NSArray *players = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"otherPlayers"];
        self.superlatives = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"superlatives"];
        for (NSString *fbId in players) {
            [self addPlayerToDictionary:fbId];
        }
        // if judge you will receive superlatives
    } else if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"playerJoined"]) {
        [self addPlayerToDictionary:[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0]];
    } else {
        NSArray *friends = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"friends"];
        NSString *superlative = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"superlative"];
        //GamePhotoScrollViewController *vc = [[GamePhotoScrollViewController alloc] initWithCardFBIds:friends superlative:superlative];
        //[self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
