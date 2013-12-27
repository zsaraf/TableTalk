//
//  DisplayScoresTableView.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/18/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "DisplayScoresTableView.h"
#import "PlayerScoreTableViewCell.h"

#define CELL_SIZE 44

@interface DisplayScoresTableView ()

@property (nonatomic, strong) NSMutableArray *scoresArray;
@property (nonatomic, strong) UIColor *textColor;

@end

@implementation DisplayScoresTableView

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor winningPlayer:(Player *)winningPlayer;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = backgroundColor;
        self.textColor = textColor;
        
        self.winningPlayer = winningPlayer;
        
        self.scoresArray = [[NSMutableArray alloc] init];
        for (NSString *fbId in [TableTalkUtil instance].players) {
            [self.scoresArray addObject:[[TableTalkUtil instance].players objectForKey:fbId]];
        }
        [self.scoresArray addObject:[TableTalkUtil instance].me];
        [self.scoresArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Player *player1 = (Player *)obj1;
            Player *player2 = (Player *)obj2;
            
            return player2.score - player1.score;
        }];
        self.delegate = self;
        self.dataSource = self;
        self.separatorColor = [UIColor clearColor];
        self.separatorInset = UIEdgeInsetsMake(0, CELL_SIZE, 0, CELL_SIZE);
    }
    return self;
}

-(void)setDelegate:(id<UITableViewDelegate>)delegate
{
    //NSAssert(delegate == self, @"score table view needs to be its own delegate");
    
    [super setDelegate:delegate];
}

-(void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    NSAssert(dataSource == self, @"score table view needs to be its own data source");
    
    [super setDataSource:dataSource];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 0) return 0;
    return self.scoresArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"playerScoreTableViewCell";
    PlayerScoreTableViewCell *tableViewCell = [self dequeueReusableCellWithIdentifier:identifier];
    if (!tableViewCell) {
        tableViewCell = [[PlayerScoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [tableViewCell setTextColor:self.textColor];
        [tableViewCell setUserInteractionEnabled:NO];
    }
    
    Player *player = [self.scoresArray objectAtIndex:indexPath.item];
    [tableViewCell setPlayer:player isWinningPlayer:player == self.winningPlayer];
    return tableViewCell;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
