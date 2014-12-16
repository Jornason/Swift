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

@import UIKit;

@protocol RWTDetailViewControllerDelegate;

@interface RWTDetailViewController : UITableViewController

/** @brief An item to be displayed. */
@property (copy, nonatomic) NSString *item;

/** @brief A delegate to get notified about changes in item. */
@property (weak, nonatomic) id <RWTDetailViewControllerDelegate> delegate;

/** @brief Starts editing by making the text field become first responder. */
- (void)startEditing;

/** @brief Stops editing by making the text field resign first responder. */
- (void)stopEditing;

@end

@protocol RWTDetailViewControllerDelegate <NSObject>

/** @brief Gets called on the delegate when user taps the 'Done'button on the keyboard. */
- (void)detailViewController:(RWTDetailViewController *)controller didFinishWithUpdatedItem:(NSString *)item;

@end
