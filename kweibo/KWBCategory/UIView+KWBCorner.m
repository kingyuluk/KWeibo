//
//  UIView+KWBCorner.m
//  kweibo
//
//  Created by Kingyu on 2021/3/18.
//

#import "UIView+KWBCorner.h"

@implementation UIView (KWBCorner)


- (void)addRoundedCorners:(UIRectCorner)corner
                withRadius:(CGSize)radius
{
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:radius];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    self.layer.mask = shape;
}


@end
