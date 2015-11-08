//
//  AssetViewContoller.swift
//  PhotoDemo
//
//  Created by mac on 15/11/8.
//  Copyright © 2015年 mac. All rights reserved.
//

import UIKit
import Photos

class AssetViewContoller: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  var asset: PHAsset!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let barItem = UIBarButtonItem(title: "Delete", style: .Plain, target: self, action: "deleteAsset")
    navigationItem.rightBarButtonItem = barItem
    
    let imageManager = PHImageManager.defaultManager()
    imageManager.requestImageForAsset(asset, targetSize: imageView.frame.size, contentMode: .AspectFit, options: nil) { [weak self](image, infor) -> Void in
      self?.imageView.image = image
    }
  }
  
  func deleteAsset(){
    PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
        PHAssetChangeRequest.deleteAssets([self.asset])
      }) { (success, error) -> Void in
        dispatch_async(dispatch_get_main_queue()) {
          if success {
            self.navigationController?.popViewControllerAnimated(true)
          }else {
            print("Error deleting asset: \(error!.localizedDescription)")
          }
        }
    }
  }

  deinit {
    print("Destroy Asset View Controller.")
  }
}
