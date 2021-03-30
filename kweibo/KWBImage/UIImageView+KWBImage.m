//
//  UIImageView+KWBImage.m
//  kweibo
//
//  Created by Kingyu on 2021/3/16.
//

#import "UIImageView+KWBImage.h"
#import "UIView+KWBCorner.h"
#import "KWBCacheManager.h"
#import "KWBImageDownloader.h"

@implementation UIImageView (KWBImage)

- (void)kwb_setImageWithUrl:(NSURL *)url{
    [self kwb_setImageWithUrl:url completion:nil];
}

- (void)kwb_setImageWithUrl:(NSURL *)url completion:(KWBImageSetCompletion)completion{
    __weak typeof(self) weakSelf = self;
    [[KWBImageDownloader sharedInstance] downloadWithURL:url completion:^(NSData * data, NSURLResponse * _Nullable response) {
        __strong typeof(self) strongSelf = weakSelf;
        UIImage * image = [UIImage imageWithData:data];
        if (completion) {
            completion(image, response);
        }else{
            dispatch_async_in_mainqueue_safe(^{
                strongSelf.image = image;
            });
        }
    }];
}


@end
