//
//  WaitForJudgeViewController.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "WaitForJudgeViewController.h"
#import "WinnerViewController.h"

@interface WaitForJudgeViewController ()

@end

@implementation WaitForJudgeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(self.view.bounds, 30, 150)];
    [label setTextColor:[UIColor greenColor]];
    [label setText:@"Waiting For Judge"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label];
}

-(void)socketDidReceiveEvent:(SocketIOPacket *)packet
{
    if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"roundFinished"]) {
        NSString *winner = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"winner"];
        NSString *selectedFriend = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"selectedFriend"];
        
        WinnerViewController *vc = [[WinnerViewController alloc] initWithWinner:winner andSelectedFriend:selectedFriend andShouldSendMessage:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
