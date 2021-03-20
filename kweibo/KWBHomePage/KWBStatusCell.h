//
//  KWBStatusCell.h
//  kweibo
//
//  Created by Kingyu on 2021/3/12.
//

#import <UIKit/UIKit.h>
#import "KWBStatusModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KWBStatusCell : UITableViewCell

- (void)loadDataWithModel:(KWBStatusModel *)model;

@end

NS_ASSUME_NONNULL_END
