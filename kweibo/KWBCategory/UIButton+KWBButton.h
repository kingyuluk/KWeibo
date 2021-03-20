//
//  UIButton+KWBButton.h
//  kweibo
//
//  Created by Kingyu on 2021/3/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (KWBButton)

// 设置可点击范围到按钮边缘的距离
-(void)setEnLargeEdge:(CGFloat)size;

// 设置可点击范围到按钮上、右、下、左的距离
-(void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

@end

NS_ASSUME_NONNULL_END
