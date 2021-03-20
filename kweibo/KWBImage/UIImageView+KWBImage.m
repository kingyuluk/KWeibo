//
//  UIImageView+KWBImage.m
//  kweibo
//
//  Created by Kingyu on 2021/3/16.
//

#import "UIImageView+KWBImage.h"
#import "UIView+KWBCorner.h"

@implementation UIImageView (KWBImage)

- (void)kwb_setImageWithUrl:(NSURL *)url{
    [self kwb_setImageWithUrl:url completion:nil];
}

- (void)kwb_setImageWithUrl:(NSURL *)url completion:(KWBImageSetCompletion)completion{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UIImage *image = [UIImage imageWithData:data];
        if (completion) {
            completion(image, error);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImage:image];
            });
        }
    }];
    [task resume];
}

@end
