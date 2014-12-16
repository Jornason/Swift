//
//  AppDelegate.m
//  Stitch
//
//  Created by Jack Wu on 2014-06-18.
//
//

#import "AppDelegate.h"
#import "UIColor+ThemeColors.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  
  self.window.tintColor = [UIColor blueThemeColor];
  
  [UINavigationBar appearance].barTintColor = [UIColor blueThemeColor];
  [UINavigationBar appearance].tintColor = [UIColor whiteColor];
  [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
  
  
  return YES;
}

@end
