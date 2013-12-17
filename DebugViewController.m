//
//  DebugViewController.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "DebugViewController.h"
#import "JudgeChoosingWinnerPhotoScrollView.h"
#import "Choice.h"

@interface DebugViewController ()

@end

@implementation DebugViewController

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
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableArray *choices = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; i ++) {
        Choice *choice = [[Choice alloc] initWithFbId:@"" chosenByFbId:@""];
        choice.image = [UIImage imageNamed:@"debugImage.jpg"];
        choice.name = [NSString stringWithFormat:@"Name %d", i];
        [choices addObject:choice];
    }
    JudgeChoosingWinnerPhotoScrollView *v = [[JudgeChoosingWinnerPhotoScrollView alloc] initWithFrame:self.view.bounds choices:choices];
    [self.view addSubview:v];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
