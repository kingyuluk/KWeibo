//
//  KWBImageDownloader.m
//  kweibo
//
//  Created by Kingyu on 2021/3/22.
//

#import "KWBImageDownloader.h"
#import "KWBCacheManager.h"

@implementation KWBImageDownloader

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static KWBImageDownloader * instance;
    dispatch_once(&onceToken, ^{
        instance = [[KWBImageDownloader alloc] init];
    });
    return instance;
}

- (void)downloadWithURL:(NSURL *)url completion:(KWBDowanloadCompleteBlock)completion{
    [[KWBCacheManager sharedInstance] queryCache:url.absoluteString withExtension:@"jpg" completion:^(NSData * _Nullable data, BOOL hasCache) {
        if(hasCache){
            completion(data, nil);
        }else{
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(data){
                    [[KWBCacheManager sharedInstance] storeCache:data ForKey:url.absoluteString];
                    completion(data, response);
                }
            }];
            [task resume];
        }
    }];
    
}

@end
