//
//  UIImage+KWBImage.h
//  kweibo
//
//  Created by Kingyu on 2021/3/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (KWBImage)

- (UIImage*)cropImage:(CGRect)rect;
- (UIImage *)scaleImage:(UIImage *)image toFit:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
