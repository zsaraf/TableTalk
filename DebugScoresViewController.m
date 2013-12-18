//
//  DebugScoresViewController.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/18/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "DebugScoresViewController.h"
#import "TableTalkUtil.h"
#import "DisplayScoresTableView.h"

@interface DebugScoresViewController ()

@property (nonatomic, strong) Player *me;

@end

@implementation DebugScoresViewController

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
    
    NSArray *players = [NSArray arrayWithObjects:@"521242550",@"521827780",@"524372404",@"524693200",@"524747587", @"588688409", nil];
    self.me = [[Player alloc] initWithFbId:@"1323098301"];
    self.me.delegate = self;
    [TableTalkUtil instance].me = self.me;
    for (NSString *fbId in players) {
        Player *player = [[Player alloc] initWithFbId:fbId];
        player.delegate = self;
        [[TableTalkUtil instance].players setObject:player forKey:fbId];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)playerDidFinishDownloadingImageAndName:(Player *)player
{
    static int counter = 0;
    counter ++;
    
    if (counter == [TableTalkUtil instance].players.count + 1)
    {
        DisplayScoresTableView *tableView = [[DisplayScoresTableView alloc] initWithFrame:self.view.bounds backgroundColor:[UIColor colorWithRed:88/255. green:169/255. blue:220/255. alpha:1.] textColor:[UIColor whiteColor] winningPlayer:self.me];
        [self.view addSubview:tableView];
    }
}

@end
