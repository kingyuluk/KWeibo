//
//  KWBTabBarViewController.h
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KWBTabBarTagType){
    KWBTabBarTagPost,
    KWBTabBarTagUserCenter,
    KWBTabBarTagSearch,
};

@interface KWBTabBarViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
