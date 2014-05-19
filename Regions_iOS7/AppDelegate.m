//
//  AppDelegate.m
//  Regions_iOS7
//
//  Created by Dean Woodward on 15/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import "AppDelegate.h"
#import "RegionsViewController.h"

@implementation AppDelegate

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

//------------------------------------------------------------------------------
// Use this method to release shared resources, save user data, invalidate
// timers, and store enough application state information to restore your
// application to its current state in case it is terminated later. If your
// application supports background execution, called instead of
// applicationWillTerminate: when the user quits.
//------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
	// Reset the icon badge number to zero.
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	
	if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
		
        // Get a reference to the RegionsViewController
        RegionsViewController *rvc = [self regionsViewController];
        
        // Stop normal location updates and start significant location change updates for battery efficiency.
		[rvc.locationManager stopUpdatingLocation];
		[rvc.locationManager startMonitoringSignificantLocationChanges];
        NSLog(@"Switched to significant change monitoring.");
	}
	else {
		NSLog(@"Significant location change monitoring is not available.");
	}
}

//------------------------------------------------------------------------------
// Called as part of the transition from the background to the inactive state;
// Here you can undo many of the changes made on entering the background.
//------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

//------------------------------------------------------------------------------
// Restart any tasks that were paused (or not yet started) while the application
// was inactive. If the application was previously in the background, optionally
// refresh the user interface.
//------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    RegionsViewController *rvc = [self regionsViewController];
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
		// Stop significant location updates and start normal location updates again since the app is in the forefront.
		[rvc.locationManager stopMonitoringSignificantLocationChanges];
		[rvc.locationManager startUpdatingLocation];
        NSLog(@"Switched to updating location.");
	}
	else {
		NSLog(@"Significant location change monitoring is not available.");
	}
	
	if (!rvc.updatesTableView.hidden) {
		// Reload the updates table view to reflect update events that were recorded in the background.
		[rvc.updatesTableView reloadData];
			
		// Reset the icon badge number to zero.
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	}
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"In application will terminate");
}

//------------------------------------------------------------------------------
// Get a reference to the RegionsViewController
//------------------------------------------------------------------------------
- (RegionsViewController *)regionsViewController
{
    UIViewController *navVC = self.window.rootViewController;
    RegionsViewController *rvc = [navVC.childViewControllers firstObject];
    return rvc;
}


@end
