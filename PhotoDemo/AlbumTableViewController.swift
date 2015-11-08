//
//  AlbumTableViewController.swift
//  PhotoDemo
//
//  Created by mac on 15/11/8.
//  Copyright © 2015年 mac. All rights reserved.
//

import UIKit
import Photos

class AlbumTableViewController: UITableViewController {
  
  var albumsFetchResult: PHFetchResult!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    albumsFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
    
    navigationItem.rightBarButtonItem = editButtonItem()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
  }
  

  // MARK: - Table view data source
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return albumsFetchResult.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("AlbumCell", forIndexPath: indexPath)
    let album = albumsFetchResult.objectAtIndex(indexPath.row) as! PHAssetCollection
    
    cell.textLabel?.text = album.localizedTitle
    
    if album.estimatedAssetCount != NSNotFound {
      let albumPlural = album.estimatedAssetCount > 1 ? "s" : ""
      let subTitle = "\(album.estimatedAssetCount) Photo\(albumPlural)"
      cell.detailTextLabel?.text = subTitle
    }else {
      cell.detailTextLabel?.text = "-- empty --"
    }
    
    let albumMoments = PHAsset.fetchKeyAssetsInAssetCollection(album, options: nil)
    
    if let firstAsset = albumMoments?.firstObject as? PHAsset{
      let imageManager = PHImageManager.defaultManager()
      
      imageManager.requestImageForAsset(firstAsset, targetSize: CGSize(width: 80, height: 80), contentMode: .AspectFill, options: nil) { (image, info) -> Void in
        cell.imageView?.image = image
        cell.setNeedsLayout()
      }
    }
    
    return cell
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "AlbumShowDetail" {
      let controller = segue.destinationViewController as! AlbumCollectionViewController
      let tappedIndexPath = tableView.indexPathForSelectedRow!
      let tappedCollection = albumsFetchResult.objectAtIndex(tappedIndexPath.row) as! PHAssetCollection
      controller.title = tappedCollection.localizedTitle
      controller.selectedCollection = tappedCollection
    }
  }
}

extension AlbumTableViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(changeInstance: PHChange) {
    
  }
}




