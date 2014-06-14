//
//  SMAppDelegate.m
//  StichMessages
//
//  Created by Younduk Nam on 5/14/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMAppDelegate.h"

#import "SMMainViewController.h"

#import "SMUtility.h"

@interface SMAppDelegate()
@property (nonatomic, strong) SMMainViewController *mainViewController;
@end

@implementation SMAppDelegate

@synthesize mainViewController;
@synthesize navController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.mainViewController = [[SMMainViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    
    self.window.rootViewController = self.navController;
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self setupAppearance];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupAppearance {
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[SMUtility gMainColor]];
    
}

/*
- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    SMLogInViewController *logInViewController = [[SMLogInViewController alloc] init];
    [logInViewController setDelegate:self];
    
    [self.mainViewController presentViewController:logInViewController animated:NO completion:nil];
}*/
/*
- (void)loginViewController:(SMLogInViewController *)loginViewController didLogInUser:(PFUser *)user{
    [self.navController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)loginViewController:(SMLogInViewController *)loginViewController didSignUpUser:(PFUser *)user{
    [self loginViewController:loginViewController didLogInUser:user];
}

- (void)logOut {
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewControllerAnimated:YES];
    
    self.mainViewController = nil;
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
*/
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
