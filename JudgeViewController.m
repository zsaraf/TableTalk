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
#import "JudgingSelectorChosenFriendCard.h"
#import "Player.h"
#import "JudgeChoosingWinnerPhotoScrollView.h"

#define ENABLED_CONSTANT .7817

@interface JudgeViewController ()

@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSMutableArray *views;
@property (nonatomic, strong) NSMutableDictionary *photosDictionary;
@property (nonatomic, assign) NSInteger currentlySelected;
@property (nonatomic, strong) NSMutableArray *playerViews;
@property (nonatomic, assign) BOOL hasChosen;
@property (nonatomic, strong) NSMutableDictionary *chosenPhotosDictionary;
@property (nonatomic, strong) UIScrollView *chosenPhotosScrollView;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, strong) NSMutableArray *chosenPhotosImageViews;
@property (nonatomic, strong) NSMutableArray *choices;
@property (nonatomic, strong) JudgeChoosingWinnerPhotoScrollView *judgeChoosingWinnerPhotoScrollView;

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
        self.choices = [[NSMutableArray alloc] init];
        self.currentlySelected = -1;
        self.superlatives = superlatives;
    }
    return self;
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
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenDoubleTapped:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTapRecognizer];
}

-(IBAction)screenDoubleTapped:(UITapGestureRecognizer *)sender
{
    SuperlativeCardView *v = [self getSuperlativeCardForLocationInView:[sender locationInView:self.view]];
    [self displayPlayerImagesWithSuperlativeView:v];
    [[TableTalkUtil appDelegate].socket sendBeginGameMessageWithSuperlative:v.superlative];
    self.views = [[NSMutableArray alloc] initWithObjects:v, nil];
    
}

-(CGFloat)screenWidth
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    return screenWidth;
}

-(void)setScreenWidth:(CGFloat)screenWidth {}

-(void)displayPlayerImagesWithSuperlativeView:(UIView *)superlativeView
{
    self.playerViews = [[NSMutableArray alloc] init];
    NSMutableDictionary *playersDict = [TableTalkUtil instance].players;
    int i = 0;
    for (NSString *fbId in playersDict) {
        Player *player = [playersDict objectForKey:fbId];
        BlurredWaitingForPlayersToFinishView *blurView = [[BlurredWaitingForPlayersToFinishView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/4 + i*(self.view.frame.size.height/12), self.view.frame.size.width, self.view.frame.size.height/12) player:player];
        [blurView setAlpha:0.];
        [self.view insertSubview:blurView atIndex:0];
        [self.playerViews addObject:blurView];
        i ++;
    }
    [UIView animateWithDuration:.3 animations:^{
        [superlativeView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/4)];
        for (UIView *view in self.views) {
            if (view != superlativeView) {
                [view setAlpha:0.];
            }
        }
        for (UIView *view in self.playerViews) [view setAlpha:1.];
    }];
}

-(void)createScrollViewWithChosenPhotos
{
    // MAKE SURE TO CHECK WHICH ARRAY IS BEING USED --ZWS
    self.chosenPhotosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/4, self.view.frame.size.width, self.view.frame.size.width)];
    [self.chosenPhotosScrollView setPagingEnabled:YES];
    [self.chosenPhotosScrollView setDelegate:self];
    [self.chosenPhotosScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width * self.chosenPhotosDictionary.count)];
    [self.chosenPhotosScrollView setClipsToBounds:NO];
    [self.chosenPhotosScrollView setAlpha:0.];
    [self.view insertSubview:self.chosenPhotosScrollView atIndex:0];
    
    self.chosenPhotosImageViews = [[NSMutableArray alloc] init];
    
    int counter = 0;
    for (NSString *key in self.chosenPhotosDictionary) {
        UIImage *img = [self.chosenPhotosDictionary objectForKey:key];
        
        JudgingSelectorChosenFriendCard *v = [[JudgingSelectorChosenFriendCard alloc] initWithFrame:CGRectMake(0, counter * self.view.frame.size.width, self.view.frame.size.width, self.view.frame.size.width) image:img playerFacebookId:key chosenFacebookId:key];
        [self.chosenPhotosScrollView addSubview:v];
        [self.chosenPhotosImageViews addObject:v];
        if (counter == 0) [v setBlurredImageViewAlpha:0.0];
        
        counter++;
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger currentPage = ((NSInteger)scrollView.contentOffset.y)/((NSInteger)scrollView.frame.size.height);
    
    CGFloat alpha = fmodf(scrollView.contentOffset.y, scrollView.frame.size.height) / scrollView.frame.size.height;
    
    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
        if (i >= 0 && i < self.chosenPhotosImageViews.count) {
            JudgingSelectorChosenFriendCard *v = [self.chosenPhotosImageViews objectAtIndex:i];
            if (i == currentPage) {
                [v setBlurredImageViewAlpha:alpha];
            } else {
                [v setBlurredImageViewAlpha:1 - alpha];
            }
        }
    }
}

-(SuperlativeCardView *)getSuperlativeCardForLocationInView:(CGPoint)locationInView
{
    SuperlativeCardView *v = (SuperlativeCardView *)[self.view hitTest:locationInView withEvent:nil];
    while (v && ![v isKindOfClass:[SuperlativeCardView class]]) {
        v = (SuperlativeCardView *)(v.superview);
    }
    return v;
}

// choice delegate
-(void)didFinishDownloadingImageAndNameForChoice:(Choice *)choice
{
    static NSInteger count = 0;
    count++;
    if (count == [TableTalkUtil instance].players.count) {
        [self displaySelectedPlayersToBeginJudging];
    }
}

-(void)displaySelectedPlayersToBeginJudging
{
    SuperlativeCardView *scv = [self.views firstObject];
    self.judgeChoosingWinnerPhotoScrollView = [[JudgeChoosingWinnerPhotoScrollView alloc] initWithFrame:CGRectMake(0, scv.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - scv.frame.size.height) choices:self.choices];
    [self.judgeChoosingWinnerPhotoScrollView setAlpha:0];
    [self.view addSubview:self.judgeChoosingWinnerPhotoScrollView];
    [UIView animateWithDuration:.5 animations:^{
        [self.judgeChoosingWinnerPhotoScrollView setAlpha:1];
        for (UIView *v in self.view.subviews) {
            if (v != scv && v != self.judgeChoosingWinnerPhotoScrollView) {
                [v setAlpha:0.];
            }
        }
    } completion:^(BOOL finished) {
        for (UIView *v in self.view.subviews) {
            if (v != scv && v != self.judgeChoosingWinnerPhotoScrollView) {
                [v removeFromSuperview];
            }
        }
    }];
}

/*-(IBAction)screenTapped:(UITapGestureRecognizer *)sender
{
    // MUST UNCOMMENT THIS --ZWS
    //SuperlativeCardView *v = [self getSuperlativeCardForLocationInView:[sender locationInView:self.view]];
    
    // MUST REMOVE THIS, ONLY USED FOR FAST DEBUGGING. --ZWS
    SuperlativeCardView *v = [self.views firstObject];
    
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
}*/

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
        NSString *fbId = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"userID"];
        NSString *selectedFbId = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"selectedFriend"];
        Choice *choice = [[Choice alloc] initWithFbId:selectedFbId chosenByFbId:fbId];
        choice.delegate = self;
        [self.choices addObject:choice];
        
        BlurredWaitingForPlayersToFinishView *v;
        for (BlurredWaitingForPlayersToFinishView *view in self.playerViews) {
            if ([view.player.fbId isEqualToString:fbId]) {
                v = view;
            }
        }
        [v changeToEnabledStateWithAnimation:YES];
    }
}

@end
