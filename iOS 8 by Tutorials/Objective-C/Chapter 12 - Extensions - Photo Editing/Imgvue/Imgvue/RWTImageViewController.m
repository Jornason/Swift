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

#import "RWTImageViewController.h"
#import "RWTSavedImageService.h"
#import "RWTImageFilterService.h"

@interface RWTImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) RWTImageFilterService *filterService;
@property (strong, nonatomic) UIImage *filteredImage;

@end

@implementation RWTImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.imageView setImage:self.image];
    
    UIBarButtonItem *addFilterBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Filter" style:UIBarButtonItemStylePlain target:self action:@selector(addFilter:)];
    self.navigationItem.rightBarButtonItem = addFilterBarButtonItem;
    
    self.filterService = [[RWTImageFilterService alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)addFilter:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Filter" message:@"Choose a filter to apply to the image." preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak RWTImageViewController *weakSelf = self;
    [self.filterService.availableFilters enumerateKeysAndObjectsUsingBlock:^(NSString *displayName, NSString *filterName, BOOL *stop) {
        UIAlertAction *filterAction = [UIAlertAction actionWithTitle:displayName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            weakSelf.filteredImage = [weakSelf.filterService applyFilter:filterName toImage:weakSelf.image];
            [weakSelf.imageView setImage:weakSelf.filteredImage];
        }];
        
        [alertController addAction:filterAction];
    }];
    
    UIAlertAction *noneAction = [UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [weakSelf.imageView setImage:weakSelf.image];
    }];
    [alertController addAction:noneAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
