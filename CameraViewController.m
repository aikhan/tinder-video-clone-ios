//
//  HomeViewController.m
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import "CameraViewController.h"
#import "ViewUtils.h"
#import "ImageView.h"
#import "VideoView.h"
#import "SCLAlertView.h"
#import "Tru_app-Swift.h"


@interface CameraViewController ()
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) NSTimer *VideoTimer;
@property (strong, nonatomic) NSTimer *VideoCountDownTimer;
@property (strong, nonatomic) NSTimer *CountDownTimer;
@property (strong, nonatomic) NSTimer *GifCameraTimer;
@property (strong, nonatomic) NSMutableArray *imagesArray;


@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *GIFImageView;
@property (weak, nonatomic) IBOutlet UIButton *takeSelfieButton;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *FinalButton;
@property (weak, nonatomic) IBOutlet OppositeGradientHeaderView *navigationBar;
@property (weak, nonatomic) IBOutlet UIImageView *videoPng;


//Camera Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoPngConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewTopConstriant;




@end

NSString *kSuccessTitle = @"Congratulations 🎉😃";
NSString *kErrorTitle = @"Connection error";
NSString *kNoticeTitle = @"Notice";
NSString *kWarningTitle = @"Warning";
NSString *kInfoTitle = @"Info";
NSString *kSubtitle = @"You are on your way to meeting new people!\n There are a couple of things that you must do first before moving on!\n1. You must turn on your location \n2. You must turn on your notifications!.\n3. You must take your selfies 😎\n 4. You must upload your first profile video!\5. MOST IMPORTANTLY’!\n BE YOURSELF!😊😊😊";
NSString *kButtonTitle = @"Done";
NSString *kAttributeTitle = @"Attributed string operation successfully completed.";

@implementation CameraViewController


- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //If from profile, show backbutton, if not hide it
    if(_fromProfile == YES){
        _backButton.hidden = NO;
        [_FinalButton setTitle:@"Upload Profile Video" forState:UIControlStateNormal];
    }
    else{
        _backButton.hidden = YES;
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    //If this is the camera scren that comes up when the user is signing up, then give them a big instructional pop up what they need to do to move forward


    // ----- initialize camera -------- //
    
    // create camera vc
    /*
        We can change the AVCaptureSessionPresetHigh to lower quality for reduced size depending upon the connection quality.
     */
    
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionFront
                                             videoEnabled:YES];
   
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = NO;
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        
        NSLog(@"Device changed.");
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == LLCameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission ||
               error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                
                if(weakSelf.errorLabel) {
                    [weakSelf.errorLabel removeFromSuperview];
                }
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"We need permission for the camera.\nPlease go to your settings.";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                weakSelf.errorLabel = label;
                [weakSelf.view addSubview:weakSelf.errorLabel];
            }
        }
    }];
    
    // ----- camera buttons -------- //
    
    // cancel button
    if(_isGifCamera == false){
        [self.view addSubview:self.cancelButton];}
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.frame = CGRectMake(0, 0, 44, 44);
    
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapButton.frame = CGRectMake(0, 0, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if(_isGifCamera == false){
    [self.view addSubview:self.snapButton];
    }
    
    // button to toggle flash
    self.flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.flashButton.frame = CGRectMake(0, 0, 16.0f + 20.0f, 24.0f + 20.0f);
    self.flashButton.tintColor = [UIColor whiteColor];
    [self.flashButton setImage:[UIImage imageNamed:@"camera-flash.png"] forState:UIControlStateNormal];
    self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if(_isGifCamera == false){
    [self.view addSubview:self.flashButton];
    }
    
    if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
        // button to toggle camera positions
        self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.switchButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
        self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
        self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if(_isGifCamera == false){
            [self.view addSubview:self.switchButton];}
    }
    //Never have an option to change from video to pictures. if Gif Camera, segment control = 0 else == 1
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Picture",@"Video"]];
    self.segmentedControl.frame = CGRectMake(12.0f, screenRect.size.height - 67.0f, 120.0f, 32.0f);
    //self.segmentedControl.selectedSegmentIndex = 1;
    //self.segmentedControl.tintColor = [UIColor whiteColor];
    //[self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    //if(_isGifCamera == false){
    //[self.view addSubview:self.segmentedControl];
   // }
    
    //Set the selfies take to false
    _selfiesTaken = false;
    
    //Check if notifications are on
    [self checkNotifications];
    
    //Check if location is on
    [self checkLocation];
    
    //Check if the first video has been sent
   // [self checkFirstVideo];
    
    //Set the final to upload videos and just do the check there
    if( _fromProfile == YES){
        [_FinalButton setTitle:@"Upload Profile Video" forState: UIControlStateNormal];

    }
    else{
        [_FinalButton setTitle:@"Upload Profile Video" forState: UIControlStateNormal];
    }
    
    [_FinalButton removeTarget:nil
                        action:NULL
              forControlEvents:UIControlEventAllEvents];
    
    [_FinalButton addTarget:self
                     action:@selector(uploadVideo)
           forControlEvents:UIControlEventTouchUpInside];
    
    
    _countDownLoopCount = 4;
    _gifCountLoop = 0;
    _videoCount = 15;
    
    //Countdown
    self.timerLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 1/5, self.view.frame.size.height * 4/5, 75, 75)];
    self.timerLabel.text = @"";
    [self.timerLabel setFont:[UIFont boldSystemFontOfSize:40]];
    self.timerLabel.adjustsFontSizeToFitWidth = YES;
    self.timerLabel.backgroundColor = [UIColor clearColor];
    self.timerLabel.textColor = [UIColor whiteColor];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    self.timerLabel.left = 12.0f;
    self.timerLabel.bottom = self.view.height - 35.0f;
    [self.view addSubview:self.timerLabel];
    self.timerLabel.hidden = true;
    
    //Set countdown label to white color
    _countDownLabel.textColor = [UIColor whiteColor];
    
    //Hide the label until the user says take pictures
    _countDownLabel.hidden = YES;
    
    //Array of pictures that are sent back
    
    _imagesArray = [[NSMutableArray alloc] init];
    
    //Hide Image View
    _GIFImageView.hidden = YES;
    
    if(_infoPopup == YES){
        //Show this pop up with all the regulations
    [self hideEverything];
    
        SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert addButton:@"Gotcha 😜" actionBlock:^(void) {
        [self unhideEverything];
    }];
    
    //Determine what to say according to if the location service are on or not
    if (_LocationOn == false && _notificationOn == false){
        //Tell them to turn them both on, so leave it the way that it is
    }
    else if (_LocationOn == false && _notificationOn ==  true){
        //Then tell the user to turn the location on
        kSubtitle = @"You are on your way to meeting new people!\n There are a couple of things that you must do first before moveing on!\n1. You must turn on your location! \n2. You must take your selfies 😎\n3. You must upload your first profile video!\n4. MOST IMPORTANTLY!\n BE YOURSELF!😊😊😊";
    }
    else if (_LocationOn == true && _notificationOn == false){
        //Tell the user to turn the notifications on
         kSubtitle = @"You are on your way to meeting new people!\n There are a couple of things that you must do first before moving on!\n1. You must turn on your notifications! \n2. You must take your selfies 😎\n3. You must upload your first profile video!\n4. MOST IMPORTANTLY!\n BE YOURSELF!😊😊😊";
    }
    else{
        //Just tell them that they need to take thier selfies and upload their first video
        kSubtitle = @"You are on your way to meeting new people!\n There are a couple of things that you must do first before moving on!\n1. You must take your selfies 😎\n2. You must upload your first profile video!\n3. MOST IMPORTANTLY!\n BE YOURSELF!😊😊😊";
    }
    
    UIColor *color = [UIColor orangeColor];
    [alert showCustom:self image:[UIImage imageNamed:@"CameraPopup"] color:color title:kSuccessTitle subTitle: kSubtitle closeButtonTitle:nil duration:0.0f];
        
        //If it is a iphone 5, then set constriants
        if([[self iphoneType] isEqual: @"iphone5"]){
            self.videoPngConstarint.constant = 329;
            self.GIFImageView.height = 329;
            self.bottomViewTopConstriant = 0;
            
        }
    
    }
    
}

-(void)firstButton{
    //Just see if this works
    NSLog(@"This works");
}

-(void)uploadVideo{
    if(_fromProfile == true){
        [self hideEverything];
        self.segmentedControl.selectedSegmentIndex = 1;
        
    }
    
    //If they have not taken thier selfies yet, they can not take a video
    if (_selfiesTaken == false && _fromProfile == false){
        //Show a pop up that instructs them to take their selfies first
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        NSString *kSubtitle = @"Sorry 😁\nYou must take your selfies before uploading your video!\n Won't hurt anybody. \n We encourage being yourself where ever you are! 🤓";

        UIColor *color = [UIColor orangeColor];
        [alert showCustom:self image:[UIImage imageNamed:@"CameraPopup"] color:color title:@"OOPS! 😅" subTitle: kSubtitle closeButtonTitle:@"Gotcha 😜" duration:0.0f];
    }
    else{
        
    //Check to see if the location is off or if the notifications are off
        [self checkLocation];
        [self checkNotifications];
        if (_LocationOn ==  false){
            //Present to them a pop up that tells them to turn on thier location
            SCLAlertView *alert = [[SCLAlertView alloc] init];
             NSString *kSubtitle = @"Sorry 😁\nYou must turn on your location before proceeding! ✈️ ";
             
             UIColor *color = [UIColor orangeColor];
            
            //add the action of them turning on their location
            [alert addButton:@"Turn on Location ✈️" actionBlock:^(void) {
                [self turnOnLocation];
            }];
             [alert showCustom:self image:[UIImage imageNamed:@"CameraPopup"] color:color title:@"OOPS! 😅" subTitle: kSubtitle closeButtonTitle:nil duration:0.0f];
            
        }
        else if (_notificationOn == false){
            //Present to them a pop up that tells them to turn on thier location
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            NSString *kSubtitle = @"Sorry 😁\nYou must turn on your notifications before proceeding! 📲";
            
            UIColor *color = [UIColor orangeColor];
            
            //Add the action of them turning on thier notifications
            [alert addButton:@"Turn on Notifications 📲" actionBlock:^(void) {
                [self turnOnNotifications];
            }];
            
            [alert showCustom:self image:[UIImage imageNamed:@"CameraPopup"] color:color title:@"OOPS! 😅" subTitle: kSubtitle closeButtonTitle:nil duration:0.0f];

        }
        else{

            //Upload Video simply hides every single view on the current screen and allows the user to upload their first video
            [self hideEverything];
            self.segmentedControl.selectedSegmentIndex = 1;
            _isGifCamera = YES;
        }
    
    
    
    }
}

-(void)hideEverything{

    _GIFImageView.hidden = YES;
    _takeSelfieButton.hidden = YES;
    _bottomView.hidden = YES;
    _FinalButton.hidden = YES;
    _navigationBar.hidden = YES;
    _videoPng.hidden = YES;
}

-(void)unhideEverything{

    _GIFImageView.hidden = NO;
    _takeSelfieButton.hidden = NO;
    _bottomView.hidden = NO;
    _FinalButton.hidden = NO;
    _navigationBar.hidden = NO;
    _videoPng.hidden = NO;
}



-(void)turnOnNotifications{
    //-- Set Notification
    if ([[UIApplication sharedApplication]respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // For iOS 8 and above
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        NSURL *settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if ([[UIApplication sharedApplication] canOpenURL:settings])
            [[UIApplication sharedApplication] openURL:settings];
    }
    
    //Check what the response is. If it is yes, then change the state of the view
    

}

-(void)turnOnLocation{
    //ASk the user to tuen on their location, if they say no, say you can  not proceed and use the app because it requires you location
    NSURL *settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:settings])
        [[UIApplication sharedApplication] openURL:settings];
    
    //After they are shown this check to make sure what answer they gave to you
    

}

-(void)checkNotifications{
    
    if ([self checkForNotifications] == true){
        _notificationOn = true;
    }
    
}

-(void)checkLocation{
    
    //Check to see if the location services are enabled and if they are, has the user granted persmission, if so, hide that label
    if([CLLocationManager locationServicesEnabled]){
        
        NSLog(@"Location Services Enabled");
        
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusRestricted || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
            _LocationOn = false;
            NSLog(@"Location has not been granted");
        }
        else{
            _LocationOn = true;
            NSLog(@"Location has been authorized");
        }
    }
}


- (IBAction)takeSelfiesAction:(id)sender {
    //Disable upload first video button
    self.FinalButton.userInteractionEnabled = false;
    
    //Turn the segment control to 0 to take pictures
    self.segmentedControl.selectedSegmentIndex = 0;
    
    //Disable selfie button
    _takeSelfieButton.enabled = NO;
    
    //Stop animating
    [_GIFImageView stopAnimating];
    
    //Set isGifCamera to true
    _isGifCamera = YES;
    
    //Countdown
    _CountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(countDown) // <== see the ':', indicates your function takes an argument
                                                     userInfo:nil 
                                                      repeats:YES];
    
    //Set the counter back to 4 so if they decide to take the selfies again it will not go it the negative numbers
    self.countDownLoopCount = 4;
    self.gifCountLoop = 0;
    
    //Empty image array
    [_imagesArray removeAllObjects];
    
}

-(void)countDown{
    //count down
 
    _countDownLoopCount--;
    
    //Unhide the label
    _countDownLabel.hidden = NO;
    
    if( _countDownLoopCount == 0){
        [_CountDownTimer invalidate];
        _countDownLabel.hidden = YES;
        
        //Take the 5 selfies
        [self takeSelfies];
        
        NSLog(@"The timer has been invalidated adn the selfies should start being taken now");
    }
    else{
        //Add a label to the screen
        NSString* myNewString = [NSString stringWithFormat:@"%i", _countDownLoopCount];
        if (_countDownLoopCount == 3){
            //Add the label number 3
            _countDownLabel.text = myNewString;
            //In half a second remove this label
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                              target:self
                                                            selector:@selector(removelabel) // <== see the ':', indicates your function takes an argument
                                                            userInfo:nil
                                                             repeats:NO];
            
        }
        else if(_countDownLoopCount == 2){
            //Add the label number 2
            _countDownLabel.text = myNewString;
            //In half a second remove this label
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                              target:self
                                                            selector:@selector(removelabel) // <== see the ':', indicates your function takes an argument
                                                            userInfo:nil
                                                             repeats:NO];
            
        }
        else{
            //Add the label number 1
            _countDownLabel.text = myNewString;
            //In half a second remove this label
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                              target:self
                                                            selector:@selector(removelabel) // <== see the ':', indicates your function takes an argument
                                                            userInfo:nil
                                                             repeats:NO];
        }
        
    }
    
}

-(void)removelabel{
    _countDownLabel.hidden = YES;
    NSLog(@"The label has been hidden and the count is %@", _countDownLabel);
}

-(void)takeSelfies{
    //Capture the pictures
    NSLog(@"The camera will start taking pictures!!");
    
    //Take five selfies
    _GifCameraTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(takeGIFSelfie) // <== see the ':', indicates your function takes an argument
                                                     userInfo:nil
                                                      repeats:YES];
}

-(void)takeGIFSelfie{
    _gifCountLoop++;
    if (_gifCountLoop > 5){
        //enable the selfie button
        _takeSelfieButton.enabled = YES;
        
        //Invalidate the timer, stop taking pictures and pass back that array of uiimages
        [_GifCameraTimer invalidate];
        
        //Pass back the images to be animated;
        _GIFImageView.hidden = NO;
        _GIFImageView.animationImages = _imagesArray;
        _GIFImageView.animationDuration    = 1.0;
        _GIFImageView.clipsToBounds = true;
        
        
        //Rotate imageview
        //_GIFImageView.transform = CGAffineTransformMakeRotation(M_PI);
        
        //Start animating
        [_GIFImageView startAnimating];
        
        
        //Upload these pictures to the user's bucket
        [self uploadProfileGIF:_imagesArray];
        
        //Save these pictures to the file system as Profile GIF iamges
        [self saveGIFPicturesToFileSystem:@"" images:_imagesArray];
        
        //Set the selfies taken to true
        _selfiesTaken = true;
        
        //Enable upload video button
        self.FinalButton.userInteractionEnabled = true;
        
        NSLog(@"Images count == ");
        NSLog(@"Number of items in my array is: %lu", (unsigned long)[_imagesArray count]);
        
    }
    else{
        //Take a picture and add it to an array
        __weak typeof(self) weakSelf = self;
        [weakSelf.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
            if(!error) {

                //If no error add the cropped image to the arrary
                [_imagesArray addObject:[self squareImageWithImage:image scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width)]];
            }
            else {
                NSLog(@"An error has occured: %@", error);
            }
        } exactSeenImage:YES];

        }
}





- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



- (void)segmentedControlValueChanged:(UISegmentedControl *)control
{
    NSLog(@"Segment value changed!");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
}



/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button
{
    [self.camera togglePosition];
}

//Cancel button
- (UIButton *)cancelButton {
    if(!_cancelButton) {
        UIImage *cancelImage = [UIImage imageNamed:@"cancel.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tintColor = [UIColor whiteColor];
        [button setImage:cancelImage forState:UIControlStateNormal];
        button.imageView.clipsToBounds = NO;
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        button.layer.shadowOpacity = 0.4f;
        button.layer.shadowRadius = 1.0f;
        button.clipsToBounds = NO;
        
        _cancelButton = button;
    }
    
    return _cancelButton;
}

- (void)cancelButtonPressed:(UIButton *)button {
    if (_isGifCamera == YES){
        [self unhideEverything];
    }
    NSLog(@"Cancel button pressed!");
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (IBAction)continueButtonTapped:(id)sender {
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
    //[self presentViewController:vc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)flashButtonPressed:(UIButton *)button
{
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}

//- (void)snapButtonPressed:(UIButton *)button
//{
//    __weak typeof(self) weakSelf = self;
//    
//    if(self.segmentedControl.selectedSegmentIndex == 0) {
//        // capture
//        [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
//            if(!error) {
//                ImageView *imageVC = [[ImageView alloc] initWithImage:image];
//                [weakSelf presentViewController:imageVC animated:NO completion:nil];
//            }
//            else {
//                NSLog(@"An error has occured: %@", error);
//            }
//        } exactSeenImage:YES];
//        
//    } else {
//        if(!self.camera.isRecording) {
//            self.segmentedControl.hidden = YES;
//            self.flashButton.hidden = YES;
//            self.switchButton.hidden = YES;
//            
//            self.snapButton.layer.borderColor = [UIColor redColor].CGColor;
//            self.snapButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
//            
//            //Animation code for record button
//            
//
//           _VideoTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f
//                                            target:self selector:@selector(stopRecordingVideo) userInfo:nil repeats:YES];
//            
//            
//            // start recording
//            NSURL *outputURL = [[[self applicationDocumentsDirectory]
//                                 URLByAppendingPathComponent:@"test1"] URLByAppendingPathExtension:@"mov"];
//            [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
//                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
//                                                                     bundle:nil];
//                VideoView *vc = [storyboard instantiateViewControllerWithIdentifier:@"VideoView"];
//                
//                vc.videoUrl = outputURL;
//                
//                if (_isProfileVideo == YES){
//                    vc.isProfileVideo = YES;
//                }
//                vc.userToSend = _userToSend;
//                
//                [self presentViewController:vc animated:false completion:nil];
//
//
//            }];
//            
//        } else {
//            self.segmentedControl.hidden = NO;
//            self.flashButton.hidden = NO;
//            self.switchButton.hidden = NO;
//            
//            self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
//            self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
//            
//            [self.camera stopRecording];
//        }
//    }
//}
- (void)snapButtonPressed:(UIButton *)button
{
    __weak typeof(self) weakSelf = self;
    
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        // capture
        [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
            if(!error) {
                ImageView *imageVC = [[ImageView alloc] initWithImage:image];
                [weakSelf presentViewController:imageVC animated:NO completion:nil];
            }
            else {
                NSLog(@"An error has occured: %@", error);
            }
        } exactSeenImage:YES];
        
    } else {
        if(!self.camera.isRecording) {
            //If camera is not recording, start recording
            self.segmentedControl.hidden = YES;
            self.flashButton.hidden = YES;
            self.switchButton.hidden = YES;
            
            self.snapButton.layer.borderColor = [UIColor redColor].CGColor;
            self.snapButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
            
            _VideoTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f
                                target:self selector:@selector(stopRecordingVideo) userInfo:nil repeats:YES];
            //Show countdown label
            [self startCountdown];
            
            
            // start recording
            NSURL *outputURL = [[[self applicationDocumentsDirectory]
                                 URLByAppendingPathComponent:@"test1"] URLByAppendingPathExtension:@"mov"];
            [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle:nil];
                VideoView *vc = [storyboard instantiateViewControllerWithIdentifier:@"VideoView"];
                
                vc.videoUrl = outputURL;
                
                if (_isProfileVideo == YES){
                    vc.isProfileVideo = YES;
                }
                if(_fromProfile == YES){
                    vc.fromProfile = YES;
                }
                vc.userToSend = _userToSend;
                
                [self presentViewController:vc animated:false completion:nil];

            }];
            
        } else {
            //If camera is recording then stop recording
            self.segmentedControl.hidden = NO;
            self.flashButton.hidden = NO;
            self.switchButton.hidden = NO;
            
            self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
            
            [self.camera stopRecording];
            [self invalidateTimers];
            self.timerLabel.hidden = true;
            
            
        }
    }
}

-(void)invalidateTimers{
    //Invalidate all timers
    [_VideoTimer invalidate];
    [_VideoCountDownTimer invalidate];
    [_CountDownTimer invalidate];
    [_GifCameraTimer invalidate];
    
    //Reset all counts
    _countDownLoopCount = 4;
    _gifCountLoop = 0;
    _videoCount = 15;
    
    
}

-(void)startCountdown{
    //Unhide the timer
    self.timerLabel.hidden = false;
    
    //set the counter text to 15
    self.timerLabel.text = @"15";
    
    //Start the countdown
    _VideoCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                            target:self selector:@selector(videoCountDown) userInfo:nil repeats:YES];
}

-(void)videoCountDown{
    NSLog(@"The video countdown has been calld");
    _videoCount--;
    if (_videoCount <= 0) {
        [_VideoCountDownTimer invalidate];
        self.timerLabel.hidden = YES;
    }
    else{
   
    
    NSString *count = [NSString stringWithFormat:@"%d",_videoCount];
    _timerLabel.text = count;
    _timerLabel.adjustsFontSizeToFitWidth = YES;
    _timerLabel.backgroundColor = [UIColor clearColor];
    _timerLabel.textColor = [UIColor whiteColor];
    _timerLabel.textAlignment = NSTextAlignmentCenter;

    }
}

-(void)stopRecordingVideo{
    self.segmentedControl.hidden = NO;
    self.flashButton.hidden = NO;
    self.switchButton.hidden = NO;
    
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    [self.camera stopRecording];
    [self invalidateTimers];
     self.timerLabel.hidden = true;

}

- (void)animateRecordingButton{
    [UIView animateWithDuration:2.0f animations:^{
        
        [self.snapButton setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
        
        //fade out
        [UIView animateWithDuration:2.0f animations:^{
            
            [self.snapButton setAlpha:0.1f];
            
        } completion:nil];
        
    }];
}

/* other lifecycle methods */

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.camera.view.frame = self.view.contentBounds;
    
    self.snapButton.center = self.view.contentCenter;
    self.snapButton.bottom = self.view.height - 15.0f;
    
    self.flashButton.center = self.view.contentCenter;
    self.flashButton.top = 5.0f;
    
    self.switchButton.top = 5.0f;
    self.switchButton.right = self.view.width - 5.0f;
    
    self.segmentedControl.left = 12.0f;
    self.segmentedControl.bottom = self.view.height - 35.0f;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
