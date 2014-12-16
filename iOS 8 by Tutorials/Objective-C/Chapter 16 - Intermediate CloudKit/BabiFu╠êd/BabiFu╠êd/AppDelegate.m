/*
 * Copyright (c) 2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

@import CloudKit;

#import "AppDelegate.h"
#import "Workaround.h"
#import "MasterViewController.h"

@interface AppDelegate ()
@property (weak, nonatomic) MasterViewController* masterViewController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//  [Workaround doWorkaround];
  
  UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
  UISplitViewController *splitViewController = (UISplitViewController *)[tabBarController selectedViewController];
  UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
  splitViewController.delegate = (id)navigationController.topViewController;
  
  UINavigationController* masterNav = splitViewController.viewControllers[0];
  self.masterViewController = (MasterViewController*)[masterNav topViewController];
  
  [application registerForRemoteNotifications];
  
  return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSLog(@"Registered for Push notifications with token: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"Push subscription failed: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  CKQueryNotification* note = [CKQueryNotification notificationFromRemoteNotificationDictionary:userInfo];
  [self.masterViewController.controller handleNotification:note];
}



@end
