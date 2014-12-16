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

#import "SettingsViewController.h"
#import "TimezoneTableViewCell.h"
#import "WatchView.h"
#import "ColorPickerViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *portraitLayoutConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *landscapeLayoutConstraints;

@property (strong, nonatomic) NSArray *timezoneNames;

@property (strong, nonatomic) IBOutlet WatchView *watchView;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) UIColor *selectedColor;
@property (strong, nonatomic) NSString *selectedTimeZone;
@property (strong, nonatomic) IBOutlet UISegmentedControl *faceTypeSegmentedControl;

- (IBAction)selectClockSecondsType:(id)sender;
- (IBAction)selectClockBackground:(id)sender;
- (IBAction)selectClockDesign:(id)sender;

@end

@implementation SettingsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Default Selected Timezone
    self.selectedTimeZone = @"Asia/Singapore";
    
    // Get the current local time to start the timer.
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    [self.watchView startTimeWithTimeZone:[currentTimeZone name]];

    //Create right button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addWatchToList)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self applyConstraintsBasedOnViewWith:self.view.bounds.size];
}

- (void)addWatchToList
{
    [self.watchView endTime];
    
    [self.delegate didCreateNewClockSettings:self.watchView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)selectClockSecondsType:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    switch (selectedSegment) {
        case 0:
            [self.watchView setEnableClockSecondHand:YES];
            break;
        case 1:
            [self.watchView setEnableClockSecondHand:NO];
            break;

    }
    [self.watchView setNeedsLayout];
    [self.watchView layoutIfNeeded];
    
}

#pragma mark - Image Face or Color Face Selection

- (IBAction)selectClockBackground:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    switch (selectedSegment) {
        //Changes the watch faces image.
        case 0:
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"Cannot access Saved Photos on device :["
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil] show];
            } else {
                UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
                photoPicker.delegate = self;
                photoPicker.allowsEditing = YES;
                photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self showDetailViewController:photoPicker sender:self];
            }
            break;
        //Changes the watch faces background color
        case 1:
            [self performSegueWithIdentifier:@"presentColorPicker" sender:self];
						self.faceTypeSegmentedControl.selectedSegmentIndex = 0;
            break;
    }
}

- (IBAction)selectClockDesign:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    switch (selectedSegment) {
        case 0:
            [self.watchView setEnableAnalogDesign:YES];
            break;
            
        case 1:
            [self.watchView setEnableAnalogDesign:NO];
            break;
    }
    [self.watchView startTimeWithTimeZone:[NSTimeZone localTimeZone].name];
    [self.watchView setNeedsLayout];
    [self.watchView layoutIfNeeded];
}

#pragma mark - UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        //Enable image background.
        self.watchView.backgroundImage = info[UIImagePickerControllerEditedImage];
        self.selectedImage = info[UIImagePickerControllerEditedImage];
        self.watchView.enableColorBackground = NO;
        
        //Update settings clock to show correct results
        [self.watchView setNeedsLayout];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
		[self dismissViewControllerAnimated:YES completion:nil];
		self.faceTypeSegmentedControl.selectedSegmentIndex = 1;
}


#pragma mark - Color Picker Delegate

- (void)didSelectColor:(UIColor *)color
{
    //Enable color background.
		if (color) {
				self.watchView.backgroundLayerColor = color;
				self.selectedColor = color;
				[self.watchView setNeedsLayout];
				[self.watchView layoutIfNeeded];
				self.watchView.enableColorBackground = YES;
				self.faceTypeSegmentedControl.selectedSegmentIndex = 1;
		} else {
			self.faceTypeSegmentedControl.selectedSegmentIndex = 0;
		}
}

#pragma mark - TimeZoneTableViewController Delegate
- (void)didSelectATimeZone:(NSString *)timeZone {
    self.watchView.currentTimeZone = timeZone;
    [self.navigationController popViewControllerAnimated:YES];
    [self.watchView startTimeWithTimeZone:timeZone];
}


- (IBAction)showListOfTimeZone:(id)sender {
    [self performSegueWithIdentifier:@"showTimeZones" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"presentColorPicker"])
    {
        ColorPickerViewController *colorPickerViewController = [segue destinationViewController];
        colorPickerViewController.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"showTimeZones"]) {
        TimeZoneTableViewController *timeZoneTableViewController = [segue destinationViewController];
        timeZoneTableViewController.delegate = self;
    }
}

#pragma mark - Adaptive UI Device Rotations Constraint Handling

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	[self applyConstraintsBasedOnViewWith:size];
}

#pragma mark - Constraint Helper Methods
- (void)applyConstraintsBasedOnViewWith:(CGSize)size
{
	BOOL transitionToWide = size.width > size.height;
	if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
		NSArray *constraintsToUnistall = transitionToWide ? self.portraitLayoutConstraints : self.landscapeLayoutConstraints;
		NSArray *constraintsToInstall = transitionToWide ? self.landscapeLayoutConstraints : self.portraitLayoutConstraints;
		[self.view layoutIfNeeded];
		
		[NSLayoutConstraint deactivateConstraints:constraintsToUnistall];
		[NSLayoutConstraint activateConstraints:constraintsToInstall];
	}
}
@end
