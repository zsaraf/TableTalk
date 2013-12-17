//
//  Choice.h
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Choice;

@protocol ChoiceDelegate

-(void)didFinishDownloadingImageAndNameForChoice:(Choice *)choice;

@end

@interface Choice : NSObject


-(id)initWithFbId:(NSString *)fbId chosenByFbId:(NSString *)chosenByFbId;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fbId;
@property (nonatomic, strong) NSString *chosenByFbId;
@property (nonatomic, weak) id<ChoiceDelegate> delegate;

@end
