//
//  GamePhotoScrollViewController.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/14/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "GamePhotoScrollViewController.h"
#import "OneFriendPhotoScrollView.h"
#import "TableTalkUtil.h"
#import "WaitForJudgeViewController.h"
#import "WinnerViewController.h"

@interface GamePhotoScrollViewController ()

@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSArray *card_fbIDs;
@property (nonatomic, assign) BOOL isJudging;

@end

@implementation GamePhotoScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCardFBIds:(NSArray *)fbIDs isJudge:(BOOL)isJudge
{
    self = [super init];
    if (self) {
        self.card_fbIDs = fbIDs;
        self.isJudging = isJudge;
        [TableTalkUtil appDelegate].socket.delegate = self;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.photoScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.photoScrollView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.photoScrollView];
    [self.photoScrollView setPagingEnabled:YES];
    [self.photoScrollView setDelegate:self];
    [self addFriendScrollViews];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoDoubleTapped:)];
    [recognizer setNumberOfTapsRequired:2];
    [self.photoScrollView addGestureRecognizer:recognizer];
}

-(IBAction)photoDoubleTapped:(UITapGestureRecognizer *)sender
{
    NSInteger friendIndex = self.photoScrollView.contentOffset.x/self.photoScrollView.frame.size.width;
    if (self.isJudging) {
        [[TableTalkUtil appDelegate].socket sendChoseWinnerMessage:[self.card_fbIDs objectAtIndex:friendIndex]];
    } else {
        WaitForJudgeViewController *vc = [[WaitForJudgeViewController alloc] init];
        [TableTalkUtil appDelegate].socket.delegate = vc;
        [self.navigationController pushViewController:vc animated:YES];
        [[TableTalkUtil appDelegate].socket sendChoseFriendMessage:[self.card_fbIDs objectAtIndex:friendIndex]];
    }
}

-(void)socketDidReceiveEvent:(SocketIOPacket *)packet
{
    if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"roundFinished"]) {
        if (self.isJudging) {
            NSString *winner = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"winner"];
            NSString *selectedFriend = [[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"selectedFriend"];
        
            WinnerViewController *vc = [[WinnerViewController alloc] initWithWinner:winner andSelectedFriend:selectedFriend andShouldSendMessage:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        
    }
}

-(void)addFriendScrollViews
{
    [self.photoScrollView setContentSize:CGSizeMake(self.card_fbIDs.count * self.view.frame.size.width, self.view.frame.size.height)];
    for (int i = 0; i < self.card_fbIDs.count; i++) {
        OneFriendPhotoScrollView *sv = [[OneFriendPhotoScrollView alloc] initWithFrame:CGRectOffset(self.view.frame, i *self.view.frame.size.width, 0) andPhotoURL:[NSURL URLWithString:[NSString stringWithFormat:GRAPH_SEARCH_URL_FORMAT, [self.card_fbIDs objectAtIndex:i]]]];
        [self.photoScrollView addSubview:sv];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrolling");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
