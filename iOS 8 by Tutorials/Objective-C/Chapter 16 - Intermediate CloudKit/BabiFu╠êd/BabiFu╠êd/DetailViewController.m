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


#import "DetailViewController.h"
@import UIWidgets;


#import "NotesViewController.h"
#import "Model.h"

NS_OPTIONS(NSUInteger, InputFlags) {
  CameraFlag = 1 << UIImagePickerControllerSourceTypeCamera,
  PhotoAlbumFlag = 1 << UIImagePickerControllerSourceTypePhotoLibrary
};

@interface DetailViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic) BOOL uploading;
@property (nonatomic) NSUInteger sourceTypes;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    
    // Update the view.
    [self configureView];
  }
  
  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }
}

- (void) configureView {
  self.title = self.detailItem.name;
  self.titleLabel.text = self.detailItem.name;
  
  [self.detailItem loadCoverPhoto:^(UIImage *photo) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.coverView.image = photo;
    });
  }];
  
  self.starRating.maxRating = 5;
  self.starRating.enabled = NO;
  
  [[Model model].user loggedInToICloud:^(CKAccountStatus accountStatus, NSError *error) {
    BOOL enabled = accountStatus == CKAccountStatusAvailable;
    self.starRating.enabled = enabled;
    self.healthyChoiceButton.enabled = enabled;
    self.kidsMenuButton.enabled = enabled;
    self.mensRoomButton.enabled = enabled;
    self.womensRoomButton.enabled = enabled;
    self.boosterButton.enabled = enabled;
    self.highchairButton.enabled = enabled;
    self.addPhotoButton.enabled = enabled;
  }];
  
  self.kidsMenuButton.checked = self.detailItem.hasKidsMenu;
  self.healthyChoiceButton.checked = self.detailItem.hasHealthyOptions;
  self.womensRoomButton.selected = self.detailItem.changingTableType & ChangingTableTypeWomens;
  self.mensRoomButton.selected = self.detailItem.changingTableType & ChangingTableTypeMens;
  self.highchairButton.selected = self.detailItem.seatingType & SeatingTypeHighChair;
  self.boosterButton.selected = self.detailItem.seatingType & SeatingTypeBooster;
  
  [self.detailItem fetchRating:^(double rating, BOOL isUser) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.starRating.maxRating = 5;
      self.starRating.rating = rating;
      [self.starRating setNeedsDisplay];
      
      self.starRating.emptyColor = isUser ? [UIColor yellowColor] : [UIColor whiteColor];
      self.starRating.solidColor = isUser ? [UIColor yellowColor] : [UIColor whiteColor];
    });
  }];
  
  [self.detailItem fetchPhotos:^(NSArray *assets) {
    if (assets) {
      CGFloat x = 10;
      for (CKRecord* record in assets) {
        CKAsset* asset = record[@"Photo"];
        UIImage* image = [UIImage imageWithContentsOfFile:asset.fileURL.path];
        if (image) {
          UIImageView* imView = [[UIImageView alloc] initWithImage:image];
          imView.frame = CGRectMake(x, 0, 60, 60);
          imView.clipsToBounds = YES;
          imView.layer.cornerRadius = 8.0;
          imView.layer.borderWidth = 0.;
          x += 70;
          
          //if the user has discovered the photo poster, color the photo with a green border
          CKReference* photoUserRef = record[@"User"];
          CKRecordID* photoUserId = photoUserRef.recordID;
          NSArray* contacts = [[[Model model].user contacts] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CKDiscoveredUserInfo* evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject.userRecordID isEqual:photoUserId];
          }]];
          if (contacts.count > 0) {
            imView.layer.borderWidth = 1.0;
            imView.layer.borderColor = [UIColor greenColor].CGColor;
          }
          
          dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoScrollView addSubview:imView];
          });
        }
      }
    }
  }];
  
  [self.detailItem fetchNote:^(NSString *note) {
    if (note) {
      dispatch_async(dispatch_get_main_queue(), ^{
        self.noteTextView.text = note;
      });
    }
  }];
}

- (void) saveRating:(NSNumber*)rating {
  CKRecord* ratingRecord = [[CKRecord alloc] initWithRecordType:@"Rating"];
  ratingRecord[@"Rating"] = rating;
  
  CKReference* ref = [[CKReference alloc] initWithRecord:self.detailItem.record action:CKReferenceActionDeleteSelf];
  ratingRecord[@"Establishment"] = ref;
  
  [[Model model].user userID:^(CKRecordID *recordID, NSError *error) {
    if (recordID) {
      CKReference* userRef = [[CKReference alloc] initWithRecordID:recordID action:CKReferenceActionNone];
      ratingRecord[@"User"] = userRef;
      
      [self.detailItem.database saveRecord:ratingRecord completionHandler:^(CKRecord *record, NSError *error) {
        if (error != nil) {
          NSLog(@"error saving rating: %@", error);
        } else {
          dispatch_async(dispatch_get_main_queue(), ^{
            //use yellow to signify the user's rating
            self.starRating.emptyColor = [UIColor yellowColor];
            self.starRating.solidColor = [UIColor yellowColor];
            [self.starRating setNeedsDisplay];
          });
        }
      }];
    }
  }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.coverView.clipsToBounds = YES;
  self.coverView.layer.cornerRadius = 10.0;
  
  self.starRating.editingChangedBlock = ^(NSUInteger rating) {
    [self saveRating:@(rating)];
  };
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self configureView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"EditNote"]) {
    NotesViewController* noteController = segue.destinationViewController;
    noteController.establishment = self.detailItem;
  }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
  barButtonItem.title = NSLocalizedString(@"Master", @"Master");
  [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
  self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
  // Called when the view is shown again in the split view, invalidating the button and popover controller.
  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
  self.masterPopoverController = nil;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
  // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
  return YES;
}

#pragma mark - Image Picking

- (IBAction)addPhoto:(id)sender {
  UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
  imagePicker.delegate = self;
  imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
  
  [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [self dismissViewControllerAnimated:YES completion:nil];
  UIImage* selectedImage = info[UIImagePickerControllerOriginalImage];
  if (selectedImage) {
    [self addPhotoToEsablishment:selectedImage];
  }
}

- (NSURL*) generageFileURL {
  NSFileManager* manager = [NSFileManager defaultManager];
  NSArray* fileArray = [manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
  NSURL* cacheURL = [fileArray lastObject];
  NSURL* fileURL = [[cacheURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:@"jpg"];
  NSString* filePath = [cacheURL path];
  if (filePath) {
    if (![manager fileExistsAtPath:filePath]) {
      [manager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
  }
  return fileURL;
}

- (void) addNewPhotoToScrollView:(UIImage*) image {
  UIImageView* newImView = [[UIImageView alloc] initWithImage:image];
  CGFloat offset = self.detailItem.assetCount * 70. + 10.;
  CGRect frame = CGRectMake(offset, 0, 60, 60);
  newImView.frame = frame;
  newImView.clipsToBounds = YES;
  newImView.layer.cornerRadius = 8.;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.photoScrollView addSubview:newImView];
    self.photoScrollView.contentSize = CGSizeMake(CGRectGetMaxX(frame), CGRectGetHeight(frame));
  });
}

- (void) addPhotoToEsablishment:(UIImage*)image {
  //1 CKAssets need a local file to upload to CloudKit
  //so, save it locally first
  NSURL* fileURL = [self generageFileURL];
  NSData* data = UIImageJPEGRepresentation(image, 0.9);
  NSError* error = nil;
  [data writeToURL:fileURL atomically:YES];
  
  if (error != nil) {
    [[[UIAlertView alloc] initWithTitle:@"Error Saving Photo" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    return;
  }
  
  CKAsset* asset = [[CKAsset alloc] initWithFileURL:fileURL];
  CKReference* ref = [[CKReference alloc] initWithRecord:self.detailItem.record action:CKReferenceActionDeleteSelf];
  
  [[Model model].user userID:^(CKRecordID *recordID, NSError *error) {
    if (recordID) {
      CKReference* userRef = [[CKReference alloc] initWithRecordID:recordID action:CKReferenceActionNone];
      CKRecord* record = [[CKRecord alloc] initWithRecordType:@"EstablishmentPhoto"];
      record[@"Photo"] = asset;
      record[@"Establishment"] = ref;
      record[@"User"] = userRef;
      
      [self.detailItem.database saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
        if (!error) {
          [self addNewPhotoToScrollView:image];
        }
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
      }];
    }
  }];
}

@end
