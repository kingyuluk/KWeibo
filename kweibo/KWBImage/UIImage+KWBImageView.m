//
//  UIImage+KWBImage.m
//  kweibo
//
//  Created by Kingyu on 2021/3/22.
//

#import "UIImage+KWBImageView.h"

@implementation UIImage (KWBImage)

- (UIImage*)cropImage:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake (0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage ;
}

- (UIImage *)scaleImage:(UIImage *)image toFit:(CGFloat)width
{
    CGFloat scale = image.size.width / width;
    CGFloat scaleWidth = image.size.width / scale, scaleHeight = image.size.height / scale;
    UIGraphicsBeginImageContext(CGSizeMake(scaleWidth, scaleHeight));
    [image drawInRect:CGRectMake(0, 0, scaleWidth, scaleHeight)];
    UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}


@end
