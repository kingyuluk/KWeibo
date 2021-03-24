//
//  KWBHomePageViewController.h
//  kweibo
//
//  Created by Kingyu on 2021/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KWBHomePageViewController : UIViewController

@property (nonatomic, strong, readwrite) UITableView        * tableView;
@property (nonatomic, assign, readwrite) NSInteger            pageIndex;
@property (nonatomic, assign, readwrite) NSInteger             pageSize;

- (void)authAccountInCustomView;
- (void)authAccount;

- (void)queryStatusesFromServer:(BOOL)fromServer pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;

@end

NS_ASSUME_NONNULL_END
