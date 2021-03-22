//
//  KWBCacheManager.m
//  kweibo
//
//  Created by Kingyu on 2021/3/22.
//

#import "KWBCacheManager.h"
#import "objc/runtime.h"
#import <CommonCrypto/CommonDigest.h>

@interface KWBCacheManager ()

@property (nonatomic, strong, readonly) dispatch_queue_t ioQueue;
@property (nonatomic, strong, readonly) NSCache *        memoryCache;
@property (nonatomic, strong, readonly) NSFileManager *  diskCache;
@property (nonatomic, strong, readonly) NSURL *          diskPathURL;

@end

@implementation KWBCacheManager

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static KWBCacheManager * instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ioQueue = dispatch_queue_create("com.kingyu.ioQueue", DISPATCH_QUEUE_CONCURRENT);
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.name = @"imageCache";
        _memoryCache.totalCostLimit = 50 * 1024 * 1024;
        
        _diskCache = [NSFileManager defaultManager];
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString * path = [paths lastObject];
        NSString * diskPathString = [NSString stringWithFormat:@"%@%@",path,@"/imageCache"];
        BOOL isDirectory;
        BOOL isExisted = [_diskCache fileExistsAtPath:diskPathString isDirectory:&isDirectory];
        if(!isExisted || !isDirectory){
            [_diskCache createDirectoryAtPath:diskPathString withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _diskPathURL = [NSURL fileURLWithPath:diskPathString];
    }
    return self;
}

#pragma mark - store data

- (void)storeCacheToMemory:(NSData *)data ForKey:(NSString *)key{
    [_memoryCache setObject:data forKey:key];
}

- (void)storeCacheToDisk:(NSData *)data ForKey:(NSString *)key{
    [self storeCacheToDisk:data ForKey:key withExtension:nil];
}

- (void)storeCacheToDisk:(NSData *)data ForKey:(NSString *)key withExtension:(NSString *)extension{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_ioQueue, ^{
        [weakSelf.diskCache createFileAtPath:[self diskPathForKey:key withExtension:extension] contents:data attributes:nil];
    });
}

- (void)storeCache:(NSData *)data ForKey:(NSString *)key{
    [self storeCache:data ForKey:key withExtension:nil];
}

- (void)storeCache:(NSData *)data ForKey:(NSString *)key withExtension:(NSString *)extension{
    [self storeCacheToMemory:data ForKey:key];
    [self storeCacheToDisk:data ForKey:key withExtension:extension];
}

#pragma mark - query cache

- (void)queryCache:(NSString *)key completion:(KWBCacheQueryCompleteBlock)completion{
    [self queryCache:key withExtension:nil completion:completion];
}

- (void)queryCache:(NSString *)key withExtension:(NSString *)extension completion:(KWBCacheQueryCompleteBlock)completion{
    dispatch_barrier_async(_ioQueue, ^{
        NSData *data = [self dataFromMemory:key];
        if(!data){
            data = [self dataFromDisk:key withExtension:extension];
        }
        if (data) {
            completion(data, YES);
        }else{
            completion(nil, NO);
        }
    });
}


- (NSData *)dataFromDisk:(NSString *)key{
    return [self dataFromDisk:key withExtension:nil];
}

- (NSData *)dataFromDisk:(NSString *)key withExtension:(NSString *)extension{
    return [NSData dataWithContentsOfFile:[self diskPathForKey:key withExtension:extension]];
}

- (NSData *)dataFromMemory:(NSString *)key{
    return [_memoryCache objectForKey:key];
}

#pragma mark - clean cache

- (void)cleanMemoryCache{
    [_memoryCache removeAllObjects];
}

- (void)cleanDiskCache{
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.ioQueue, ^{
        [weakSelf.diskCache removeItemAtURL:weakSelf.diskPathURL error:nil];
        [weakSelf.diskCache createDirectoryAtPath:weakSelf.diskPathURL.path withIntermediateDirectories:YES attributes:nil error:nil];
    });
}

- (void)cleanAllCache{
    [self cleanDiskCache];
    [self cleanMemoryCache];
}

#pragma mark - cache info

- (NSUInteger)totalDiskSize {
    __block NSUInteger size = 0;
    __weak typeof(self) weakSelf = self;
    dispatch_sync(_ioQueue, ^{
        NSDirectoryEnumerator * enumerator = [weakSelf.diskCache enumeratorAtPath:weakSelf.diskPathURL.path];
        for (NSString * fileName in enumerator) {
            NSString * filePath = [self.diskPathURL.path stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attributes = [weakSelf.diskCache attributesOfItemAtPath:filePath error:nil];
            size += [attributes fileSize];
        }
    });
    return size;
}

#pragma mark - helper

- (NSString *)diskPathForKey:(NSString *)key{
    return [self diskPathForKey:key withExtension:nil];
}

- (NSString *)diskPathForKey:(NSString *)key withExtension:(NSString *)extension{
    NSString * fileName = [self SHA256:key];
    NSString * cachePathForKey = [_diskPathURL URLByAppendingPathComponent:fileName].path;
    if(extension){
        cachePathForKey =  [cachePathForKey stringByAppendingFormat:@".%@",extension];
    }
    return cachePathForKey;
}

- (NSString *)SHA256:(NSString *)key {
    if(!key) {
        return @"temp";
    }
    const char *str = [key UTF8String];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    return output;
}


@end
