//
//  KWBTabBarViewController.h
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import <UIKit/UIKit.h>
#import "KWBUserModel.h"
#import "KWBHomePageViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KWBTabBarTagType){
    KWBTabBarTagPost,
    KWBTabBarTagUserCenter,
    KWBTabBarTagSearch,
};

@interface KWBTabBarViewController : UIViewController

@property (nonatomic, weak, readwrite) KWBHomePageViewController * delegate;

- (void)loginActionWithUserModel:(KWBUserModel *)model;

@end

NS_ASSUME_NONNULL_END
