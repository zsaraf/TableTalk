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

@interface WaitForStartViewController ()

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
        GamePhotoScrollViewController *vc = [[GamePhotoScrollViewController alloc] initWithCardFBIds:friends isJudge:NO];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [TableTalkUtil appDelegate].socket.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
