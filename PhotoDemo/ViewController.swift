//
//  ViewController.swift
//  PhotoDemo
//
//  Created by mac on 15/11/8.
//  Copyright © 2015年 mac. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController {

  var pick: UIImagePickerController!
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView.clipsToBounds = true
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    configureImagePickView()
    fetchPhotos()
  }
  
  
  func fetchPhotos() {
    let opts = PHFetchOptions()
    let desc = NSSortDescriptor(key: "startDate", ascending: false)
    opts.sortDescriptors = [desc]
    
    let result = PHCollectionList.fetchCollectionListsWithType(.MomentList, subtype: .MomentListYear, options: opts)
    result.enumerateObjectsUsingBlock { (obj, int, stop) -> Void in
      let list = obj as! PHCollectionList
      let f = NSDateFormatter()
      f.dateFormat = "yyyy"
      print(f.stringFromDate(list.startDate!))
      let result = PHAssetCollection.fetchMomentsInMomentList(list, options: nil)
      result.enumerateObjectsUsingBlock({ (obj, ix, stop) -> Void in
        let coll = obj as! PHAssetCollection
        if ix == 0 {
          print("=========== \(result.count) clusters")
        }
        f.dateFormat = "yyyy-MM-dd"
        print("starting \(f.stringFromDate(coll.startDate!)): " + "\(coll.estimatedAssetCount)")
      })
    }
    

    
    let albumsResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .AlbumMyPhotoStream, options: nil)
    print(albumsResult)
    albumsResult.enumerateObjectsUsingBlock { (obj, ix, stop) -> Void in
      let album = obj as! PHAssetCollection
      print(album.localizedTitle)
          let newOpts = PHFetchOptions()
          let descNew = NSSortDescriptor(key: "creationDate", ascending: false)
          newOpts.sortDescriptors = [descNew]
      let result = PHAsset.fetchAssetsInAssetCollection(album, options: newOpts)
      print(result.count)
      result.enumerateObjectsUsingBlock({ (obj, ix, stop) -> Void in
        let asset = obj as! PHAsset
        print(asset)
      })
    }
    
    print(albumsResult.count)
    
    
  }
  
  func configureImagePickView(){
    let src = UIImagePickerControllerSourceType.SavedPhotosAlbum
    let ok = UIImagePickerController.isSourceTypeAvailable(src)
    
    if !ok {
      print("alas")
      return
    }
    let arr = UIImagePickerController.availableMediaTypesForSourceType(src)
    if arr == nil {
      print("no available types")
      return
    }
    pick = UIImagePickerController()
    pick.sourceType = src
    pick.mediaTypes = arr!
    pick.delegate = self
  }
  
  
  @IBOutlet weak var showImagePickerVc: UIButton!
  
  @IBAction func showImagePick(sender: AnyObject) {
    
    presentViewController(pick, animated: true, completion: nil)
    
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    determineStatus()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "determineStatus", name: UIApplicationWillEnterForegroundNotification, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
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
}
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let url = info[UIImagePickerControllerMediaURL] as? NSURL
    var image = info[UIImagePickerControllerOriginalImage] as? UIImage
    let edim = info[UIImagePickerControllerEditedImage] as? UIImage
    
    if edim != nil {
      image = edim
    }
    dismissViewControllerAnimated(true, completion: {
      let type = info[UIImagePickerControllerMediaType] as? String
      
      guard type != nil else{
        return
      }
      switch type! {
      case (kUTTypeImage as? String)!:
        if image != nil {
          print(image?.size)
          self.imageView.image = image
        }
      case (kUTTypeMovie as? String)!:
        if url != nil {
          print(url)
        }
      default:
        break
      }
    })
  }
}






