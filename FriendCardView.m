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

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, assign) BOOL isLast;
@property (nonatomic, strong) UIView *transparentNameView;

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
        self.imageData = [[NSMutableData alloc] init];
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
        
       /* NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                              timeoutInterval:2.0f];
        // Run network request asynchronously
        self.connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];*/
        self.index = index;
        self.imgView = [[UIImageView alloc] init];
        [self.imgView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:self.imgView];
        self.isLast = isLast;
        
        self.transparentNameView = [[UIView alloc] init];
        [self.transparentNameView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.3]];
        [self.transparentNameView setAlpha:1.];
        [self addSubview:self.transparentNameView];
        
        self.blurredImageView = [[UIImageView alloc] init];
        [self addSubview:self.blurredImageView];
    }
    return self;
}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imageData appendData:data]; // Build the image
}

-(UIImage *)drawBlur
{
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    [self.imgView drawViewHierarchyInRect:self.imgView.frame afterScreenUpdates:YES];
    
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    UIGraphicsEndImageContext();
    blurredSnapshotImage = [blurredSnapshotImage cropFromRect:CGRectMake(0, 5*snapshotImage.size.height/6, snapshotImage.size.width, snapshotImage.size.height/6)];
    
    return blurredSnapshotImage;
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
    //self.img = [UIImage imageWithData:self.imageData];
    [self.imgView setImage:self.img];
    //[self.blurredImageView setImage:[self drawBlur]];
    [self.blurredImageView setImage:[BlurUtils drawBlur:self.imgView size:self.bounds.size cropRect:CGRectMake(0, 5/6.0, 1, 1/6.0)]];
    [self.delegate didFinishLoadingImage:self.img forIndex:self.index];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    //[self.imgView setFrame:self.bounds];
    [self.imgView setFrame:CGRectMake(0, self.frame.size.height/2* self.blurredImageViewAlpha, self.frame.size.width, self.frame.size.height)];
    [self correctLabelViews];
}

-(void)correctLabelViews
{
    [self.blurredImageView setFrame:CGRectMake(0, self.frame.size.height - self.labelHeight, self.frame.size.width, self.labelHeight)];
    [self.transparentNameView setFrame:CGRectMake(0, self.frame.size.height - self.labelHeight, self.frame.size.width, self.labelHeight)];
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
    [self.blurredImageView setAlpha:blurredImageViewAlpha];
    [self.imgView setFrame:CGRectMake(0, self.frame.size.height/2* blurredImageViewAlpha, self.frame.size.width, self.frame.size.height)];
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
