//
//  SMLogiViewController.m
//  SafeMessage
//
//  Created by youndukn on 4/8/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMLogInViewController.h"

#import "SMUtility.h"

#import "SMAppDelegate.h"

#import "SMKeyboardHandler.h"
#import "MBProgressHUD.h"

#import "SMConstants.h"

@interface SMLogInViewController (){
    SMKeyboardHandler *keyboard;
}
@property (nonatomic, strong) UIImageView *fieldsBackground;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *logInButton;
@property (nonatomic, strong) UIButton *signUpButton;
@property (nonatomic, strong) UIButton *facebookButton;

@end

@implementation SMLogInViewController

@synthesize fieldsBackground;
@synthesize logo;
@synthesize logoLabel;
@synthesize usernameField;
@synthesize passwordField;
@synthesize logInButton;
@synthesize signUpButton;
@synthesize facebookButton;

const int iSMMinPassword = 4;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    keyboard = [[SMKeyboardHandler alloc] init];
    keyboard.delegate = self;
    
    UITapGestureRecognizer *tapGuester = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardAction)];
    [self.view addGestureRecognizer:tapGuester];
    
    //[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"StichMS_Logo_M.png"]]
    UILabel *label = [[UILabel alloc] init];
    label.text = @"StitchMS";
    label.textColor = [SMUtility gMainColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:50];
    [self setLogoLabel:label];
    [self.view addSubview:label];
    
    // Set field text color
    self.fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_loginfield.png"]];
    [self.view insertSubview:fieldsBackground atIndex:1];
    
    self.usernameField = [[UITextField alloc] init];
    [self.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.usernameField setPlaceholder:@"Username"];
    [self.usernameField setKeyboardType:UIKeyboardTypeDefault];
    self.usernameField.textAlignment = NSTextAlignmentCenter;
    self.usernameField.tag = 0;
    self.usernameField.delegate = self;
    [self.view addSubview:self.usernameField];
    
    self.passwordField = [[UITextField alloc] init];
    [self.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.passwordField setPlaceholder:@"Password"];
    self.passwordField.returnKeyType = UIReturnKeyDone;
    self.passwordField.textAlignment = NSTextAlignmentCenter;
    self.passwordField.tag = 1;
    [self.passwordField setSecureTextEntry:YES];
    self.passwordField.delegate = self;
    [self.view addSubview:self.passwordField];
    
    // Set buttons appearance
    self.logInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.logInButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gSubmitColor]] forState:UIControlStateNormal];
    [self.logInButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gSubmitPColor]] forState:UIControlStateHighlighted];
    [self.logInButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.logInButton setTitle:@"Login" forState:UIControlStateHighlighted];
    [self.logInButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logInButton];
    
    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signUpButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gChangeColor]] forState:UIControlStateNormal];
    [self.signUpButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gChangePColor]] forState:UIControlStateHighlighted];
    [self.signUpButton setTitle:@"SignUp" forState:UIControlStateNormal];
    [self.signUpButton setTitle:@"SignUp" forState:UIControlStateHighlighted];
    [self.signUpButton addTarget:self action:@selector(signUpAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signUpButton];
    
    // Set buttons appearance
    self.facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gMainLightColor]] forState:UIControlStateNormal];
    [self.facebookButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gMainLightColor]] forState:UIControlStateHighlighted];
    [self.facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
    [self.facebookButton setTitle:@"Facebook" forState:UIControlStateHighlighted];
    [self.facebookButton addTarget:self action:@selector(facebookAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.facebookButton];
    
}

- (void)loginAction{
    if([self.usernameField.text length] == 0 ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username Not Present" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Confirm",nil];
        [alert show];
        return;
    }
    if([self.passwordField.text length] <= iSMMinPassword ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Minimum Password Length %d",iSMMinPassword-1] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Confirm",nil];
        [alert show];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"LogIning"];
    [hud setDimBackground:NO];
    
    [PFUser
     logInWithUsernameInBackground:self.usernameField.text
     password:self.passwordField.text
     block:^(PFUser *user, NSError *error) {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         if (user) {
            [self.delegate loginViewController:self didLogInUser:user];
         }else{
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Unsuccessful" message:errorString delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인",nil];
            [alert show];
        }
    }];
}

- (void)signUpAction{
    
    if([self.usernameField.text length] <= 2){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Premium Character Number" message:@"More Than 3 Characters" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Confirm",nil];
        [alert show];
        return;
    }
    
    if( [self.passwordField.text length] < iSMMinPassword){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Minimum Password Length %d",iSMMinPassword-1] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Confirm",nil];
        [alert show];
        return;
    }
    
    PFUser *user = [PFUser user];
    user.username = self.usernameField.text;
    user.password = self.passwordField.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"SignUping"];
    [hud setDimBackground:NO];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            [self.delegate loginViewController:self didSignUpUser:user];
        }else if([error code] == kPFErrorUsernameTaken){
            //error
            // Show the errorString somewhere and let the user try again.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username is Taken" message:nil delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:nil];
            [alert show];
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            // Show the errorString somewhere and let the user try again.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signup Unsuccessful" message:errorString delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:nil];
            [alert show];
        }
    }];
}


- (void)facebookAction{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Facebooking"];
    [hud setDimBackground:NO];
    
    [PFFacebookUtils logInWithPermissions: @[@"user_about_me"] block:^(PFUser *user, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            [PFFacebookUtils reauthorizeUser:[PFUser currentUser]
                      withPublishPermissions:@[@"publish_actions"]
                                    audience:FBSessionDefaultAudienceOnlyMe
                                       block:^(BOOL succeeded, NSError *error) {
                                           if (succeeded) {
                                               NSLog(@"granted");
                                           }
                                       }];

            [self.delegate loginViewController:self didSignUpUser:user];
        } else {
            [self.delegate loginViewController:self didSignUpUser:user];
            NSLog(@"User logged in through Facebook!");
        }
    }];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float inset = 35.0f;
    // Set frame for elements
    
    [self.logoLabel setFrame:CGRectMake(screenRect.size.width/2-screenRect.size.width/3, 20, screenRect.size.width/1.5,80.0f)];
    
    //[self.logo setFrame:CGRectMake(screenRect.size.width/2-logo.image.size.width/4, 80.0f, logo.image.size.width/2, logo.image.size.height/2)];
    [self.fieldsBackground setFrame:CGRectMake(inset, screenRect.size.height-250.0f, screenRect.size.width-inset*2, 100.0f)];
    
    NSArray *fieldRectArray = [SMUtility getFramesWithColumns:1 Row:2 Width:screenRect.size.width Height:100.0f SideRL:inset MiddleRL:0.0f SideTB:0.0f MiddleTB:0.0f];
    
    CGRect usernameRect = [[fieldRectArray objectAtIndex:0] CGRectValue];
    usernameRect.origin.y+= screenRect.size.height-250.0f;
    [self.usernameField setFrame:usernameRect];
    
    CGRect passwordRect = [[fieldRectArray objectAtIndex:1] CGRectValue];
    passwordRect.origin.y+= screenRect.size.height-250.0f;
    [self.passwordField setFrame:passwordRect];

    NSArray *buttonRectArray = [SMUtility getFramesWithColumns:2 Row:1 Width:screenRect.size.width Height:70.0f SideRL:inset MiddleRL:10.0f SideTB:10.0f MiddleTB:10.0f];
    
    CGRect loginRect = [[buttonRectArray objectAtIndex:0] CGRectValue];
    loginRect.origin.y+= screenRect.size.height-150.0f;
    [self.logInButton setFrame:loginRect];
    
    CGRect signupRect = [[buttonRectArray objectAtIndex:1] CGRectValue];
    signupRect.origin.y+= screenRect.size.height-150.0f;
    [self.signUpButton setFrame:signupRect];
    
    NSArray *buttonRectArray1 = [SMUtility getFramesWithColumns:1 Row:1 Width:screenRect.size.width Height:70.0f SideRL:inset MiddleRL:10.0f SideTB:10.0f MiddleTB:10.0f];
    
    CGRect facebookRect = [[buttonRectArray1 objectAtIndex:0] CGRectValue];
    facebookRect.origin.y+= screenRect.size.height-90.0f;
    [self.facebookButton setFrame:facebookRect];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if( textField.tag == 0){
        [textField resignFirstResponder];
        [self.passwordField becomeFirstResponder];
    }else if(textField.tag == 1){
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)keyboardSizeChanged:(CGSize)delta{
    
    CGRect frame = self.view.frame;
    CGRect frameLogo = self.logoLabel.frame;
    frameLogo.origin.y += delta.height;
    frame.origin.y -= delta.height;
    self.view.frame = frame;
    self.logoLabel.frame = frameLogo;
}

- (void)hideKeyboardAction{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

@end
