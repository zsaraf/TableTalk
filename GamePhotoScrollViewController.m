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
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIImageView+WebCache.h"
#import "FriendCardView.h"

@interface GamePhotoScrollViewController ()


@property (nonatomic, strong) NSMutableArray *scrollViewArray;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isJudging;
@property (nonatomic, assign) NSInteger numPhotosLoaded;
@property (nonatomic, strong) UIView *blackView;

@property (nonatomic, assign) CGFloat firstY;
@property (nonatomic, assign) CGFloat currentY;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, weak) FriendCardView *current;
@property (nonatomic, assign) CGFloat screenWidth;

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
        self.scrollViewArray = [[NSMutableArray alloc] init];
        self.isJudging = isJudge;
        [TableTalkUtil appDelegate].socket.delegate = self;
        
        self.contentView = [[UIView alloc] init];
        int index = 0;
        for (NSString *fbID in fbIDs) {
            FriendCardView *sv = [[FriendCardView alloc] initWithFBId:fbID andIndex:index isLast:(index == fbIDs.count - 1)];
            sv.delegate = self;
            [self.scrollViewArray addObject:sv];
            [self.contentView insertSubview:sv atIndex:0];
            index ++;
        }
        
    }
    return self;
}

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
}

-(IBAction)screenTapped:(UITapGestureRecognizer *)sender
{
    NSLog(@"screen tapped");
    UIView *v = [self.contentView hitTest:[sender locationInView:self.contentView] withEvent:nil];
    while (![v isKindOfClass:[FriendCardView class]]) v = v.superview;
    FriendCardView *fv = (FriendCardView *)v;
    
    if (fv.index == self.currentPage) {
        WaitForJudgeViewController *vc = [[WaitForJudgeViewController alloc] init];
        [TableTalkUtil appDelegate].socket.delegate = vc;
        [self.navigationController pushViewController:vc animated:YES];
        [[TableTalkUtil appDelegate].socket sendChoseFriendMessage:fv.fbID];
        return;
    }
    
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
    CGFloat nameHeight = (self.contentView.frame.size.height - self.screenWidth)/(self.scrollViewArray.count - 1);
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
    
    // beginning of toolbar code
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [self.toolbar setBarTintColor:[UIColor colorWithRed:39/255. green:144/255. blue:210/255. alpha:1.]]; //rgba(44, 62, 80,1.0)
    [self.toolbar setTranslucent:NO];
    NSString *superlativeString = @"Best Smile";
    UIFont *myFont = [UIFont fontWithName:@"Futura-Medium" size:25];
    CGSize size = [superlativeString sizeWithAttributes:@{NSFontAttributeName:myFont}];
    CGFloat verticalPadding = (self.toolbar.frame.size.height - size.height)/2;
    UILabel *superlativeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, verticalPadding, self.toolbar.frame.size.width, self.toolbar.frame.size.height - 2 * verticalPadding)];
    [superlativeLabel setText:superlativeString];
    [superlativeLabel setFont:myFont];
    [superlativeLabel setTextAlignment:NSTextAlignmentCenter];
    [superlativeLabel setTextColor:[UIColor whiteColor]];
    
    UIView *labelBckgdView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, self.toolbar.frame.size.height - 10)];
    [labelBckgdView addSubview:superlativeLabel];
    UIBarButtonItem *superlative = [[UIBarButtonItem alloc] initWithCustomView:labelBckgdView];
    self.toolbar.items = [NSArray arrayWithObjects:
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          superlative,
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          nil];
    [self.view addSubview:self.toolbar];
    // end of toolbar code
    
    // beginning of content code
    [self.contentView setFrame:CGRectMake(0, self.toolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.toolbar.frame.size.height)];
    [self.view addSubview:self.contentView];
    CGFloat nameHeight = (self.contentView.frame.size.height - self.screenWidth)/(self.scrollViewArray.count - 1);
    for (int i = 0; i < self.scrollViewArray.count; i++) {
        FriendCardView *sv = [self.scrollViewArray objectAtIndex:i];
        [sv setLabelHeight:nameHeight];
        CGFloat x = 2*(i % 2) - 1;
        //if (i == 0) sv.blurredImageViewAlpha = 0.;
        //else sv.blurredImageViewAlpha = 1.0;
        sv.blurredImageViewAlpha = 0.;
        [sv setFrame:CGRectMake(x * self.screenWidth, (i)*nameHeight, self.contentView.frame.size.width, self.screenWidth)];
    }
    
    self.currentPage = 0;
    
    self.blackView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    [self.blackView setBackgroundColor:[UIColor blackColor]];
    [self.contentView addSubview:self.blackView];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setFrame:CGRectInset(self.contentView.bounds, 100, 100)];
    [self.blackView addSubview:indicator];
    [indicator startAnimating];
    
    [self.view bringSubviewToFront:self.toolbar];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoDoubleTapped:)];
    [recognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:recognizer];
    
    
}



-(IBAction)photoDoubleTapped:(UITapGestureRecognizer *)sender
{
    NSLog(@"photo doubel tapped");
    /*NSInteger friendIndex = self.photoScrollView.contentOffset.x/self.photoScrollView.frame.size.width;
     // ZWS-TODO Judge will never be in this screen, remove following.
    if (self.isJudging) {
        [[TableTalkUtil appDelegate].socket sendChoseWinnerMessage:[self.card_fbIDs objectAtIndex:friendIndex]];
    } else {
        WaitForJudgeViewController *vc = [[WaitForJudgeViewController alloc] init];
        [TableTalkUtil appDelegate].socket.delegate = vc;
        [self.navigationController pushViewController:vc animated:YES];
        [[TableTalkUtil appDelegate].socket sendChoseFriendMessage:[self.card_fbIDs objectAtIndex:friendIndex]];
    }*/
}

-(void)socketDidReceiveEvent:(SocketIOPacket *)packet
{
    // ZWS-TODO receive playerFinished, and keep stored
    // ZWS-TODO receive startJudging, and go to waitforjudge
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
