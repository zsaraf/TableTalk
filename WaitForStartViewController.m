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
#import "Player.h"

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
    [[TableTalkUtil appDelegate].socket sendBeginGameMessage];
    //ZWS-TODO: get rid of it
    NSArray *players = [NSArray array];
    JudgeViewController *vc = [[JudgeViewController alloc] initWithPlayers:players superlatives:self.superlatives];
    [TableTalkUtil appDelegate].socket.delegate = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)addPlayerToDictionary:(NSString *)fbId
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    Player *player = [[Player alloc] initWithFbId:fbId];
    [[TableTalkUtil instance].players setObject:player forKey:fbId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:GRAPH_SEARCH_URL_FORMAT, fbId]];
    [manager downloadWithURL:url options:0 progress:^(NSUInteger receivedSize, long long expectedSize){
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        [player setImage:image];
    }];
    NSURL *linkURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@?fields=name", fbId]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:linkURL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [player setName:[responseObject objectForKey:@"name"]];
    }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  
                              }];
    [[NSOperationQueue mainQueue] addOperation:op];
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
        if (friends == nil) {
            NSArray *players = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"otherPlayers"];
            NSArray *superlatives = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"superlatives"];
            JudgeViewController *vc = [[JudgeViewController alloc] initWithPlayers:players superlatives:superlatives];
            [TableTalkUtil appDelegate].socket.delegate = vc;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            GamePhotoScrollViewController *vc = [[GamePhotoScrollViewController alloc] initWithCardFBIds:friends isJudge:NO];
            [self.navigationController pushViewController:vc animated:YES];
        }
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
