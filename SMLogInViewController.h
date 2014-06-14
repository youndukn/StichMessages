//
//  SMLogiViewController.h
//  SafeMessage
//
//  Created by youndukn on 4/8/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMKeyboardHandler.h"

@protocol SMLogInViewControllerDelegate;

@interface SMLogInViewController : UIViewController <SMKeyboardHandlerDelegate, UITextFieldDelegate>

@property (nonatomic,weak) id <SMLogInViewControllerDelegate> delegate;

@end

@protocol SMLogInViewControllerDelegate <NSObject>

//- (void)loginViewController:(SMLogInViewController *)loginViewController didLogInUser:(PFUser*)user;
//- (void)loginViewController:(SMLogInViewController *)loginViewController didSignUpUser:(PFUser*)user;

@end