//
//  OAuthWebViewController.h
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^KWBAuthSuccessCompletion)(void);

@interface KWBOAuthWebViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
