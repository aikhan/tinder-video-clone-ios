//
//  TestVideoViewController.m
//  Memento
//
//  Created by Ömer Faruk Gül on 22/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import "VideoView.h"
#import "Tru_app-Swift.h"
#import "SCLAlertView.h"

@import AVFoundation;

@interface VideoView ()
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *avPlayerLayer;
@property (strong, nonatomic) UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendArrow;

//Allow the user to download the video that they jsut took to their camera role
@property (strong, nonatomic) UIButton *downloadButton;


@end

@implementation VideoView



- (instancetype)initWithVideoUrl:(NSURL *)url {
    self = [super init];
    if(self) {
        _videoUrl = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Show that view loaded
    NSLog(@"The view did load");
    
    //Send image
    UIImage *img = [UIImage imageNamed:@"Sent"];
    
    UIImage *img2 = [UIImage imageNamed:@"VideoUpload"];
    
    if(_isProfileVideo == YES){
        //Set the image for sending videos
        [_sendArrow setImage:img2 forState:UIControlStateNormal];
    }
    else{
        //Set the image for sending videos
        [_sendArrow setImage:img forState:UIControlStateNormal];
    }
    
   
    
    //Name of the person you are sending it to
    _nameLabel.textColor = [UIColor whiteColor];
    if (_isProfileVideo == YES){
        _nameLabel.text = @"Upload Profile Video";
    }
    else{
        //Set the name of the label and set it to white
        _nameLabel.text = _userToSend.firstName;
        
    }
    

    self.view.backgroundColor = [UIColor whiteColor];
    
    // the video player
    self.avPlayer = [AVPlayer playerWithURL:self.videoUrl];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.avPlayerLayer.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    [self.view.layer addSublayer:self.avPlayerLayer];
    
    // cancel button
    [self.view addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.frame = CGRectMake(0, 0, 44, 44);
    
    //Download Button
    UIImage *downloadImage = [UIImage imageNamed:@"DownloadVideo"];
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.downloadButton.tintColor = [UIColor whiteColor];
    [self.downloadButton setImage:downloadImage forState:UIControlStateNormal];
    self.downloadButton.imageView.clipsToBounds = NO;

    [self.downloadButton addTarget:self action:@selector(downloadVideoFromView) forControlEvents:UIControlEventTouchUpInside];
    self.downloadButton.frame = CGRectMake(10, self.view.frame.size.height - 70 - 50 - 10, 50, 50);
    [self.view addSubview:self.downloadButton];
    
}

-(void)downloadVideoFromView{
    NSLog(@"The button is being pressed but there is no image");
    [self downloadVideo:self.videoUrl];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.avPlayer play];
}

- (IBAction)sendTo:(id)sender {
    
    
    if(_isProfileVideo){
        
        [self saveProfileVideoToFileSystem:self.videoUrl];
        
        //If this is the initial video, or a profile video, then upload it to the users bucket
        NSString *bucketname = [[NSUserDefaults standardUserDefaults] stringForKey:@"bucketName"];
        [self uploadProfileVideo:bucketname videoUrl:self.videoUrl];
        
        [self dismissViewControllerAnimated:NO completion:nil];
        [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        
        [[self delegate] reloadView];
        
        if(_fromProfile == NO){
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MainView"];
            [[self presentingViewController] presentViewController:vc animated:YES completion:NULL];
        }
        
        
    }
    else{
        [self sendVideoTo:_userToSend.userBucket videoUrl:self.videoUrl];
        [self dismissViewControllerAnimated:NO completion:nil];
        [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];

        //Stop playing video as soon as they press send
        [self.avPlayer pause];
        
    }

}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

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
    NSLog(@"cancel button pressed!");
    [self dismissViewControllerAnimated:NO completion:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
