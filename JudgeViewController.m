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
#import "UIImage+Crop.h"
#import "UIImage+ImageEffects.h"

#define SIZE_OF_BLURRED_PLAYER_VIEW 64
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

@property (nonatomic, strong) NSMutableArray *nextRoundCards;
@property (nonatomic) NSInteger numNextRoundCardsDownloaded;
@property (nonatomic) BOOL isReadyToMoveOntoGamePhotoScrollViewController;
@property (nonatomic, strong) NSString *nextRoundSuperlative;

@property (nonatomic) NSInteger numChoicesDownloaded;
@property (nonatomic) NSInteger numPlayersDidFinish;

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
        [TableTalkUtil appDelegate].socket.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:39/255. green:144/255. blue:210/255. alpha:1.];
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
    if (self.judgeChoosingWinnerPhotoScrollView) {
        
    } else {
        SuperlativeCardView *v = [self getSuperlativeCardForLocationInView:[sender locationInView:self.view]];
        [self displayPlayerImagesWithSuperlativeView:v];
        [[TableTalkUtil appDelegate].socket sendBeginGameMessageWithSuperlative:v.superlative];
        self.views = [[NSMutableArray alloc] initWithObjects:v, nil];
    }
}

-(CGFloat)screenWidth
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    return screenWidth;
}

-(void)setScreenWidth:(CGFloat)screenWidth {}

-(void)displayPlayerImagesWithSuperlativeView:(SuperlativeCardView *)superlativeView
{
    self.playerViews = [[NSMutableArray alloc] init];
    NSMutableDictionary *playersDict = [TableTalkUtil instance].players;
    int i = 0;
    for (NSString *fbId in playersDict) {
        Player *player = [playersDict objectForKey:fbId];
        BlurredWaitingForPlayersToFinishView *blurView = [[BlurredWaitingForPlayersToFinishView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (playersDict.count - i)*SIZE_OF_BLURRED_PLAYER_VIEW, self.view.frame.size.width, SIZE_OF_BLURRED_PLAYER_VIEW) player:player];
        [blurView setAlpha:0.];
        [self.view insertSubview:blurView atIndex:0];
        [self.playerViews addObject:blurView];
        i ++;
    }
    [UIView animateWithDuration:.5 animations:^{
        [self.view bringSubviewToFront:superlativeView];
        [superlativeView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        for (UIView *view in self.views) {
            if (view != superlativeView) {
                [view setAlpha:0.];
            }
        }
    } completion:^(BOOL finished) {
        for (UIView *view in self.playerViews) [view setAlpha:1.];
        
        __weak SuperlativeCardView *_superlativeView = superlativeView;
        [superlativeView addRoundLabelAndNumFinishedLabelWithFinishedCompetionBlock:^{
            [UIView animateWithDuration:.5 animations:^{
                [_superlativeView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - playersDict.count * SIZE_OF_BLURRED_PLAYER_VIEW)];
            }];
        }];
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
    self.numChoicesDownloaded ++;
    if (self.numChoicesDownloaded == [TableTalkUtil instance].players.count) {
        [self displaySelectedPlayersToBeginJudging];
    }
}

-(IBAction)beginJudgingButtonTapped:(UITapGestureRecognizer *)sender
{
    [sender setEnabled:NO];
    
    SuperlativeCardView *scv = [self.views firstObject];
    CGFloat newHeight = 64;
    
    self.judgeChoosingWinnerPhotoScrollView = [[JudgeChoosingWinnerPhotoScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - newHeight) choices:self.choices withDesiredEndingBackgroundColor:scv.backgroundColor isJudge:YES];
    [self.view addSubview:self.judgeChoosingWinnerPhotoScrollView];
    
    CGFloat initialOffset = SIZE_OF_BLURRED_PLAYER_VIEW * [TableTalkUtil instance].players.count;
    CGFloat secondOffset = self.view.frame.size.height - newHeight - initialOffset;
    CGFloat initialAnimationNumSeconds = initialOffset / (initialOffset + secondOffset) * 1.0;
    CGFloat secondAnimationNumSeconds = secondOffset / (initialOffset + secondOffset) * 1.0;
    [UIView animateWithDuration:initialAnimationNumSeconds delay:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
        [scv hideRoundAndNumFinishedLabels];
        [self.judgeChoosingWinnerPhotoScrollView setFrame:CGRectOffset(self.judgeChoosingWinnerPhotoScrollView.frame, 0, -1.0 * SIZE_OF_BLURRED_PLAYER_VIEW * [TableTalkUtil instance].players.count)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:secondAnimationNumSeconds delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [scv setFrame:CGRectMake(0, 0, self.view.frame.size.width, newHeight)];
            [self.judgeChoosingWinnerPhotoScrollView setFrame:CGRectMake(0, newHeight, self.view.frame.size.width, self.view.frame.size.height - newHeight)];
        } completion:^(BOOL finished) {
            
        }];
        for (UIView *v in self.view.subviews) {
            if (v != scv && v != self.judgeChoosingWinnerPhotoScrollView) {
                [v removeFromSuperview];
            }
        }
    }];
}

-(void)displaySelectedPlayersToBeginJudging
{
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *superlativesSnapShotImage = [snapshotImage cropFromRect:CGRectMake(0, self.view.frame.size.height - [TableTalkUtil instance].players.count * SIZE_OF_BLURRED_PLAYER_VIEW, self.view.frame.size.height, [TableTalkUtil instance].players.count *SIZE_OF_BLURRED_PLAYER_VIEW)];
    UIImage *blurredImage = [superlativesSnapShotImage applyLightEffect];
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - blurredImage.size.height, self.view.frame.size.width, blurredImage.size.height)];
    [view setImage:blurredImage];
    [view setAlpha:0];
    [self.view addSubview:view];
    
    UILabel *viewLabel = [[UILabel alloc] initWithFrame:view.bounds];
    [viewLabel setText:@"Tap to begin judging"];
    [viewLabel setTextAlignment:NSTextAlignmentCenter];
    [viewLabel setTextColor:[UIColor whiteColor]];
    [viewLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
    [view addSubview:viewLabel];
    
    [UIView animateWithDuration:.5 animations:^{
        [view setAlpha:1];
    }];
    
    for (UIGestureRecognizer *rec in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:rec];
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginJudgingButtonTapped:)];
    [self.view addGestureRecognizer:recognizer];
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
    } else if ([[json objectForKey:@"name"] isEqualToString:@"playerFinished"]) {
        self.numPlayersDidFinish ++;
        NSString *fbId = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"fbID"];
        NSString *selectedFbId = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"selectedFriend"];
        Choice *choice = [[Choice alloc] initWithFbId:selectedFbId chosenByFbId:fbId];
        choice.delegate = self;
        [self.choices addObject:choice];
        
        SuperlativeCardView *scv = [self.views firstObject];
        [scv setNumFinishedLabelTextWithNumFinished:self.numPlayersDidFinish];
        
        BlurredWaitingForPlayersToFinishView *v;
        for (BlurredWaitingForPlayersToFinishView *view in self.playerViews) {
            if ([view.player.fbId isEqualToString:fbId]) {
                v = view;
            }
        }
        [v changeToEnabledStateWithAnimation:YES];
    } else if ([[json objectForKey:@"name"] isEqualToString:@"judgePickingSuperlative"]) {
        NSString *fbId = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"fbID"];
        [UIView animateWithDuration:.5 animations:^{
            for (UIView *view in self.view.subviews) {
                [view setAlpha:0];
            }
        } completion:^(BOOL finished) {
            UILabel *label = [TableTalkUtil tableTalkLabelWithFrame:self.view.bounds fontSize:22 text:[NSString stringWithFormat:@"%@ is picking the next superlative", @"Judge"]];
            [label setAlpha:0];
            [label setNumberOfLines:0];
            [label setLineBreakMode:NSLineBreakByWordWrapping];
            [self.view addSubview:label];
            
            [UIView animateWithDuration:.5 animations:^{
                [label setAlpha:1];
            }];
        }];
    } else if ([[json objectForKey:@"name"] isEqualToString:@"roundFinished"]) {
        NSArray *nextRoundCards = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"friends"];
        self.nextRoundCards = [[NSMutableArray alloc] init];
        for (NSString *fbId in nextRoundCards) {
            Card *card = [[Card alloc] initWithFbId:fbId];
            card.delegate = self;
            [self.nextRoundCards addObject:card];
        }
    } else if ([[json objectForKey:@"name"] isEqualToString:@"startRound"]) {
        if (self.nextRoundCards.count != 0) {
            self.isReadyToMoveOntoGamePhotoScrollViewController = YES;
            self.nextRoundSuperlative = [[json objectForKey:@"args"] objectAtIndex:0];
            if (self.numNextRoundCardsDownloaded == self.nextRoundCards.count) {
                [self changeToGamePhotoScrollViewController];
            }
        }
    }
}

-(void)changeToGamePhotoScrollViewController
{
    GamePhotoScrollViewController *gvc = [[GamePhotoScrollViewController alloc] initWithCards:self.nextRoundCards superlative:self.nextRoundSuperlative];
    
    CATransition *transition = [CATransition animation];
    
    transition.duration = .5;
    transition.type = kCATransitionFade;
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController setViewControllers:@[gvc] animated:NO];

}

-(void)cardDidFinishDownloadingImageAndName:(Card *)card
{
    self.numNextRoundCardsDownloaded ++;
    
    if (self.numNextRoundCardsDownloaded ==  self.nextRoundCards.count && self.isReadyToMoveOntoGamePhotoScrollViewController) {
        [self changeToGamePhotoScrollViewController];
    }
}


@end
