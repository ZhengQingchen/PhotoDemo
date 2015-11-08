//
//  AlbumCollectionViewController.swift
//  PhotoDemo
//
//  Created by mac on 15/11/8.
//  Copyright © 2015年 mac. All rights reserved.
//

import UIKit
import Photos


class AlbumCollectionViewController: UICollectionViewController {
  
  var selectedCollection:PHAssetCollection!
  var assetResult:PHFetchResult!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    assetResult = PHAsset.fetchAssetsInAssetCollection(selectedCollection, options: nil)
    
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    return assetResult.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AlbumCell", forIndexPath: indexPath) as! AlbumCollectionViewCell
    let assetForCell = assetResult[indexPath.item] as! PHAsset
    let imageManager = PHImageManager.defaultManager()
    imageManager.requestImageForAsset(assetForCell, targetSize: cell.frame.size, contentMode: .AspectFit, options: nil) { (image , info) -> Void in
      cell.imageView.image = image
      cell.setNeedsLayout()
    }
        
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let width:CGFloat = (view.frame.width - 16 - 10) / 4
    return CGSize(width: width, height: width)
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "AlbumShowAsset" {
      let controller = segue.destinationViewController as! AssetViewContoller
      let indexPath = collectionView?.indexPathsForSelectedItems()![0]
      let result = assetResult[indexPath!.row]
      controller.asset = result as! PHAsset
    }
  }
  
}
