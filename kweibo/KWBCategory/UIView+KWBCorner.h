//
//  UIView+KWBCorner.h
//  kweibo
//
//  Created by Kingyu on 2021/3/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (KWBCorner)

/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corner 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radius   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corner
                withRadius:(CGSize)radius;

@end

NS_ASSUME_NONNULL_END
