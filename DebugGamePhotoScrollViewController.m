//
//  DebugGamePhotoScrollViewController.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/20/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "DebugGamePhotoScrollViewController.h"

@interface DebugGamePhotoScrollViewController ()

@property (nonatomic, strong) NSMutableArray *cards;

@end

@implementation DebugGamePhotoScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)cardDidFinishDownloadingImageAndName:(Card *)card
{
    static int counter = 0;
    counter ++;
    
    if (counter == self.cards.count) {
        GamePhotoScrollViewController *gvc = [[GamePhotoScrollViewController alloc] initWithCards:self.cards superlative:@"Great dick"];
        [self.navigationController pushViewController:gvc animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.cards = [[NSMutableArray alloc] init];
    
    NSArray *players = [NSArray arrayWithObjects:@"521242550",@"521827780",@"524372404",@"524693200",@"524747587", @"588688409", @"1323098301", nil];
    
    for (NSString *fbId in players) {
        Card *card = [[Card alloc] initWithFbId:fbId
                      ];
        card.delegate = self;
        [self.cards addObject:card];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
