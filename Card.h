//
//  Card.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/20/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;

@protocol CardDelegate

-(void)cardDidFinishDownloadingImageAndName:(Card *)card;

@end

@interface Card : NSObject

-(id)initWithFbId:(NSString *)fbId;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fbId;
@property (nonatomic, weak) id<CardDelegate> delegate;

@end
