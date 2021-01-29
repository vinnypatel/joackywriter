//
//  AppDelegate.swift
//  JoackyWriter
//
//  Created by Ilya Kulbakin on 01/02/2017.
//  Copyright © 2017 Jenex Software. All rights reserved.
//

import UIKit
import AVFoundation
//import FBSDKCoreKit
//import SwiftyDropbox
//import Firebase
//import IQKeyboardManagerSwift


let APPDELEGATE = AppDelegate.sharedAppDelegate()
let USERDEFAULT = UserDefaults.standard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var speechSynthesizer = AVSpeechSynthesizer()
    var window: UIWindow?
    
    class func sharedAppDelegate() -> AppDelegate{
                return UIApplication.shared.delegate as! AppDelegate
            }
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

       

        Sounds.default.prepare()
        return true
    }

    
    func saveImageToDocumentDirectory(image: UIImage, imageName: String) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
         // name of the image to be saved
        let fileURL = documentsDirectory.appendingPathComponent("\(imageName).png")
        if let data = image.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: fileURL.path){
            do {
                try data.write(to: fileURL)
                print("file saved")
                return true
                
            } catch {
                print("error saving file:", error)
                return false
                
            }
        }
        return false
    }


    func loadImageFromDocumentDirectory(nameOfImage : String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("\(nameOfImage).png")
            let image    = UIImage(contentsOfFile: imageURL.path)
            return image!
        }
        return UIImage.init(named: "default.png")!
    }
    
    func removeItemForDocument(itemName:String, fileExtension: String) {
      let fileManager = FileManager.default
      let NSDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
      let NSUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
      let paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)
      guard let dirPath = paths.first else {
          return
      }
      let filePath = "\(dirPath)/\(itemName).\(fileExtension)"
      do {
        try fileManager.removeItem(atPath: filePath)
      } catch let error as NSError {
        print(error.debugDescription)
      }}
}

