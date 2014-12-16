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

import UIKit
import QuartzCore


let reuseIdentifier = "ColorSwatchCell"

class ColorSwatchCollectionViewController: UICollectionViewController, ColorSwatchSelector {
  
  var swatchList: ColorSwatchList?
  var swatchSelectionDelegate: ColorSwatchSelectionDelegate?
  
  // Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(animated: Bool) {
    if swatchList == nil {
      swatchList = ColorSwatchList()
      collectionView(collectionView, didSelectItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    }
  }
  
  // #pragma mark UICollectionViewDataSource
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let list = swatchList {
      return list.colorSwatches.count
    }
    return 0
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
  let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
    // Configure the cell
    if let swatchCell = cell as? ColorSwatchCollectionViewCell {
      if let swatch = swatchList?.colorSwatches[indexPath.item] {
        swatchCell.resetCell(swatch)
      }
    }
    return cell
  }
  
  // #pragma mark <UICollectionViewDelegate>
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let swatch = swatchList?.colorSwatches[indexPath.item] {
      swatchSelectionDelegate?.didSelect(swatch, sender: self)
    }
  }
  
  // UIViewController
  override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    // The orientation only makes a difference on an iphone
    if(UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
      let newOrientation = UIApplication.sharedApplication().statusBarOrientation
      if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
        if newOrientation.isPortrait {
          flowLayout.scrollDirection = .Horizontal
        } else {
          flowLayout.scrollDirection = .Vertical
        }
      }
    }
  }
}

