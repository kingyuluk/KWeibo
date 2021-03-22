//
//  KWBCacheManager.h
//  kweibo
//
//  Created by Kingyu on 2021/3/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^KWBCacheQueryCompleteBlock)(NSData * _Nullable data, BOOL hasCache);

@interface KWBCacheManager : NSObject

+ (instancetype)sharedInstance;

#pragma mark - store data
- (void)storeCacheToDisk:(NSData *)data ForKey:(NSString *)key;
- (void)storeCacheToDisk:(NSData *)data ForKey:(NSString *)key withExtension:(nullable NSString *)extension;

- (void)storeCacheToMemory:(NSData *)data ForKey:(NSString *)key;

- (void)storeCache:(NSData *)data ForKey:(NSString *)key;
- (void)storeCache:(NSData *)data ForKey:(NSString *)key withExtension:(nullable NSString *)extension;

#pragma mark - query cache
- (void)queryCache:(NSString *)key completion:(KWBCacheQueryCompleteBlock)completion;
- (void)queryCache:(NSString *)key withExtension:(nullable NSString *)extension completion:(KWBCacheQueryCompleteBlock)completion;

#pragma mark - clean cache
- (void)cleanDiskCache;
- (void)cleanAllCache;

- (NSUInteger)totalDiskSize;

@end

NS_ASSUME_NONNULL_END
