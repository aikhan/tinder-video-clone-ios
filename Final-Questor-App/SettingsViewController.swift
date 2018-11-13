
import UIKit
import Eureka
import Alamofire

protocol ReloadProfileView :class{
    func reload()
}

typealias Emoji = String
let 👦🏼 = "👦🏼", 🍐 = "🍐", 💁🏻 = "💁🏻", 🐗 = "🐗", 🐼 = "🐼", 🐻 = "🐻", 🐖 = "🐖", 🐡 = "🐡", 👨🏻 = "👨🏻", 👨🏼 = "👨🏼", 👨🏽 = "👨🏽", 👨🏾 = "👨🏾", 👨🏿 = "👨🏿", 👩🏻 = "👩🏻", 👩🏼 = "👩🏼", 👩🏽 = "👩🏽", 👩🏾 = "👩🏾", 👩🏿 = "👩🏿"

class SettingsViewController : FormViewController {
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    let user = CoreDataDAO.getLoggedInUserInfo()!
    var reloadDelegate: ReloadProfileView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Done button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsViewController.dismiss as (SettingsViewController) -> () -> ()))
        self.navigationController?.navigationBar.tintColor = UIColor.orange
        
        URLRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .blue }
        LabelRow.defaultCellUpdate = { cell, row in cell.detailTextLabel?.textColor = .orange  }
        CheckRow.defaultCellSetup = { cell, row in cell.tintColor = .orange }
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
        //Set up entire Form
        form +++
        
            Section("My Account")
         
                //First Name
                <<< NameRow() {
                    $0.tag = "FirstName"
                    $0.title =  "First Name"
                    $0.value = user.firstName
                    $0.placeholderColor = UIColor.gray

                }
            
                //Location
                <<< NameRow() {
                    $0.title =  "Location"
                    $0.tag = "Location"
                    $0.value = user.userLocation
                    $0.placeholderColor = UIColor.gray
                }
            
                //Gender
                <<< PushRow<Emoji>() {
                    $0.title = "Gender"
                    $0.tag = "Gender"
                    if (user.gender == 0){
                        $0.value = 👨🏻
                    }
                    else{
                        $0.value = 👩🏻
                    }
                    $0.options = [👨🏻,👨🏼,👨🏽,👨🏾,👨🏿,👩🏻,👩🏼,👩🏽,👩🏾,👩🏿]
                    $0.selectorTitle = "Your Gender"
                }.onChange({ (row) in
                    
                    //Save Gender when pressed
                    print(row.value! as String)
                    let gender = self.setGender(gender: row.value!)
                    self.user.gender = gender
                })
                
                //Age
                <<< SliderRow() {
                    $0.title = "Age"
                    $0.maximumValue = 50.0
                    $0.minimumValue = 18.0
                    $0.value = self.user.age as Float?
                    $0.steps = 0
                }.onChange({ (row) in
                    self.user.age = row.value as NSNumber?
                })
            
                //Phone Number, could be nil
                <<< PhoneRow() {
                    $0.title = "Phone Number"
                    $0.tag = "PhoneNumber"
                    if let phoneNumber = self.user.phoneNumber{
                        $0.value = phoneNumber
                        $0.placeholderColor = UIColor.gray
                    }
                    else{
                        $0.placeholder = "Enter Phone Number"
                        $0.placeholderColor = UIColor.gray
                    }
                    $0.disabled = false
                }
            
                //Email
                <<< NameRow() {
                    $0.tag = "Email"
                    $0.title =  "Email"
                    if user.email != nil{
                       $0.value = user.email
                    }
                    else{
                        $0.placeholder = "Email"
                    }
                    
                    $0.placeholderColor = UIColor.gray
                }
            //Bio
            +++ Section("Bio")
            
            <<< TextAreaRow() {
                $0.value = self.user.bio!
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                }.onChange({ (row) in
                    self.user.bio = row.value! as String
                })
    
            //New Section Preferences
            +++ Section("Preferences")
            
                //Looking For
                <<< PushRow<Emoji>() {
                    $0.title = "Looking For"
                    $0.tag = "lookingFor"
                    $0.options = ["Male", "Female", "Both"]
                    if let lookingFor = self.user.lookingFor{
                        if lookingFor == 0{
                            $0.value = "Male"
                        }
                        else if lookingFor == 1{
                            $0.value = "Female"
                        }
                        else{
                            $0.value = "Both"
                        }
                    }
                    $0.selectorTitle = "Looking For"
                }.onChange({ (row) in
                    if(row.value == "Male"){
                        self.user.lookingFor = 0
                    }
                    else if(row.value == "Female"){
                        self.user.lookingFor = 1
                    }
                    else{
                        self.user.lookingFor = 2
                    }
                })
        
            
                //Relationship TODO:Look up what the heck is what
                <<< PushRow<Emoji>() {
                    $0.title = "Relationship"
                    $0.options = ["Dating", "Friends", "Both"]
                    if let dating = self.user.dating{
                        if dating == 0{
                            $0.value = "Dating"
                        }
                        else if dating == 1{
                            $0.value = "Friends"
                        }
                        else{
                            $0.value = "Both"
                        }
                    }
                    $0.selectorTitle = "Relationship"
                    }.onChange({ (row) in
                        if(row.value == "Dating"){
                            self.user.lookingFor = 0
                        }
                        else if(row.value == "Both"){
                            self.user.lookingFor = 1
                        }
                        else{
                            self.user.lookingFor = 2
                        }
                    })
            
                //Search Distance
                <<< SliderRow() {
                    $0.title = "Distance Of Search"
                    $0.maximumValue = 50.0
                    $0.minimumValue = 1.0
                    $0.value = 20
                    $0.steps = 0
                }.onChange({ (row) in
                    self.user.distanceOfSearch = row.value as NSNumber?
                })
            
                //Max Age
                <<< SliderRow() {
                    $0.title = "Max Age"
                    $0.maximumValue = 50.0
                    $0.minimumValue = 18.0
                    $0.value = 35
                    $0.steps = 0
                    }.onChange({ (row) in
                        self.user.ageHigh = row.value as NSNumber?
                    })
            
                //Min Age
                <<< SliderRow() {
                    $0.title = "Min Age"
                    $0.maximumValue = 60.0
                    $0.minimumValue = 18.0
                    $0.value = 18
                    $0.steps = 0
                    }.onChange({ (row) in
                        self.user.ageLow = row.value as NSNumber?
                    })
            
            //Notification Section
            +++ Section("Notifications")
            
                //New Messages
                <<< SwitchRow() {
                    $0.title = "New Messages"
                    $0.tag = "New Messages"
                    $0.value = SessionManager.sharedInstance.newMessage
                }.onChange({ (row) in
                    //Save change to Session Manager
                    SessionManager.sharedInstance.newMessage = row.value!
                })
            
                //New Matches
                <<< SwitchRow() {
                    $0.title = "New Matches"
                    $0.tag = "New Matches"
                    $0.value = SessionManager.sharedInstance.newMatch
                    }.onChange({ (row) in
                        //Save change to Session Manager
                        SessionManager.sharedInstance.newMatch = row.value!
                    })
            
                //New Likes
                <<< SwitchRow() {
                    $0.title = "New Likes"
                    $0.tag = "New Likes"
                    $0.value = SessionManager.sharedInstance.liked
                    }.onChange({ (row) in
                        //Save change to Session Manager
                        SessionManager.sharedInstance.liked = row.value!
                    })

            //Legal Section
            +++ Section("Legal")
        
                //Privacy Policy
                <<< ButtonRow("Privacy Policy") {
                    $0.title = "Privacy Policy"
                    $0.presentationMode = .showCustom(controllerName: "PrivacyPolicy", onDismiss: nil)
                }
        
                //Terms of Service
                <<< ButtonRow("Terms Of Service") {
                    $0.title = "Terms of Service"
                    $0.presentationMode = .showCustom(controllerName: "TermsOfService", onDismiss: nil)
                }
            
            
                //Licenses
                <<< ButtonRow("Licenses") {
                    $0.title = "Licenses"
                    $0.presentationMode = .showCustom(controllerName: "Licenses", onDismiss: nil)
                }
        
            //Section to logout and delete account
            +++ Section()
        
                //Logout
                <<< AlertRow<Emoji>() {
                    $0.title = "Log out"
                    $0.selectorTitle = "Are you sure you want to log out?"
                    $0.options = ["YES", "NO"]
                    }.onChange { row in
                        print(row.value ?? "No Value")
                        if(row.value == "YES"){
                            //Log out user
                            self.logoutAction()
                        }
                    }
                    .onPresent{ _, to in
                        to.view.tintColor = UIColor.orange
                    }
        
                //Delete Account
                <<< AlertRow<Emoji>() {
                    $0.title = "Delete Account"
                    $0.selectorTitle = "Are you sure you want to delete you account?"
                    $0.options = ["YES", "NO"]
                    }.onChange { row in
                        print(row.value ?? "No Value")
                        
                        //Delete user account
                        var selfBucket = SessionManager.sharedInstance.user?.userBucket
                        if selfBucket == nil {
                            selfBucket = DAO.getBucketNameForLoggedInUser()
                        }
                        
                        //Delete User Account
                        self.deleteUser(selfBucket!)
                        
                        //Log out user
                        self.logoutAction()
                    }
                    .onPresent{ _, to in
                        to.view.tintColor = UIColor.orange
                    }
    }
    
    /*
     * Every time that the settings page is dismissed, it should save all of the values to core data as well as update them in the cloud
     */
    func dismiss(){
        
        //Save first name
        var row: NameRow? = form.rowBy(tag: "FirstName")
        if let firstName = (row?.value){
            user.firstName = firstName as String
        }
        
        //Save location
        row = form.rowBy(tag: "Location")
        if let location = (row?.value){
            user.userLocation = location as String
        }
        
        //Save Phone Number, could be nil
        row = form.rowBy(tag: "PhoneNumebr")
        if let phoneNumber = (row?.value){
            //Check if there is an actual phone number and 10 digits long
            if (checkPhoneNumber(number: phoneNumber)){
                user.phoneNumber = phoneNumber
            }
        }
        
        //Save email, could be nil
        row = form.rowBy(tag: "Email")
        if let email = (row?.value){
            //Check if there is an actual email
            if email != "Email"{
                //There is an actual email in there, save it
                user.email = email
            }
        }
        
        //Save entire user object back to coredata
        user.save()
        
        //Reload Profile View
        if (reloadDelegate != nil){
            reloadDelegate?.reload()
        }
        
        //Finally dismiss view controller
        self.dismiss(animated: true, completion: nil)
    }
    
    func setGender(gender: String) -> NSNumber{
        
        switch gender {
        case 👨🏻:
            return 0
        case 👨🏼:
            return 0
        case 👨🏽:
            return 0
        case 👨🏾:
            return 0
        case 👨🏿:
            return 0
        case 👩🏻:
            return 1
        case 👩🏼:
            return 1
        case 👩🏽:
            return 1
        case 👩🏾:
            return 1
        case 👩🏿:
            return 1
        default:
            return user.gender!
        }
    }
    
    
    func checkPhoneNumber(number: String) -> Bool{
        let phone = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        if (phone.characters.count == 10){
            return true
        }
        else{
            return false
        }
    }
    
    func logoutAction(){
        SessionManager.sharedInstance.user = nil
        DAO.clearAllLocalDataStore()
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        
        //Send user back to the main page
        UserDefaults.standard.set(false, forKey: "login") //just in case
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        //Set everything in the session manager to nil
        SessionManager.sharedInstance.isUserLoggedIn = false
        SessionManager.sharedInstance.lat = 0
        SessionManager.sharedInstance.long = 0
        SessionManager.sharedInstance.user = nil
        SessionManager.sharedInstance.usersArray = nil
        SessionManager.sharedInstance.userCity = nil
        SessionManager.sharedInstance.userCountry = nil
        
        //Remove all core data when user logs out
        DAO.clearAllLocalDataStore()
        
        //If the user did not sign it, meaning the root view controller is main, then it will pop back to main
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialView = mainStoryboard.instantiateViewController(withIdentifier: "InitialScreen") as! FirstViewController
        let nav = UINavigationController(rootViewController: initialView)
        nav.navigationBar.isTranslucent = false
        nav.isNavigationBarHidden = true
        appdelegate.window!.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "InitialView")
    }
    
    func deleteUser(_ bucket: String){
        let params = ["bucketName" : bucket]
        let url = "https://final-questor-app.appspot.com/deleteAccount"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            print(response)
        }
    }
}
