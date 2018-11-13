//
//  ImageView.h
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 15/11/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SendToViewController;

@interface ImageView : UIViewController
- (instancetype)initWithImage:(UIImage *)image;
-(void)callmethod;
@end
