//
//  KWBImageDownloader.h
//  kweibo
//
//  Created by Kingyu on 2021/3/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^KWBDowanloadCompleteBlock)(NSData * data, NSURLResponse * _Nullable response);

@interface KWBImageDownloader : NSObject

+ (instancetype)sharedInstance;
- (void)downloadWithURL:(NSURL *)url completion:(KWBDowanloadCompleteBlock)completion;

@end

NS_ASSUME_NONNULL_END
