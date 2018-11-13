//
//  AppDelegate.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 6/16/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Firebase
import AeroGearOAuth2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager = CLLocationManager()
    //static var counter: Int = 0
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let development = false
        
        //Present the according screen, not as navigation controller
        /*
        let navigationController: UINavigationController = (self.window!.rootViewController as! UINavigationController)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.clear
        UIApplication.shared.statusBarStyle = .lightContent
 */
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if development == true{
            let camera = storyboard.instantiateViewController(withIdentifier: "SignUp3") as? CameraViewController<AnyObject>
            let user = GTLUserUser()
            user.userBucket = "adrian-21-adrian-1471580171"
            camera?.userToSend = user
            camera?.isProfileVideo = true
           // navigationController.pushViewController(camera!, animated: true)
        }else{
            
            if (SessionManager.sharedInstance.isUserLoggedIn == true){
                // Show the main view
                self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MainView")
                //navigationController.pushViewController(storyboard.instantiateViewController(withIdentifier: "MainView"), animated: false)
            }
            else {
                //Show the initial screen for login or signup
                self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "InitialView")
                //navigationController.pushViewController(storyboard.instantiateViewController(withIdentifier: "InitialScreen"), animated: false)
            }
        }
        
        self.window?.makeKeyAndVisible()
        
        
        // Override point for customization after application launch.
        self.checkForReachability()
        //SessionManager.sharedInstance
        SessionManager.sharedInstance.deviceType = whatDeviceType()
        setupCoreLocation()
        
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // [START register_for_notifications]
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        // [END register_for_notifications]
        
        FIRApp.configure()
        if let token = FIRInstanceID.instanceID().token(){
            print("token" , token)
        }
        
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                                         name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
        print("Device Token:", tokenString)
        
        //Save toke to nsuserdefaults
        UserDefaults.standard.set(tokenString, forKey: "registrationToken")
        SessionManager.sharedInstance.deviceToken = tokenString
        
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle DATA NOTIFICATION
        
        //If it is a data notification, add completetion handler of NEWDATA
        
        
        //Completion Handler
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
        let refreshedToken = FIRInstanceID.instanceID().token()!
        print("token" , refreshedToken)
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        
        //If this is a data message
        if let custom = userInfo["custom"] as? NSDictionary{
            
            if let match = custom["match"] as? NSDictionary{
                print("Match: \(match)")
                
                
            }
            
            
            completionHandler(.newData)
            //Do some download stuff
        }
        else{
            completionHandler(.noData)
            
            // [END receive_message]
            
            //Show the notification when app is not in the foreground
            NSLog("startLocalNotification")
            let notification: UILocalNotification = UILocalNotification()
            notification.fireDate = Date(timeIntervalSinceNow: 7)
            notification.alertBody =  userInfo["body"] as? String
            notification.timeZone = TimeZone.current
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.applicationIconBadgeNumber = 5
            notification.alertAction = "open"
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        
    }
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error!)")
            } else {
                print("Connected to FCM.")
                
                
            }
        }
    }
    // [END connect_to_fcm]
    
    func setupCoreLocation(){
        //setup Core Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        //stops updating the user location
        locationManager.stopUpdatingLocation()
        
        print("counter 2")
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                SessionManager.sharedInstance.userCountry = pm.country
                SessionManager.sharedInstance.userCity = pm.locality
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        
        //If the user is logged in, update location from app delegate
        if (SessionManager.sharedInstance.isUserLoggedIn == true && SessionManager.sharedInstance.userCity != nil){
            DAO.updateCurrentUsersLocation(location.coordinate.longitude, lat: location.coordinate.latitude, city: SessionManager.sharedInstance.userCity!)
        }
        
        
        
        //Save the lat and lon in the constants
        Constants.lat = location.coordinate.latitude
        Constants.lon = location.coordinate.longitude
        
        SessionManager.sharedInstance.lat = location.coordinate.latitude
        SessionManager.sharedInstance.long = location.coordinate.longitude
        
        print(Constants.lat)
        print(Constants.lon)
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func checkForReachability(){
        //declare this property where it won't go out of scope relative to your listener
        let reachability = Reachability()!
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        
        
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                print("Not reachable")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func whatDeviceType() -> String{
        var phoneType :String = String()
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 480:
                phoneType = "iphone3"
                print("iPhone Classic")
            case 960:
                phoneType = "iphone4"
                print("iPhone 4 or 4S")
            case 1136:
                phoneType = "iphone5"
                print("iPhone 5 or 5S or 5C")
            case 1334:
                phoneType = "iphone6"
                print("iPhone 6 or 6S")
            case 2208:
                phoneType = "iphone6Plus"
                print("iPhone 6+ or 6S+")
            default:
                print("unknown")
            }
        }
        return phoneType
    }
    
    func checkForLocation(){
        
        if CLLocationManager.locationServicesEnabled() {
            print("Location Services Enabled")
            if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .notDetermined {
            
                print("Location has not been granted")
            }
            else {
                Constants.locationOn = true
                print("Location has been authorized")
            }
        }
        
    }
    
    
    
        
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        setupCoreLocation()
        checkForLocation()
        print("Application came to foregroud")
        //Set the scrollview back to the middle
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFcm()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    //OAuth Redirect
    func application(application: UIApplication,
                     openURL url: NSURL,
                     sourceApplication: String?,
                     annotation: AnyObject?) -> Bool {
        let notification = NSNotification(name: NSNotification.Name(rawValue: AGAppLaunchedWithURLNotification),
                                          object:nil,
                                          userInfo:[UIApplicationLaunchOptionsKey.url:url])
        NotificationCenter.default.post(notification as Notification)
        return true
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.HumpTrump.Final-Questor-App.Final_Questor_App" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Final_Questor_App", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        print("Status bar should be white")
        return UIStatusBarStyle.lightContent
    }
}


