//
//  UIImageView+KWBImage.h
//  kweibo
//
//  Created by Kingyu on 2021/3/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^KWBImageSetCompletion)(UIImage * image, NSError * error);

@interface UIImageView (KWBImage)

- (void)kwb_setImageWithUrl:(NSURL *)url;

- (void)kwb_setImageWithUrl:(NSURL *)url completion:(nullable KWBImageSetCompletion)completion;


@end

NS_ASSUME_NONNULL_END
