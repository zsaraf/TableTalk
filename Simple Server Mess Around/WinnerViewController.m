//
//  WinnerViewController.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/23/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "WinnerViewController.h"
#import "JudgeViewController.h"
#import "GamePhotoScrollViewController.h"

@interface WinnerViewController ()

@property (nonatomic, strong) NSString *winner;
@property (nonatomic, strong) NSString *selectedFriend;
@property (nonatomic, assign) BOOL shouldSendMessage;

@end

@implementation WinnerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(id)initWithWinner:(NSString *)winner andSelectedFriend:(NSString *)selectedFriend andShouldSendMessage:(BOOL)shouldSendMessage
{
    if (self = [super init]) {
        self.winner = winner;
        self.selectedFriend = selectedFriend;
        self.shouldSendMessage = shouldSendMessage;
        [[TableTalkUtil appDelegate].socket setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectInset(self.view.frame, 30, 100)];
    [l setText:[NSString stringWithFormat:@"winner %@", self.winner]];
    [l setTextColor:[UIColor whiteColor]];
    [self.view addSubview:l];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    sleep(3);
    if (self.shouldSendMessage) {
        //[[TableTalkUtil appDelegate].socket sendBeginGameMessage];
    }
}

-(void)socketDidReceiveEvent:(SocketIOPacket *)packet
{
    if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"playerFinished"]) return;
    NSArray *friends = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"friends"];
    if (friends == nil) {
        JudgeViewController *vc = [[JudgeViewController alloc] init];
        [TableTalkUtil appDelegate].socket.delegate = vc;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        GamePhotoScrollViewController *vc = [[GamePhotoScrollViewController alloc] initWithCardFBIds:friends superlative:@"ZWS-TODO this is all bullshit"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
