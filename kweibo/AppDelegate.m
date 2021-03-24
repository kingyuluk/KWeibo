//
//  AppDelegate.m
//  kweibo
//
//  Created by Kingyu on 2021/3/12.
//

#import "AppDelegate.h"
#import <Weibo_SDK/WeiboSDK.h>
#import "KWBHomePageViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[KWBHomePageViewController alloc] init]];
    [_window makeKeyAndVisible];
    
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kAppKey];
    return YES;
}

@end
