//
//  HomeViewController.h
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"
#import "GTLUser.h"



@interface CameraViewController <CallProfileReload> : UIViewController 

@property (nonatomic, assign) BOOL isProfileVideo;
@property (nonatomic, assign) BOOL isGifCamera;
@property (nonatomic, assign) BOOL infoPopup;
@property (nonatomic, assign) BOOL fromProfile;
@property (nonatomic, assign) BOOL notificationOn;
@property (nonatomic, assign) BOOL LocationOn;
@property (nonatomic, assign) BOOL VideoUploaded;
@property (nonatomic, assign) BOOL selfiesTaken;
@property (strong, nonatomic) GTLUserUser *userToSend;

@property int countDownLoopCount;
@property int gifCountLoop;
@property int videoCount;
@end
