//
//  GamePhotoScrollViewController.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/14/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "GamePhotoScrollViewController.h"
#import "TableTalkUtil.h"
#import "WaitForJudgeViewController.h"
#import "WinnerViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendCardView.h"
#import "SuperlativeCardView.h"
#import "JudgeChoosingWinnerPhotoScrollView.h"
#import "JudgeViewController.h"

@interface GamePhotoScrollViewController ()


@property (nonatomic, strong) NSMutableArray *scrollViewArray;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger numPhotosLoaded;
@property (nonatomic, strong) UIView *blackView;

@property (nonatomic, assign) CGFloat firstY;
@property (nonatomic, assign) CGFloat currentY;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *toolbar;
@property (nonatomic, weak) FriendCardView *current;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, strong) NSString *superlative;

@property (nonatomic, strong) NSArray *cards;
@property (nonatomic, strong) NSMutableArray *choices;
@property (nonatomic, strong) UIImageView *selectedImageView;

// content view views
@property (nonatomic, strong) UILabel *contentViewNameLabel;
@property (nonatomic, strong) UILabel *contentViewStatusLabel;
@property (nonatomic, strong) UILabel *contentViewNumFinishedLabel;

// for the choices
@property (nonatomic) NSInteger numFinished;
@property (nonatomic) NSInteger numChoicesDownloaded;

@property (nonatomic, strong) NSString *currentlyViewing;
@property (nonatomic, strong) JudgeChoosingWinnerPhotoScrollView *judgeChoosingWinnerPhotoScrollView;

// to enter next round:
@property (nonatomic, strong) NSArray *superlatives;
@property (nonatomic, strong) NSMutableArray *nextRoundsCards;
@property (nonatomic) NSInteger numCardsDownloaded;
@property (nonatomic, strong) NSString *nextRoundSuperlative;
@property (nonatomic) BOOL isReadyToBeginNextRound;

@end

@implementation GamePhotoScrollViewController

@synthesize currentlyViewing = _currentlyViewing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCards:(NSArray *)cards superlative:(NSString *) superlative
{
    if (self = [super init]) {
        self.scrollViewArray = [[NSMutableArray alloc] init];
        [TableTalkUtil appDelegate].socket.delegate = self;
        self.superlative = superlative;
        self.contentView = [[UIView alloc] init];
        self.cards = cards;
        self.choices = [[NSMutableArray alloc] init];
    }
    return self;
}

//-(id)initWithCardFBIds:(NSArray *)fbIDs superlative:(NSString *)superlative
//{
//    if (self = [super init]) {
//        self.scrollViewArray = [[NSMutableArray alloc] init];
//        [TableTalkUtil appDelegate].socket.delegate = self;
//        self.superlative = superlative;
//        self.contentView = [[UIView alloc] init];
//        int index = 0;
//        for (NSString *fbID in fbIDs) {
//            FriendCardView *sv = [[FriendCardView alloc] initWithFBId:fbID andIndex:index isLast:(index == fbIDs.count - 1)];
//            sv.delegate = self;
//            [self.scrollViewArray addObject:sv];
//            [self.contentView insertSubview:sv atIndex:0];
//            index ++;
//        }
//    }
//    return self;
//}

-(CGFloat)screenWidth
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    return screenWidth;
}

-(void)setScreenWidth:(CGFloat)screenWidth {}

-(void)didFinishLoadingImage:(UIImage *)image forIndex:(NSInteger)index
{
    self.numPhotosLoaded ++;
    if (self.numPhotosLoaded >= self.scrollViewArray.count) {
        for (int i = 0; i < self.scrollViewArray.count; i++) {
            FriendCardView *v = [self.scrollViewArray objectAtIndex:i];
            if (i != 0) [v setBlurredImageViewAlpha:1.0];
        }
        [(UIActivityIndicatorView *)(self.blackView.subviews.firstObject) stopAnimating];
        [self.blackView removeFromSuperview];
        [UIView animateWithDuration:.3 animations:^{
            for (int i = 0; i < self.scrollViewArray.count; i++) {
                FriendCardView *v = [self.scrollViewArray objectAtIndex:i];
                CGFloat nameHeight = (self.contentView.frame.size.height - self.screenWidth)/(self.scrollViewArray.count - 1);
                [v setFrame:CGRectMake(0, (i)*nameHeight, self.contentView.frame.size.width, self.screenWidth)];
            }
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.5 animations:^{
                [[self.scrollViewArray firstObject] setBlurredImageViewAlpha:0.0];
            }];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    [self.contentView addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    [self.contentView addGestureRecognizer:tapRecognizer];
    [recognizer requireGestureRecognizerToFail:tapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoDoubleTapped:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTapRecognizer];
    //[recognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
}

-(IBAction)screenTapped:(UITapGestureRecognizer *)sender
{
    NSLog(@"screen tapped");
    UIView *v = [self.contentView hitTest:[sender locationInView:self.contentView] withEvent:nil];
    while (![v isKindOfClass:[FriendCardView class]]) v = v.superview;
    FriendCardView *fv = (FriendCardView *)v;
    
    [UIView animateWithDuration:.3 animations:^{
        
        if (fv.index < self.currentPage) {
            for (int i = fv.index; i <= self.currentPage; i++) {
                FriendCardView *v = [self.scrollViewArray objectAtIndex:i];
                [v setFrame:[self frameForCardViewAtIndex:i isInUpState:NO]];
                [v setBlurredImageViewAlpha:1.];
            }
        } else {
            for (int i = self.currentPage; i < fv.index; i++) {
                FriendCardView *v = [self.scrollViewArray objectAtIndex:i];
                [v setFrame:[self frameForCardViewAtIndex:i isInUpState:YES]];
                [v setBlurredImageViewAlpha:1.];
            }
        }
        FriendCardView *cv = [self.scrollViewArray objectAtIndex:fv.index];
        [cv setBlurredImageViewAlpha:0.];
    }];
    self.currentPage = fv.index;
}

-(CGRect)frameForCardViewAtIndex:(NSInteger)index isInUpState:(BOOL)isInUpState
{
    CGFloat nameHeight = (self.contentView.frame.size.height - self.screenWidth)/(self.cards.count - 1);
    CGRect frame = CGRectMake(0, index * nameHeight, self.contentView.frame.size.width, self.screenWidth);
    if (isInUpState) {
        frame.origin.y -= frame.size.height - nameHeight;
    }
    return frame;
}

-(IBAction)userDidPan:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        self.firstY = [sender locationInView:self.contentView].y;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [sender locationInView:self.contentView];
        CGFloat nameHeight = (self.contentView.frame.size.height - self.screenWidth)/(self.scrollViewArray.count - 1);
        if (self.current == nil) {
            int index = (location.y < self.firstY) ? self.currentPage : self.currentPage - 1;
            if (index < 0 || index >= self.scrollViewArray.count - 1) return;
            self.current = [self.scrollViewArray objectAtIndex:index];
        } else {
            if (abs(location.y - self.firstY) > self.current.frame.size.height - nameHeight) {
                [sender setTranslation:CGPointZero inView:self.view];
                return;
            }
        }
        [self.current setFrame:CGRectOffset(self.current.frame, 0, [sender translationInView:self.view].y)];
        CGFloat alpha = abs(location.y - self.firstY)/(self.current.frame.size.height - nameHeight);
        if (location.y < self.firstY) alpha = 1- alpha;
        
        [self.current setBlurredImageViewAlpha:1 - alpha];
        FriendCardView *next = [self.scrollViewArray objectAtIndex:self.current.index + 1];
        [next setBlurredImageViewAlpha:alpha];
        [sender setTranslation:CGPointZero inView:self.view];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.current == nil) return;
        
        CGPoint location = [sender locationInView:self.contentView];
        int diff = abs(self.firstY - location.y);
        if (self.firstY < location.y) {
            diff += [sender velocityInView:self.view].y/10;
        } else {
            diff -= [sender velocityInView:self.view].y/10;
        }
        CGFloat nameHeight = (self.contentView.frame.size.height - self.screenWidth)/(self.scrollViewArray.count - 1);
        CGRect newFrame = CGRectMake(0, self.current.index * nameHeight, self.contentView.frame.size.width, self.screenWidth);
        CGFloat newAlpha = 0.;
        if (diff < self.screenWidth/2) {
            if (location.y > self.firstY) {
                newAlpha = 1.;
                newFrame.origin.y -= self.current.frame.size.height - nameHeight;
            }
        } else {
            if (location.y <= self.firstY) {
                newFrame.origin.y -= self.current.frame.size.height - nameHeight;
                newAlpha = 1.;
                self.currentPage ++;
            } else {
                self.currentPage --;
            }
        }
        
        CGFloat absVelocityInView = abs([sender velocityInView:self.view].y);
        NSLog(@"%f", absVelocityInView);
        if (absVelocityInView < 100) absVelocityInView = 400;
        CGFloat animationTime = abs(newFrame.origin.y - self.current.frame.origin.y) * 1/absVelocityInView;
        [UIView animateWithDuration:animationTime animations:^{
            [self.current setFrame:newFrame];
            [self.current setBlurredImageViewAlpha:newAlpha];
            FriendCardView *next = [self.scrollViewArray objectAtIndex:self.current.index + 1];
            [next setBlurredImageViewAlpha:1-newAlpha];
        }];
        self.current = nil;
        [sender setTranslation:CGPointZero inView:self.view];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIColor *bckgdColor = [UIColor colorWithRed:39/255. green:144/255. blue:210/255. alpha:1.];
    // beginning of toolbar code
    self.toolbar = [[SuperlativeCardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 84) superlative:self.superlative index:0];
    [self.toolbar setBackgroundColor:bckgdColor];
    [self.view addSubview:self.toolbar];
    // end of toolbar code
    [self.view setBackgroundColor:bckgdColor];
    
    // beginning of content code
    [self.contentView setFrame:CGRectMake(0, self.toolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.toolbar.frame.size.height)];
    [self.contentView setBackgroundColor:bckgdColor];
    [self.view addSubview:self.contentView];
    CGFloat nameHeight = (self.contentView.frame.size.height - self.screenWidth)/(self.cards.count - 1);
    for (int i = 0; i < self.cards.count; i++) {
        Card *card = [self.cards objectAtIndex:i];
        FriendCardView *sv = [[FriendCardView alloc] initWithFrame:[self frameForCardViewAtIndex:i isInUpState:NO]
                                                              card:card andIndex:i isLast:i == self.cards.count - 1];
        [self.scrollViewArray addObject:sv];
        [sv setLabelHeight:nameHeight];
        if (i == 0) sv.blurredImageViewAlpha = 0.;
        else sv.blurredImageViewAlpha = 1.0;
        [self.contentView addSubview:sv];
        //sv.blurredImageViewAlpha = 0.;
        //[sv setFrame:CGRectMake(0, (i)*nameHeight, self.contentView.frame.size.width, self.screenWidth)];
    }
    
    for (int i = self.scrollViewArray.count - 1; i >= 0; i--) {
        [self.contentView bringSubviewToFront:[self.scrollViewArray objectAtIndex:i]];
    }
    
    self.currentPage = 0;
    
    FriendCardView *v = [self.scrollViewArray firstObject];
    [v setBlurredImageViewAlpha:0.];
    
    [self.view bringSubviewToFront:self.toolbar];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}



-(IBAction)photoDoubleTapped:(UITapGestureRecognizer *)sender
{
    NSLog(@"photo doubel tapped");
    UIView *v = [self.contentView hitTest:[sender locationInView:self.contentView] withEvent:nil];
    while (![v isKindOfClass:[FriendCardView class]]) v = v.superview;
    FriendCardView *fv = (FriendCardView *)v;
    
    if (fv.index == self.currentPage) {
        Choice *myChoice = [[Choice alloc] initWithFbId:fv.card.fbId chosenByFbId:[TableTalkUtil instance].me.fbId image:fv.card.image name:fv.card.name];
        [self.choices addObject:myChoice];
        [myChoice setDelegate:self];
        
        [[TableTalkUtil appDelegate].socket sendChoseFriendMessage:fv.card.fbId];
        
        for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
            [self.view removeGestureRecognizer:recognizer];
        }
        
        
        //        WaitForJudgeViewController *vc = [[WaitForJudgeViewController alloc] init];
        //        [TableTalkUtil appDelegate].socket.delegate = vc;
        //        [self.navigationController pushViewController:vc animated:YES];
        
        self.numFinished ++;
        
        // set up image view for animation
        self.selectedImageView = [[UIImageView alloc] initWithFrame:fv.frame];
        [self.selectedImageView setAlpha:0];
        [self.selectedImageView setImage:fv.card.image];
        [self.contentView addSubview:self.selectedImageView];
        
        [UIView animateWithDuration:.5 animations:^{
            for (NSInteger i = 0; i < self.scrollViewArray.count; i++) {
                if (i != self.currentPage) {
                    FriendCardView *v =  [self.scrollViewArray objectAtIndex:i];
                    [v setFrame:CGRectOffset(v.frame, self.view.frame.size.width, 0)];
                }
            }
            [self.selectedImageView setAlpha:1];
        } completion:^(BOOL finished) {
            [fv removeFromSuperview];
            
            CGFloat newWidth = self.view.frame.size.width - 60;
            CGPoint center = [self.contentView convertPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2) fromView:self.view];
            CGRect newImageFrame = CGRectMake(center.x - newWidth/2 , center.y - newWidth/2, newWidth, newWidth);
            
            self.contentViewNameLabel = [TableTalkUtil tableTalkLabelWithFrame:CGRectMake(0, newImageFrame.origin.y + newImageFrame.size.height + 10, self.contentView.frame.size.width, 40)
                                                                      fontSize:18
                                                                          text:[NSString stringWithFormat:@"Your card: %@", fv.card.name]];
            [self.contentViewNameLabel setAlpha:0];
            [self.contentView addSubview:self.contentViewNameLabel];
            
            self.contentViewNumFinishedLabel = [TableTalkUtil tableTalkLabelWithFrame:CGRectMake(0, self.contentView.frame.size.height - 64, self.contentView.frame.size.width, 64)
                                                                             fontSize:16
                                                                                 text:[NSString stringWithFormat:@"%d/%d players have chosen", self.numFinished,[TableTalkUtil instance].players.count]];
            [self.contentViewNumFinishedLabel setAlpha:0];
            [self.contentView addSubview:self.contentViewNumFinishedLabel];
            
            //            self.contentViewStatusLabel = [TableTalkUtil tableTalkLabelWithFrame:CGRectMake(0, self.contentViewNumFinishedLabel.frame.origin.y - 64, self.contentView.frame.size.width, 64) fontSize:20 text:@"Waiting for all players to finish"];
            //            [self.contentViewStatusLabel setAlpha:0];
            //            [self.contentView addSubview:self.contentViewStatusLabel];
            
            
            [UIView animateWithDuration:.5 animations:^{
                [self.selectedImageView setFrame:newImageFrame];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.5 animations:^{
                    [self.contentViewNameLabel setAlpha:1];
                    //[self.contentViewStatusLabel setAlpha:1];
                    [self.contentViewNumFinishedLabel setAlpha:1];
                }];
            }];
        }];
    } else {
        [self screenTapped:sender];
    }
}

-(void)socketDidReceiveEvent:(SocketIOPacket *)packet
{
    // ZWS-TODO receive playerFinished, and keep stored
    // ZWS-TODO receive startJudging, and go to waitforjudge
    id json = packet.dataAsJSON;
    if ([[json objectForKey:@"name"] isEqualToString:@"roundFinished"]) {
        NSString *fbId = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"winner"];
        NSInteger index;
        for (int i = 0; i < self.choices.count; i++) {
            Choice *choice = [self.choices objectAtIndex:i];
            if ([choice.chosenByFbId isEqualToString:fbId]) {
                index = (NSInteger)i;
            }
        }
        if ([[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"superlatives"]) {
            self.superlatives = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"superlatives"];
        } else {
            self.nextRoundsCards = [[NSMutableArray alloc] init];
            NSArray *nextRoundFbIds = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"friends"];
            for (NSString *fbId in nextRoundFbIds) {
                Card *card = [[Card alloc] initWithFbId:fbId];
                card.delegate = self;
                [self.nextRoundsCards addObject:card];
            }
        }
        
        [self.view bringSubviewToFront:self.judgeChoosingWinnerPhotoScrollView];
        [UIView animateWithDuration:.5 animations:^{
            [self.judgeChoosingWinnerPhotoScrollView setFrame:CGRectMake(0, self.toolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.toolbar.frame.size.height)];
        } completion:^(BOOL finished) {
            [self.judgeChoosingWinnerPhotoScrollView displayWinnerWithCardTapped:index];
            if (self.superlatives) {
                [self performSelector:@selector(showBlackScreenAndTapToPickSuperlative) withObject:Nil afterDelay:2];
            }
        }];
    } else if ([[json objectForKey:@"name"] isEqualToString:@"playerFinished"]) {
        self.numFinished ++;
        [self.contentViewNumFinishedLabel setText:[NSString stringWithFormat:@"%d/%d players have chosen", self.numFinished,[TableTalkUtil instance].players.count]];
        NSString *fbId = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"fbID"];
        NSString *selectedFbId = [[[json objectForKey:@"args"] objectAtIndex:0] objectForKey:@"selectedFriend"];
        Choice *choice = [[Choice alloc] initWithFbId:selectedFbId chosenByFbId:fbId];
        choice.delegate = self;
        [self.choices addObject:choice];
        
        if (self.choices.count == 1) self.currentlyViewing = fbId;
        
        [self.contentViewNumFinishedLabel setText:[NSString stringWithFormat:@"%d/%d players have chosen", self.choices.count,[TableTalkUtil instance].players.count]];
    } else if ([[json objectForKey:@"name"] isEqualToString:@"currentlyViewing"]) {
        NSLog(@"is currently viewing %@", [[json objectForKey:@"args"] objectAtIndex:0]);
        [UIView animateWithDuration:.5 animations:^{
            [self.judgeChoosingWinnerPhotoScrollView scrollToFacebookId:[[json objectForKey:@"args"] objectAtIndex:0]];
        }];
    } else if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"judgePickingSuperlative"]) {
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
    } else if ([[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"startRound"]) {
        self.nextRoundSuperlative = [[[packet dataAsJSON] objectForKey:@"args"] objectAtIndex:0];
        self.isReadyToBeginNextRound = YES;
        if (self.numCardsDownloaded == self.nextRoundsCards.count) {
            [self displayNextRoundGamePhotoScrollViewController];
        }
    }
}

-(void)displayNextRoundGamePhotoScrollViewController
{
    GamePhotoScrollViewController *gvc = [[GamePhotoScrollViewController alloc] initWithCards:self.nextRoundsCards superlative:self.nextRoundSuperlative];
    
    CATransition *transition = [CATransition animation];
    
    transition.duration = .5;
    transition.type = kCATransitionFade;
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController setViewControllers:@[gvc] animated:NO];
}

-(void)didTapOnBlackScreenToBeginSuperlatives
{
    [[TableTalkUtil appDelegate].socket sendJudgePickingNextRoundsSuperlative];
    JudgeViewController *jvc = [[JudgeViewController alloc] initWithPlayers:nil superlatives:self.superlatives];
    
    CATransition *transition = [CATransition animation];
    
    transition.duration = .5;
    transition.type = kCATransitionFade;
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController setViewControllers:@[jvc] animated:NO];
    
}

-(void)showBlackScreenAndTapToPickSuperlative
{
    UIView *blackScreen = [[UIView alloc] initWithFrame:self.view.bounds];
    [blackScreen setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.8]];
    [blackScreen setAlpha:0];
    [self.view addSubview:blackScreen];
    
    UILabel *label = [TableTalkUtil tableTalkLabelWithFrame:blackScreen.bounds fontSize:20 text:@"You are the next judge. Tap to begin picking a superlative"];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setNumberOfLines:0];
    [blackScreen addSubview:label];
    [UIView animateWithDuration:.5 animations:^{
        [blackScreen setAlpha:1];
    }];
    
    for (UIGestureRecognizer *rec in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:rec];
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnBlackScreenToBeginSuperlatives)];
    [self.view addGestureRecognizer:recognizer];
    
}

-(void)displayJudgeSyncScreenPart2
{
    CGFloat newBottomHeight = 64;
    self.judgeChoosingWinnerPhotoScrollView = [[JudgeChoosingWinnerPhotoScrollView alloc] initWithFrame:CGRectMake(0, self.toolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.toolbar.frame.size.height - newBottomHeight) choices:self.choices withDesiredEndingBackgroundColor:self.toolbar.backgroundColor isJudge:NO];
    [self.judgeChoosingWinnerPhotoScrollView setUserInteractionEnabled:NO];
    [self.judgeChoosingWinnerPhotoScrollView scrollToFacebookId:self.currentlyViewing];
    [self.view insertSubview:self.judgeChoosingWinnerPhotoScrollView belowSubview:self.contentView];
    [UIView animateWithDuration:.5 animations:^{
        [self.contentViewNumFinishedLabel setAlpha:0];
        [self.contentView setFrame:CGRectMake(0, self.view.frame.size.height - newBottomHeight, self.view.frame.size.width, newBottomHeight)];
    } completion:^(BOOL finished) {
        [self.contentViewNumFinishedLabel setFrame:self.contentView.bounds];
        [self.contentViewNumFinishedLabel setText:@"Judge is viewing..."];
        [UIView animateWithDuration:.5 animations:^{
            [self.contentViewNumFinishedLabel setAlpha:1];
        } completion:^(BOOL finished) {
        }];
    }];
}

-(void)displayJudgeSyncScreen
{
    [self.view bringSubviewToFront:self.contentView];
    [UIView animateWithDuration:.5 animations:^{
        [self.contentView setFrame:self.view.bounds];
        [self.contentViewNameLabel setAlpha:0];
        [self.selectedImageView setAlpha:0];
        [self.contentViewStatusLabel setAlpha:0];
        [self.contentViewNumFinishedLabel setAlpha:0];
    } completion:^(BOOL finished) {
        [self.contentViewNumFinishedLabel setFrame:self.contentView.bounds];
        [self.contentViewNumFinishedLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.contentViewNumFinishedLabel setText:@"Judge beginning to choose winner."];
        [UIView animateWithDuration:.5 animations:^{
            [self.contentViewNumFinishedLabel setAlpha:1];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(displayJudgeSyncScreenPart2) withObject:nil afterDelay:1];
        }];
    }];
}

-(void)setCurrentlyViewing:(NSString *)currentlyViewing
{
    _currentlyViewing = currentlyViewing;
    [UIView animateWithDuration:.5 animations:^{
        [self.judgeChoosingWinnerPhotoScrollView scrollToFacebookId:currentlyViewing];
    }];
}

-(void)cardDidFinishDownloadingImageAndName:(Card *)card
{
    self.numCardsDownloaded ++;
    
    if (self.numCardsDownloaded == self.nextRoundsCards.count && self.isReadyToBeginNextRound) {
        [self displayNextRoundGamePhotoScrollViewController];
    }
}

-(void)didFinishDownloadingImageAndNameForChoice:(Choice *)choice
{
    self.numChoicesDownloaded ++;
    
    if (self.numChoicesDownloaded == [TableTalkUtil instance].players.count) {
        //[self displayJudgeSyncScreen];
        [self performSelector:@selector(displayJudgeSyncScreen) withObject:nil afterDelay:2];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
