//
//  KWBHomePageViewController.h
//  kweibo
//
//  Created by Kingyu on 2021/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KWBHomePageViewController : UIViewController

@property (nonatomic, strong, readonly) UITableView *   tableView;

- (void)authAccountInCustomView;
- (void)authAccount;

@end

NS_ASSUME_NONNULL_END
