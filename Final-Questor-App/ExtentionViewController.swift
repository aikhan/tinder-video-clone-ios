//
//  ExtentionViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 6/16/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import Alamofire
import AlamofireImage
import Photos
import AssetsLibrary
import SSZipArchive




//Go over these methods and use if lets in order to protect from crashing

//This file will also hold all of the Global variables
var service : GTLServiceUser{
    if _service != nil{
        return _service!
    }
    func makenil(){
        _service = nil
    }
    _service = GTLServiceUser()
    
    _service?.isRetryEnabled = true
    _service?.apiVersion = "v1"
    return _service!
}
var _service : GTLServiceUser?

//Creates the initial user that will be created and then sent to the datastore
let user = GTLUserUser()

//Creates the user array that holds the initi
var users = [GTLUserUser]()
var matches = [GTLUserUser]()

extension Date {
    var age: Int {
        return (Calendar.current as NSCalendar).components(.year, from: self, to: Date(), options: []).year!
    }
}
extension UIViewController{
    
    //Pass in videoURL from video the user jsut recorded
    func downloadVideo(_ videoUrl: URL){
        
        //Test url to download
        //let videoImageUrl = "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4"
        
        DispatchQueue.global(qos: .background).async { [weak self]
            () -> Void in
            
            //let url = NSURL(string: videoImageUrl);
            
            let urlData = NSData(contentsOf: videoUrl as URL);
            if(urlData != nil)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4";
                
                DispatchQueue.main.async {
                    () -> Void in
                    
                    urlData?.write(toFile: filePath, atomically: true);
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: NSURL(fileURLWithPath: filePath) as URL)
                    }) { completed, error in
                        if completed {
                            print("Video is saved!")
                            
                            //Alert user that the video has been saved
                            let alert = UIAlertController(title: "Video Saved Successfully", message: "", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(defaultAction)
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            
        }
    }
    
    func hideKeyboardWhenTappedAround(){
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //This function is called from the camera to access the bucket name of the logged in user because it can not access DAO
    func getBucketForLoggedInUser() -> String{
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        return selfBucket!
    }
    
    //Is called one time when the user signs up. This will upload profile pic, give it the profilepic name and resize on the Backend side
    func uploadProfileGIF(_ imageArray: NSMutableArray){
        var count = 0
        let bucketname = DAO.getBucketNameForLoggedInUser()
        let uploadUrl = "https://final-questor-app.appspot.com/getData"
        for i in imageArray{
            let objectname = "picture" + String(count)
            let image = i;
            //Turn image into data
            let imageData: Data = UIImagePNGRepresentation(image as! UIImage)!
            let params = ["objectname" : objectname, "bucketname" : bucketname!, "isGifImgae" : "True", "content_type" : "image/jpeg"]
            
            
            //Swift 3.0 AlamoreFire Upload
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    // Here is where things would change for you
                    // With name is the thing between the $files, and filename is the temp name.
                    // Make sure mimeType is the same as the type of imagedata you made!
                    multipartFormData.append(imageData, withName: "file", fileName: "image", mimeType: "image/jpeg")
                    
                    //Parameters
                    for(key, value) in params{
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
            },
                to: uploadUrl,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            if let result = response.result.value {
                                // Get the json response. From this, we can get all things we send back to the app.
                                let JSON = result as! NSDictionary
                                debugPrint(response)
                            }
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                    }
            })
            
        }
        
    }
    
    
    
    //This will called once when the user first signs up as well as when the open the app and their location is updated
    func insertUser(_ newUser: GTLUserUser){
        
        let query = GTLQueryUser.queryForUserCreate(withObject: newUser) as GTLQueryUser
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        service.executeQuery(query, completionHandler: {(ticket, response, error) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil{
                //Do some error handling
                print(error.debugDescription)
                return
            }
            else{
                let returnedUser = response as! GTLUserUser
                newUser.entityKey = returnedUser.entityKey
                SessionManager.sharedInstance.user = returnedUser
                SessionManager.sharedInstance.user?.entityKey = returnedUser.entityKey
                SessionManager.sharedInstance.user?.userBucket = returnedUser.userBucket
                
                SessionManager.sharedInstance.isUserLoggedIn = true
                UserDefaults.standard.set(true, forKey: "login")
                UserDefaults.standard.set(true, forKey: "firstUserMessage")
                
                //Change phone number from nsmuber to string
                let tempNumber = SessionManager.sharedInstance.user?.phoneNumber as! Int
                let stringTemp = String(tempNumber)

                
                let didInsert = CoreDataDAO.insertUserLogin(returnedUser)
                assert(didInsert, "Could not write to the database")
                
                //save the registration token to the cloud and to the phone
                if let token = FIRInstanceID.instanceID().token(){
                    DAO.saveRegistrationToken(token)
                }
                //CloudDAO.fetchUnviewUsers()
                
                //Save the user's return bucekt name and entity key to the nsuserdefaults
                UserDefaults.standard.set(returnedUser.userBucket as String, forKey: "bucketName")
                UserDefaults.standard.set(returnedUser.entityKey, forKey: "entityKey")
                UserDefaults.standard.set(0, forKey: "profileVideoCount")
                let videoUrlsArray = NSMutableArray()
                UserDefaults.standard.set(videoUrlsArray, forKey: "profileVideoUrls")
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.setupCoreLocation()
                
                print("User has been logged in")
            }
            
        })
    }
    
    //This function will be called to recreate a user object in order to update the users location
    func createNewUserObject() -> GTLUserUser{
        UserDefaults.standard
        let userToBe = GTLUserUser()
        userToBe.entityKey = UserDefaults.standard.string(forKey: "entityKey")
        
        return userToBe
    }
    
    //This will fetch all of the users
    //TODO: only fetch according to thier gender and their preference of distnace
    func getAllUsers(_ bucket: String){
        let query = GTLQueryUser.queryForUserList()
        query?.userBucket = bucket
        service.executeQuery(query!, completionHandler: {(ticket, response, error) -> Void in
            if error != nil {
                print(error!)
            }
            else{
                let userCollection = response as! GTLUserCollection
                if let newUsers = userCollection.items() as? [GTLUserUser]{
                    users = newUsers
                    print("These are the users that are in data store")
                    for user in users{
                        print(user.firstName)
                        print(user.userBucket)
                        print(user.email)
                    }
                }
            }
        })
    }
    
    func setUpLocation(){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.setupCoreLocation()
    }
    
    //This function will return the signed url in order for the app to stream a video straight from the other users bucket
    func getVideoUrl(_ bucket: String, object: String, completionHandler: ((UIBackgroundFetchResult) -> Void)!){
        let params = ["bucketname" : bucket, "objectname" : object]
        let url = "https://final-questor-app.appspot.com/signUrl"
        
        //Swift 3.0
        Alamofire.request(url, method: .get, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            print(response)
            
            //get status code
            if let status = response.response?.statusCode{
                switch(status){
                case 201:
                    print("example success")
                default:
                    print("error with response status: \(status)")
                }
            }
            
            //get the json return value
            if let result = response.result.value{
                let JSON = result as! NSDictionary
                print(JSON)
            }
        }
        
    }
    
    func sendVideoTo(_ bucket: String, videoUrl: URL){
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        let params = ["content_type" : "video/quicktime", "sender" : selfBucket!, "bucketname" : bucket]
        let url = "https://final-questor-app.appspot.com/getData"
        
        let videoData = try? Data(contentsOf: videoUrl)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                // Here is where things would change for you
                // With name is the thing between the $files, and filename is the temp name.
                // Make sure mimeType is the same as the type of imagedata you made!
                multipartFormData.append(videoData!, withName: "file", fileName: "video", mimeType: "video/quicktime")
                
                //Parameters
                for(key, value) in params{
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
        },
            to: url,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let result = response.result.value {
                            // Get the json response. From this, we can get all things we send back to the app.
                            let JSON = result as! NSDictionary
                            debugPrint(response)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
        
    }
    
    func uploadProfileVideo(_ bucket: String, videoUrl: URL){
        var objectName: String?
        let count = UserDefaults.standard.integer(forKey: "profileVideoCount")
        objectName = "profileVideo" + String(count - 1)
        
        let params = ["content_type" : "video/quicktime", "isProfileVideo" : "true", "bucketname" : bucket, "objectname" : objectName!]
        let url = "https://final-questor-app.appspot.com/getData"
        let videoData = try? Data(contentsOf: videoUrl)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                // Here is where things would change for you
                // With name is the thing between the $files, and filename is the temp name.
                // Make sure mimeType is the same as the type of imagedata you made!
                multipartFormData.append(videoData!, withName: "file", fileName: "video", mimeType: "video/quicktime")
                
                //Parameters
                for(key, value) in params{
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
        },
            to: url,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let result = response.result.value {
                            // Get the json response. From this, we can get all things we send back to the app.
                            let JSON = result as! NSDictionary
                            debugPrint(response)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
        
        
        
    }
    
    func sendNotificationTo(_ bucket: String){
        
        var firstName = SessionManager.sharedInstance.user?.firstName
        if firstName == nil{
            firstName = DAO.getCurrentLoggedUser()!.firstName!
        }
        
        let params = ["firstName" : firstName!, "toBucket" : bucket]
        let url = "https://final-questor-app.appspot.com/notification"
        
        //Swift 3.0
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do nothing
            print(response)
        }
        
    }
    
    
    func compressVideo(_ inputURL: URL, outputURL: URL, handler:@escaping (_ session: AVAssetExportSession)-> Void)
    {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        
        let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) as AVAssetExportSession!
        
        exportSession?.outputURL = outputURL
        
        exportSession?.outputFileType = AVFileTypeQuickTimeMovie
        
        exportSession?.shouldOptimizeForNetworkUse = true
        
        exportSession?.exportAsynchronously { () -> Void in
            
            handler(exportSession!)
        }
    }
    
    func saveProfileVideoToFileSystem(_ url: URL){
        let videoName: String!
        var count = UserDefaults.standard.integer(forKey: "profileVideoCount")
        videoName = "profileVideo" + String(count) + ".mov"
        
        //Make file path for video
        let videoPath = fileInDocumentsDirectory(videoName)
        print("This is the file path for the profile video that they just uploaded == " + String(videoPath))
        
        //turn url into data
        let videoData = try? Data(contentsOf: url)
        
        let result = (try? videoData!.write(to: URL(fileURLWithPath: videoPath), options: [.atomic])) != nil
        
        //Save the file path some where that can be accessed some other time
        var array = UserDefaults.standard.array(forKey: "profileVideoUrls")
        array?.append(videoPath)
        UserDefaults.standard.set(array, forKey: "profileVideoUrls")
        
        //Update count
        count = count + 1
        
        //Save count
        UserDefaults.standard.set(count, forKey: "profileVideoCount")
        
    }
    
    
    
    
    func downloadImagesForMatch(_ imageURLS: [String], match: Bool, bucketName:String, completionHandler: ((UIBackgroundFetchResult) -> Void)!){
        var tempArray = [UIImage]()
        var count = 0
        for i in imageURLS{
            Alamofire.request(i)
                .responseImage { response in
                    debugPrint(response)
                    
                    //print(response.request)
                    //print(response.response)
                    debugPrint(response.result)
                    
                    if let image = response.result.value {
                        print("The image array should be filling up")
                        tempArray.append(image)
                        count+=1
                        if count == 5 {
                            
                            //If these are images saved for a match
                            if match == true || bucketName == ""{
                                //Save these images as the one that will show up for matches
                                self.saveGIFPicturesToFileSystem("match", images: tempArray)
                            }
                            else if(match == false && bucketName != ""){
                                self.saveGIFPicturesToFileSystem(bucketName, images: tempArray)
                            }
                            else{
                                //Save the images for the user using the phone
                                var selfBucket = SessionManager.sharedInstance.user?.userBucket
                                if selfBucket == nil {
                                    selfBucket = DAO.getBucketNameForLoggedInUser()
                                }
                                
                                self.saveGIFPicturesToFileSystem("", images: tempArray)
                            }
                            completionHandler(UIBackgroundFetchResult.newData)
                        }
                        
                    }
            }
            
        }
        
        
    }
    
    func downloadImagesFromMatchScreen(_ imageURLS: [String], bucket: String, completionHandler: ((UIBackgroundFetchResult) -> Void)!){
        
        var tempArray = [UIImage]()
        var count = 0
        for i in imageURLS{
            Alamofire.request(i)
                .responseImage { response in
                    debugPrint(response)
                    
                    //print(response.request)
                    //print(response.response)
                    debugPrint(response.result)
                    
                    if let image = response.result.value {
                        print("The image array should be filling up")
                        tempArray.append(image)
                        count+=1
                        if count == 4 {
                            
                            self.saveGIFPicturesToFileSystem(bucket, images: tempArray)
                            completionHandler(UIBackgroundFetchResult.newData)
                            
                        }
                        
                    }
            }
        }
    }
    
    func downloadGifFromMatch(_ imageURLS: [String], bucket: String, completionHandler: ((UIBackgroundFetchResult) -> Void)!){
        
        var tempArray = [UIImage]()
        var count = 0
        for i in imageURLS{
            Alamofire.request(i)
                .responseImage { response in
                    debugPrint(response)
                    
                    //print(response.request)
                    //print(response.response)
                    debugPrint(response.result)
                    
                    if let image = response.result.value {
                        print("The image array should be filling up")
                        tempArray.append(image)
                        count+=1
                        if count == 4 {
                            
                            self.saveGIFPicturesToFileSystem(bucket, images: tempArray)
                            completionHandler(UIBackgroundFetchResult.newData)
                            
                        }
                        
                    }
            }
        }
    }
    
    
    
    
    
    func saveImage (_ image: UIImage, path: String ) -> Bool{
        print("SAVE IMAGE FUNCTION WAS CALLED")
        let pngImageData = UIImagePNGRepresentation(image)
        //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        let result = (try? pngImageData!.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil
        
        return result
        
    }
    
    func loadImageFromPath(_ path: String) -> UIImage? {
        
        let image = UIImage(contentsOfFile: path)
        
        if image == nil {
            
            print("missing image at: \(path)")
        }
        else{
            print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        }
        return image
        
    }
    
    func iphoneType() -> String{
        return SessionManager.sharedInstance.deviceType
    }
    
    
    
    func saveGIFPicturesToFileSystem(_ bucket: String, images: [UIImage]){
        print("The gif function has been called")
        print("There are " , String(images.count) , " images in the array that passed in")
        var count = 0
        var gifUrlPathArray = [String]()
        for i in images{
            // Define the specific path, image name
            var myImageName = ""
            if bucket == "match" {
                myImageName = bucket + String(count)
            }
            
            if (bucket == ""){
                myImageName = "ProfileGIFImage" + String(count)
            }else{
                myImageName = bucket + String(count)
            }
            
            
            let imagePath = fileInDocumentsDirectory(myImageName)
            
            //Add image path to arrary to be saved in NSUser Defaults
            gifUrlPathArray.append(imagePath)
            
            if saveImage(i, path: imagePath) == true{
                print("THE IMAGE WAS SUCCESSFULY SAVED TO ", imagePath)
            }
            else{
                print("It is trying to save the image however it fails")
            }
            count+=1
        }
        //Save an array of nsurls as strings to hold the users profile gifs, save as logged in users profile gifs
        UserDefaults.standard.set(gifUrlPathArray, forKey: "gifPhotosfor" + bucket)
        print("THE ARRAY WAS SAVED TO NSUSERDEFAULTS")
        print("The name of the array that was saved to nsdefaults was gifphotosfor" , bucket)
    }
    
    func loadGIFPicturesFromFileSystem(_ array: [String]) -> [UIImage]{
        
        var arrayToReturn = [UIImage]()
        for i in array{
            if let loadedImage = loadImageFromPath(i) {
                print(" Loaded Image: \(loadedImage)")
                arrayToReturn.append(loadedImage)
            } else { print("unable to load picture at path: ", i) }
        }
        return arrayToReturn
    }
    
    func deleteVideo(_ url: String){
        //Delete video from file system
        // Create a FileManager instance
        
        let fileManager = FileManager.default
        let theFileName = (url as NSString).lastPathComponent
        // Delete 'hello.swift' file
        
        do {
            try fileManager.removeItem(atPath: url)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
            print("The video was not deleted")
        }
        
        
        
        var count1 = 0
        let tempArray = NSMutableArray()
        //Delete path from array in user defaults
        if let array = UserDefaults.standard.array(forKey: "profileVideoUrls"){
            for i in array{
                tempArray.add(i)
                
                if url == i as! String{
                    tempArray.removeObject(at: count1)
                }
                count1+=1
            }
            
            //Save the array back into the defaults
            UserDefaults.standard.set(tempArray, forKey: "profileVideoUrls")
        }
        
        
        //Subtract one from the video count
        var count = UserDefaults.standard.integer(forKey: "profileVideoCount")
        count = count - 1
        UserDefaults.standard.set(count, forKey: "profileVideoCount")
        
        //Delete the video from the cloud
        let objectName = theFileName.substring(with: (theFileName.characters.index(theFileName.startIndex, offsetBy: 2) ..< theFileName.characters.index(theFileName.endIndex, offsetBy: -4)))
        deleteVideoFromCloud(objectName)
        
        
    }
    
    func deleteVideoFromCloud(_ objectName: String){
        print("objectname ===" , objectName)
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        let url = "https://final-questor-app.appspot.com/deleteVideo/watched"
        let params = ["selfBucket" : selfBucket!, "objectname": objectName]
        
        //Swift 3.0
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do nothing
            print(response)
        }
        
        
    }
    
    
    func checkForNotifications() -> Bool{
        if UIApplication.shared.isRegisteredForRemoteNotifications{
            print("The device is already registered for local notifications")
            
        }
        else{
            print("The device is not registered for notifications")
        }
        
        
        let noticationSettings = UIApplication.shared.currentUserNotificationSettings
        if (noticationSettings == .none || noticationSettings!.types == UIUserNotificationType()) {
            print("Notifications are not turned on")
            return false
        }
        else{
            print("Notifications are turned on")
            Constants.notificationOn = true
            return true
        }
        
        
    }
    
    
}

func getDocumentsURL() -> URL {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsURL
}

func fileInDocumentsDirectory(_ filename: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL.path
    
}

/*
 extension Collection {
 /// Returns the element at the specified index iff it is within bounds, otherwise nil.
 subscript (safe index: Index) -> Iterator.Element? {
 return indices.contains(index) ? self[index] : nil
 }
 }
 */


class ExtentionViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
