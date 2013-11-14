//
//  FriendCardScrollView.m
//  Table Talk
//
//  Created by Zachary Waleed Saraf on 10/29/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "FriendCardView.h"
#import "AMBlurView.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Crop.h"
#import "SDWebImageManager.h"
#import "BlurUtils.h"

@interface FriendCardView ()

@property (nonatomic, strong) NSURLConnection *linkConnection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, assign) BOOL isLast;
@property (nonatomic, strong) UIView *transparentNameView;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation FriendCardView

@synthesize labelHeight = _labelHeight;
@synthesize blurredImageViewAlpha = _blurredImageViewAlpha;

- (id)initWithFrame:(CGRect)frame
{
    //NSAssert(0, @"dont use this");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFBId:(NSString *)fbID andIndex:(NSInteger)index isLast:(BOOL)isLast
{
    if (self = [super init])
    {
        self.clipsToBounds = YES;
        self.fbID = fbID;
        self.data = [[NSMutableData alloc] init];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:GRAPH_SEARCH_URL_FORMAT, fbID]];
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:url options:0
                    progress:^(NSUInteger receivedSize, long long expectedSize) {
                    
                    }
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                        if (image) {
                            self.img = image;
                            [self connectionDidFinishLoading:nil];
                        }
                    }];
        
        NSURL *linkURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@?fields=name", self.fbID]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:linkURL];
        self.linkConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        self.index = index;
        self.imgView = [[UIImageView alloc] init];
        [self.imgView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:self.imgView];
        self.isLast = isLast;
        
        self.transparentNameView = [[UIView alloc] init];
        [self.transparentNameView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.3]];
        [self.transparentNameView setAlpha:1.];
        [self addSubview:self.transparentNameView];
        
        self.blurredImageViewWrapper = [[UIView alloc] init];
        [self.blurredImageViewWrapper setClipsToBounds:YES];
        [self addSubview:self.blurredImageViewWrapper];
        
        self.blurredImageView = [[UIImageView alloc] init];
        [self.blurredImageViewWrapper addSubview:self.blurredImageView];
        
        if (!self.name) self.name = @"";
        
        self.nameLabel = [[UILabel alloc] init];
        [self.nameLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self fixNameLabelSizeForName];
        [self.nameLabel setTextColor:[UIColor whiteColor]];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self insertSubview:self.nameLabel aboveSubview:self.transparentNameView];
    }
    return self;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

-(void)fixNameLabelSizeForName
{
    if (self.nameLabel == nil || [self.name isEqualToString:@""]) {
        return;
    }
    
    CGSize size = [self.name sizeWithAttributes:@{NSFontAttributeName:self.nameLabel.font}];
    [self.nameLabel setFrame:CGRectMake((1 -self.blurredImageViewAlpha) * (self.frame.size.width - size.width), self.frame.size.height - self.labelHeight, size.width, self.labelHeight)];
    [self.nameLabel setText:self.name];
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
    if (connection == self.linkConnection) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&error];
        self.name = [dict objectForKey:@"name"];
        [self fixNameLabelSizeForName];
        return;
    }
    
    [self.imgView setImage:self.img];
    [self.blurredImageView setImage:[BlurUtils drawBlur:self.imgView size:self.bounds.size]];
    [self.delegate didFinishLoadingImage:self.img forIndex:self.index];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.imgView setFrame:CGRectMake(0, self.frame.size.height/2* self.blurredImageViewAlpha, self.frame.size.width, self.frame.size.height)];
    [self correctLabelViews];
}

-(void)correctLabelViews
{
    CGRect frame = CGRectMake(0, self.frame.size.height - self.labelHeight, self.frame.size.width, self.labelHeight);
    [self.transparentNameView setFrame:frame];
    [self.blurredImageView setFrame:CGRectMake(0, -self.frame.size.height + self.frame.size.height/2* self.blurredImageViewAlpha + self.labelHeight, self.frame.size.width, self.frame.size.height)];
    [self.blurredImageViewWrapper setFrame:frame];
    
    CGRect labelFrame = self.nameLabel.frame;
    labelFrame.origin.y = self.frame.size.height - self.labelHeight;
    labelFrame.origin.x = (1 - self.blurredImageViewAlpha) * (self.frame.size.width - labelFrame.size.width);
    [self.nameLabel setFrame:labelFrame];

}

-(void)setLabelHeight:(CGFloat)labelHeight
{
    _labelHeight = labelHeight;
    [self correctLabelViews];
}

-(void)setBlurredImageViewAlpha:(CGFloat)blurredImageViewAlpha
{
    _blurredImageViewAlpha = blurredImageViewAlpha;
    if (!self.blurredImageView || !self.imgView || CGSizeEqualToSize(self.bounds.size, CGSizeZero)) return;
    [self.blurredImageViewWrapper setAlpha:blurredImageViewAlpha];
    [self.imgView setFrame:CGRectMake(0, self.frame.size.height/2* blurredImageViewAlpha, self.frame.size.width, self.frame.size.height)];
    [self.blurredImageView setFrame:CGRectMake(0, -self.frame.size.height + self.frame.size.height/2* blurredImageViewAlpha + self.labelHeight, self.frame.size.width, self.frame.size.height)];
    if (blurredImageViewAlpha == 0) {
        [self bringSubviewToFront:self.nameLabel];
    }
    
    CGRect labelFrame = self.nameLabel.frame;
    labelFrame.origin.x = (1 - self.blurredImageViewAlpha) * (self.frame.size.width - labelFrame.size.width);
    [self.nameLabel setFrame:labelFrame];
}

@end
