//
//  Choice.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/16/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "Choice.h"
#import "SDWebImageManager.h"
#import "TableTalkUtil.h"
#import <AFNetworking.h>

@implementation Choice

-(id)initWithFbId:(NSString *)fbId chosenByFbId:(NSString *)chosenByFbId
{
    if (self = [super init]) {
        self.fbId = fbId;
        self.chosenByFbId = chosenByFbId;
        
        if (self.fbId.length == 0) return self;
        // handle downloading
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:GRAPH_SEARCH_URL_FORMAT, fbId]];
        [manager downloadWithURL:url options:0 progress:^(NSUInteger receivedSize, long long expectedSize){
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if (error) {
                NSAssert(0, @"failure downloading image of fbID %@", fbId);
            }
            [self setImage:image];
            if (self.name) {
                [self.delegate didFinishDownloadingImageAndNameForChoice:self];
            }
        }];
        NSURL *linkURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@?fields=name", fbId]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:linkURL];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self setName:[responseObject objectForKey:@"name"]];
            if (self.image) {
                [self.delegate didFinishDownloadingImageAndNameForChoice:self];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSAssert(0, @"failure downloading name of fbID %@", fbId);
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
        
    }
    return self;
}

@end
