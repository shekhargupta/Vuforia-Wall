//
//  AppDelegate.m
//  vuforia-wall
//
//  Created by Eduard Feicho <eduard_DOT_feicho_AT_rwth-aachen_DOT_de> on 13.04.12.
//  Source: https://github.com/Duffycola/Vuforia-Wall
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;


#pragma mark - UIApplicationDelegate protocol

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	
	UIViewController *vc1, *vc2, *vc3;
	
	vc1 = [[ImagePickerViewController alloc] init];
	vc2 = [[ImageWallViewController alloc] init];
#if !(TARGET_IPHONE_SIMULATOR)
	vc3 = [[QCARViewController alloc] init];
#endif
	
	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.delegate = self;
	
#if !(TARGET_IPHONE_SIMULATOR)
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:vc1,vc2,vc3,nil];
#else
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:vc1,vc2,nil];
#endif
	
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
	ImageWall* imageWall = [ImageWall sharedInstance];
	imageWall.frame = [[UIScreen mainScreen] bounds];
	
	NSLog(@"UIScreen mainScreen bounds: %@ %@ %@ %@\n", imageWall.frame.origin.x, imageWall.frame.origin.y, imageWall.frame.size.width, imageWall.frame.size.height);
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application;
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application;
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application;
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application;
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application;
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)theTabBarController shouldSelectViewController:(UIViewController *)viewController
{
	BOOL alreadySelected = theTabBarController.selectedViewController == viewController;
	if (alreadySelected) {
		return NO;
	}
	if ([viewController isKindOfClass:[ImagePickerViewController class]]) {
		[(ImagePickerViewController*)viewController showPhotoLibrary];
	}
	return YES;
}


@end
