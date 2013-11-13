//
//  JudgeViewController.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/18/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "JudgeViewController.h"
#import "GamePhotoScrollViewController.h"
#import "SuperlativeCardView.h"
#import "SDWebImageManager.h"
#import "BlurredWaitingForPlayersToFinishView.h"

#define ENABLED_CONSTANT .7817

@interface JudgeViewController ()

@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSMutableArray *views;
@property (nonatomic, strong) NSMutableDictionary *photosDictionary;
@property (nonatomic, assign) NSInteger currentlySelected;
@property (nonatomic, strong) NSMutableArray *playerViews;
@property (nonatomic, assign) BOOL hasChosen;

@end

@implementation JudgeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithPlayers:(NSArray *)players superlatives:(NSArray *)superlatives
{
    if (self = [super init]) {
        self.players = players;
        self.photosDictionary = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < self.players.count; i++) {
            [self beginDownloadingPhotoForPlayer:[self.players objectAtIndex:i]];
        }
        self.currentlySelected = -1;
        self.superlatives = superlatives;
    }
    return self;
}


-(void)beginDownloadingPhotoForPlayer:(NSString *)player
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:GRAPH_SEARCH_URL_FORMAT, player]];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:url options:0
                    progress:^(NSUInteger receivedSize, long long expectedSize) {
                        
                    }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                       if (image) {
                           [self.photosDictionary setObject:image forKey:player];
                           if (self.hasChosen && self.photosDictionary.count == self.players.count) {
                               [self displayDownloadedImages];
                           }
                           NSLog(@"loaded");
                       } else {
                           NSLog(@"didnt load");
                       }
                   }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colors = [[NSMutableArray alloc] initWithObjects:
                   [UIColor colorWithRed:16/255. green:132/255. blue:205/255. alpha:1.],
                   [UIColor colorWithRed:39/255. green:144/255. blue:210/255. alpha:1.],
                   [UIColor colorWithRed:64/255. green:157/255. blue:215/255. alpha:1.],
                   [UIColor colorWithRed:88/255. green:169/255. blue:220/255. alpha:1.],
                   nil];
    
    self.views = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 4; i++) {
        SuperlativeCardView *v = [[SuperlativeCardView alloc] initWithFrame:CGRectMake(0, i *self.view.frame.size.height/4, self.view.frame.size.width, self.view.frame.size.height/4) superlative:[self.superlatives objectAtIndex:i] index:i];
        [v setBackgroundColor:[self.colors objectAtIndex:i]];
        [self.views addObject:v];
        [self.view addSubview:v];
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    [self.view addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenDoubleTapped:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTapRecognizer];
    
    [recognizer requireGestureRecognizerToFail:doubleTapRecognizer];
	// Do any additional setup after loading the view.
}

-(IBAction)screenDoubleTapped:(UITapGestureRecognizer *)sender
{
    SuperlativeCardView *v = [self getSuperlativeCardForLocationInView:[sender locationInView:self.view]];
    
    if (v.index != self.currentlySelected) {
        [self screenTapped:sender];
    } else {
        self.hasChosen = YES;
        if (self.photosDictionary.count == self.players.count) {
            [self displayDownloadedImages];
        }
    }
}

-(void)displayDownloadedImages
{
    self.playerViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.players.count; i++) {
        NSString *p = [self.players objectAtIndex:i];
        UIImage *img = [self.photosDictionary objectForKey:p];
        BlurredWaitingForPlayersToFinishView *blurView = [[BlurredWaitingForPlayersToFinishView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/4 + i*(self.view.frame.size.height/12), self.view.frame.size.width, self.view.frame.size.height/12) image:img facebookID:p];
        [blurView setAlpha:0.];
        [self.view insertSubview:blurView atIndex:0];
        [self.playerViews addObject:blurView];
    }
    
    SuperlativeCardView *v = [self.views objectAtIndex:self.currentlySelected];
    [UIView animateWithDuration:.3 animations:^{
        [v setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/4)];
        for (UIView *view in self.views) {
            if (view != v) {
                [view setAlpha:0.];
            }
        }
        for (UIView *view in self.playerViews) [view setAlpha:1.];
    }];
    
}

-(SuperlativeCardView *)getSuperlativeCardForLocationInView:(CGPoint)locationInView
{
    SuperlativeCardView *v = (SuperlativeCardView *)[self.view hitTest:locationInView withEvent:nil];
    while (v && ![v isKindOfClass:[SuperlativeCardView class]]) {
        v = (SuperlativeCardView *)(v.superview);
    }
    return v;
}

-(IBAction)screenTapped:(UITapGestureRecognizer *)sender
{
    SuperlativeCardView *v = [self getSuperlativeCardForLocationInView:[sender locationInView:self.view]];
    
    if (v) {
        self.currentlySelected = v.index;
        CGFloat enabledSize = self.view.frame.size.height* ENABLED_CONSTANT;
        CGFloat disabledSize = (self.view.frame.size.height - enabledSize)/3;
        // animate superlative being enabled and others being disabled
        [UIView animateWithDuration:.3 animations:^{
            CGFloat totalHeight = 0;
            for (int i = 0; i < self.views.count; i++) {
                if (i == v.index) {
                    [v setFrame:CGRectMake(0, totalHeight, self.view.frame.size.width, enabledSize)];
                    totalHeight += enabledSize;
                    [v setShowAll];
                } else {
                    SuperlativeCardView *view = [self.views objectAtIndex:i];
                    [view setFrame:CGRectMake(0, totalHeight, self.view.frame.size.width, disabledSize)];
                    totalHeight += disabledSize;
                    [view setHideAll];
                }
            }
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)socketDidReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"%@", packet.dataAsJSON);
    id json = packet.dataAsJSON;
    if ([[json objectForKey:@"name"] isEqualToString:@"startJudging"]) {
        NSArray *fbIDs = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"friends"];
        //GamePhotoScrollViewController *vc = [[GamePhotoScrollViewController alloc] initWithCardFBIds:fbIDs isJudge:YES];
        //[self.navigationController pushViewController:vc animated:YES];
    } else if ([[json objectForKey:@"name"] isEqualToString:@"playerFinished"]) {
        NSLog(@"%@", json);
        NSString *fbId = [[json objectForKey:@"args"] objectAtIndex:0];
        BlurredWaitingForPlayersToFinishView *v;
        for (BlurredWaitingForPlayersToFinishView *view in self.playerViews) {
            if ([view.facebookID isEqualToString:fbId]) {
                v = view;
            }
        }
        [v changeToEnabledStateWithAnimation:YES];
    }
}

@end
