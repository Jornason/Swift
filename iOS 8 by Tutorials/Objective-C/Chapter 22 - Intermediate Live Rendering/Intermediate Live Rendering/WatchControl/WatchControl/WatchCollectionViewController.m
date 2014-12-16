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

#import "WatchCollectionViewController.h"
#import "WatchView.h"
#import "WatchCollectionViewCell.h"
@interface WatchCollectionViewController ()
@property (nonatomic, strong) NSMutableArray *listOfClocks;
@end

@implementation WatchCollectionViewController

static NSString * const reuseIdentifier = @"WatchCollectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
		self.listOfClocks = [NSMutableArray arrayWithArray:[self createDefaultWatches]];
    // Register cell classes
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.listOfClocks count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WatchCollectionViewCell *cell = (WatchCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
	WatchView *watchView = self.listOfClocks[indexPath.row];
	if (watchView != nil) {
		[cell.watchView copyClockSettingsWithWatchView:watchView];
		[cell.timezoneLabel setText:watchView.currentTimeZone];
		[cell.watchView startTimeWithTimeZone:watchView.currentTimeZone];
		[cell.watchView setNeedsLayout];
		[cell.watchView layoutIfNeeded];
	}
	
	return cell;
}

#pragma mark <UICollectionViewDelegate>

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
												layout:(UICollectionViewLayout *)collectionViewLayout
				insetForSectionAtIndex:(NSInteger)section {
	if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
		return UIEdgeInsetsMake(80, 80, 80, 80);
	} else {
		return UIEdgeInsetsMake(30, 10, 10, 10);
	}
}

#pragma mark - Settings View Controller Delegate
- (void)didCreateNewClockSettings:(NSMutableDictionary *)dict
{
	[self.listOfClocks addObject: dict];
	[self.collectionView reloadData];
}

#pragma mark - Default Preloaded Watches
- (NSArray *)createDefaultWatches {
	WatchView *watch1 = [[WatchView alloc] init];
	watch1.enableAnalogDesign = YES;
	watch1.enableClockSecondHand = YES;
	watch1.ringThickness = 2.0;
	watch1.ringColor = [UIColor colorWithRed:97.0/255.0 green:171.0/255.0 blue:250.0/255.0 alpha:1.0];
	watch1.ringProgress = 45.0;
	watch1.hourHandColor = [UIColor whiteColor];
	watch1.minuteHandColor = [UIColor whiteColor];
	watch1.secondHandColor = [UIColor redColor];
	watch1.backgroundImage = [UIImage imageNamed:@"test2.jpg"];
	watch1.currentTimeZone = @"Asia/Singapore";
	watch1.lineWidth = 1.0;
	watch1.ringThickness = 4.0;
	
	WatchView *watch2 = [[WatchView alloc] init];
	[watch2  copyClockSettingsWithWatchView:watch1];
	watch2.currentTimeZone = @"America/Chicago";
	watch2.backgroundImage = [UIImage imageNamed:@"test1.jpg"];
	watch2.enableClockSecondHand = NO;
	
	WatchView *watch3 = [[WatchView alloc] init];
	[watch3 copyClockSettingsWithWatchView:watch1];
	watch3.currentTimeZone = @"America/New_York";
	watch3.backgroundImage = [UIImage imageNamed:@"test3.jpg"];
	watch3.enableAnalogDesign = NO;
	
	return @[watch1, watch2, watch3];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"presentSettingsVC"])
	{
		SettingsViewController *settingsViewController = [segue destinationViewController];
		settingsViewController.delegate = self;
	}
}

- (IBAction)createNewWatch:(id)sender {
	[self performSegueWithIdentifier:@"presentSettingsVC" sender:self];
	
}
@end
