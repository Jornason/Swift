/*
 * Copyright (c) 2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "RWTImgurImageViewController.h"
#import "UIImageView+WebCache.h"
#import "RWTSavedImageService.h"

@interface RWTImgurImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation RWTImgurImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.imgurImage.title;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveImage:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak RWTImgurImageViewController *weakSelf = self;
    [self.imageView setImageWithURL:self.imgurImage.link placeholderImage:nil options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        float progress = (float)receivedSize/(float)expectedSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.progressView setProgress:progress animated:YES];
        });
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (error) {
            NSLog(@"Error loading image at %@: %@", weakSelf.imgurImage.link.absoluteString, error);
        }
        
        weakSelf.progressView.hidden = YES;
        weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

- (void)saveImage:(UIBarButtonItem *)buttonItem {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    RWTSavedImageService *savedImageService = [[RWTSavedImageService alloc] init];
    [savedImageService saveImage:self.imageView.image name:self.imgurImage.imgurId];
}

@end
