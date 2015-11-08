//
//  PhotosCollectionViewController.swift
//  PhotoDemo
//
//  Created by mac on 15/11/8.
//  Copyright © 2015年 mac. All rights reserved.
//

import UIKit
import Photos


class PhotosCollectionViewController: UICollectionViewController {
  
  var collectionResult:PHFetchResult!
  var array = [PHFetchResult]()
  lazy var momentDateFormatter: NSDateFormatter =  {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .NoStyle
    
    return formatter
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if determineStatus() {
      loadAssetCollectionsForDisplay()
    }else {
      print("error Not access to phone.")
    }
    
  }
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "determineStatus", name: UIApplicationWillEnterForegroundNotification, object: nil)
    PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillAppear(animated)
    PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)

  }
  
  deinit {
//    PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showImage" {
      let controller = segue.destinationViewController as! AssetViewContoller
      let indexPath = collectionView?.indexPathsForSelectedItems()![0]
      let result = array[indexPath!.section]
      controller.asset = result[indexPath!.row] as! PHAsset
    }
  }
  
  func determineStatus() -> Bool {
    let status = PHPhotoLibrary.authorizationStatus()
    
    switch status {
    case .Authorized:
      return true
    case .NotDetermined:
      PHPhotoLibrary.requestAuthorization({ (status) -> Void in
        print(status.rawValue)
      })
      return false
    case .Restricted:
      return false
    case .Denied:
      let alert = UIAlertController(title: "Need authorization", message: "Wouldn't you like to authorize this app"
        + "to use you photo library", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
      alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (_) -> Void in
        let url = NSURL(string: UIApplicationOpenSettingsURLString)!
        UIApplication.sharedApplication().openURL(url)
      }))
      presentViewController(alert, animated: true, completion: nil)
      return false
    }
  }
  
  func loadAssetCollectionsForDisplay(){
    
    let options = PHFetchOptions()
    let description = NSSortDescriptor(key: "startDate", ascending: false)
    options.sortDescriptors = [description]
    
    collectionResult = PHAssetCollection
      .fetchAssetCollectionsWithType(.Moment,subtype: .Any,options: options)
    
    collectionResult.enumerateObjectsUsingBlock {[weak self] (obj, ix, stop) -> Void in
      let collection = obj as! PHAssetCollection
      let result = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
      self?.array.append(result)
    }
    
    dispatch_async(dispatch_get_main_queue()){
      self.collectionView?.reloadData()
    }
  }
  // MARK: UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return array.count
  }
  
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let result = array[section]
    return result.count
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    
    if kind == UICollectionElementKindSectionHeader {
      let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! MomentHeaderView
      let moment = collectionResult.objectAtIndex(indexPath.section) as! PHAssetCollection
      
      headerView.titleLabel.text = "\(momentDateFormatter.stringFromDate(moment.startDate!))" +
        " - \(momentDateFormatter.stringFromDate(moment.startDate!))"
      headerView.subtitleLabel.text = moment.localizedTitle ?? ""
      
      return headerView
    }
    return UICollectionReusableView()
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotosCollectionViewCell
    let result = array[indexPath.section]
    let asset = result[indexPath.row] as! PHAsset
    
    let imageManager = PHImageManager.defaultManager()
    
    imageManager.requestImageForAsset(asset, targetSize: cell.frame.size, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
      cell.imageView.image = image
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let width:CGFloat = (view.frame.width - 16 - 10) / 4
    return CGSize(width: width, height: width)
  }
  
}

extension PhotosCollectionViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(changeInstance: PHChange) {
    
////    changeInstance.changeDetailsForObject(collectionResult)
//    let detail = changeInstance.changeDetailsForFetchResult(collectionResult)
//    
//    print("change: \(detail?.changedIndexes)")
//    print("remove: \(detail?.removedIndexes)")
//    print("insert: \(detail?.insertedIndexes)")
//    
//    if let insetSection = detail?.insertedIndexes {
//      collectionView?.performBatchUpdates({ () -> Void in
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
////          print(insetSection.firstIndex)
////          collectionResult.enumerateObjectsUsingBlock {[weak self] (obj, ix, stop) -> Void in
////            let collection = obj as! PHAssetCollection
////            let result = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
////            self?.array.append(result)
////          }
//          let collection = detail?.fetchResultAfterChanges
//          collection?.enumerateObjectsUsingBlock({ (obj, ix, stop) -> Void in
//            let collection = obj as! PHAssetCollection
//            let result = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
//            self.array.insert(result, atIndex: insetSection.firstIndex)
//          })
////          self.collectionView?.insertSections(insetSection)
//          self.collectionView?.reloadData()
//        })
//        }, completion: nil)
//
//    }
//    if let removeSection = detail?.removedIndexes {
//      collectionView?.performBatchUpdates({ () -> Void in
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//          self.collectionView?.deleteSections(removeSection)
//        })
//        }, completion: nil)
//    }
    
    dispatch_async(dispatch_get_main_queue()) { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.array.forEach({ (fetchResult) -> () in
        let changesToFetchResult = changeInstance.changeDetailsForFetchResult(fetchResult)
        if changesToFetchResult != nil && changesToFetchResult!.hasIncrementalChanges {
          
          let sectionIndex = strongSelf.array.indexOf(fetchResult)!
          print(changesToFetchResult!.fetchResultAfterChanges.firstObject)
          strongSelf.array[sectionIndex] = changesToFetchResult!.fetchResultAfterChanges
          
          var indexPathsToRemove:[NSIndexPath] = []
          var indexPathsToInsert:[NSIndexPath] = []
          changesToFetchResult!.removedIndexes?.forEach({ (index) -> () in
            let indexPathToRemove = NSIndexPath(forRow: index, inSection: sectionIndex)
            indexPathsToRemove.append(indexPathToRemove)
          })
          changesToFetchResult!.insertedIndexes?.forEach({ (index) -> () in
            let indexPathToInsert = NSIndexPath(forRow: index, inSection: sectionIndex)
            indexPathsToInsert.append(indexPathToInsert)
          })
          
          strongSelf.collectionView?.performBatchUpdates({ () -> Void in
            strongSelf.collectionView?.deleteItemsAtIndexPaths(indexPathsToRemove)
            strongSelf.collectionView?.insertItemsAtIndexPaths(indexPathsToInsert)
            
            }, completion: nil)
        }
      })
    }
  }
}









