//
//  TestVideoViewController.h
//  Memento
//
//  Created by Ömer Faruk Gül on 22/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLUser.h"


@protocol CallProfileReload <NSObject>

@required
- (void)reloadView;

@end

@interface VideoView : UIViewController
- (instancetype)initWithVideoUrl:(NSURL *)url;

@property (nonatomic, weak) id<CallProfileReload> delegate;

@property (nonatomic, assign) BOOL isProfileVideo;
@property (nonatomic, assign) BOOL fromProfile;
@property (strong, nonatomic) GTLUserUser *userToSend;
@property (strong, nonatomic) NSURL *videoUrl;
@end
