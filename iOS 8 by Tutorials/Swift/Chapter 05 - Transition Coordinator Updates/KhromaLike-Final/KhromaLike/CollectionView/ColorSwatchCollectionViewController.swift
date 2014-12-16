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
  var currentCellContentTransform = CGAffineTransformIdentity
  
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
  
  override func viewWillLayoutSubviews()  {
    super.viewWillLayoutSubviews()
    if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
      // Find the restrictive dimension
      let minDimension = min(CGRectGetHeight(view.bounds), CGRectGetWidth(view.bounds))
      let newItemSize = CGSize(width: minDimension, height: minDimension)
      if flowLayout.itemSize != newItemSize {
        flowLayout.itemSize = newItemSize
        flowLayout.invalidateLayout()
      }
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
  
  override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    cell.contentView.transform = currentCellContentTransform
  }
  
  // UIContentContainer
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    
    // 1
    let targetTForm = coordinator.targetTransform()
    let inverseTForm = CGAffineTransformInvert(targetTForm)
    // 2
    coordinator.animateAlongsideTransition({ _ in
    // Empty
      }, completion: { _ in
      // 3
      self.view.layer.transform = CATransform3DConcat(self.view.layer.transform, CATransform3DMakeAffineTransform(inverseTForm))
      // 4
      if abs(atan2(Double(targetTForm.b), Double(targetTForm.a)) / M_PI) < 0.9 {
        self.view.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.size.height,
                                             height: self.view.bounds.size.width)
      }
      // 5
      self.currentCellContentTransform = CGAffineTransformConcat(self.currentCellContentTransform, targetTForm)
      UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: nil, animations: {
        for cell in self.collectionView.visibleCells() as [UICollectionViewCell] {
          cell.contentView.transform = self.currentCellContentTransform
        }
      }, completion: nil)
    })
  }

}

