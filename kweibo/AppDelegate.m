//
//  AppDelegate.m
//  kweibo
//
//  Created by Kingyu on 2021/3/12.
//

#import "AppDelegate.h"
#import "KWBHomePageViewController.h"

@interface AppDelegate ()

@end

extern NSString * kAccessToken;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[KWBHomePageViewController alloc] init]];
    [_window makeKeyAndVisible];
    
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kAppKey];
    return YES;
}


- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        WBAuthorizeResponse *result = (WBAuthorizeResponse *)response;
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            kAccessToken = result.accessToken;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_AuthorizeSuccess object:result];
        }else if(response.statusCode == WeiboSDKResponseStatusCodeAuthDeny) {
            NSLog(@"授权失败");
        }
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WeiboSDK handleOpenURL:url delegate:self ];
}
#pragma clang diagnostic pop

@end
