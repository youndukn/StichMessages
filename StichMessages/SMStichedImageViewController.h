//
//  SMStichedImageViewController.h
//  StichMessages
//
//  Created by Younduk Nam on 5/24/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMImageView.h"
#import "SMScrollerViewController.h"

typedef enum {
	SMStitchedImageViewControllerAlertVeiwIndexRecursive = 1
} SMStitchedImageViewControllerAlertVeiwIndex;


@interface SMStichedImageViewController : SMScrollerViewController <UIAlertViewDelegate, UIGestureRecognizerDelegate,SMImageViewDelegate>

//Set StitchedImage After
@property (nonatomic, strong) UIImage *stichedImage;

//Initializer
- (id)initWithImage:(UIImage *)image;

@end
