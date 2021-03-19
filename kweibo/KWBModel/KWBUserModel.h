//
//  KWBUserModel.h
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import <Foundation/Foundation.h>
#import "KWBBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KWBUserModel : KWBBaseModel

/**
 用户ID
 */
@property (nonatomic, strong) NSString *userID;

/**
 认证口令
 */
@property (nonatomic, strong) NSString *accessToken;

/**
 认证过期时间
 */
@property (nonatomic, strong) NSDate *expirationDate;

/**
 当认证口令过期时用于换取认证口令的更新口令
 */
@property (nonatomic, strong) NSString *refreshToken;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
