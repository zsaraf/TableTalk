//
//  Card.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 12/20/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "Card.h"
#import "SDWebImageManager.h"
#import "TableTalkUtil.h"
#import "AFHTTPRequestOperation.h"

@implementation Card

-(id)initWithFbId:(NSString *)fbId
{
    if (self = [super init]) {
        self.fbId = fbId;
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:GRAPH_SEARCH_URL_FORMAT, fbId]];
        [manager downloadWithURL:url options:0 progress:^(NSUInteger receivedSize, long long expectedSize){
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            [self setImage:image];
            if (self.name) {
                [self.delegate cardDidFinishDownloadingImageAndName:self];
            }
        }];
        NSURL *linkURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@?fields=name", fbId]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:linkURL];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self setName:[responseObject objectForKey:@"name"]];
            if (self.image) {
                [self.delegate cardDidFinishDownloadingImageAndName:self];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
    }
    return self;
}

@end
