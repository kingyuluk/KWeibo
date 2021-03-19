//
//  KWBUserModel.m
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import "KWBUserModel.h"

@implementation KWBUserModel

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        _userID = dic[@"userID"];
        _refreshToken = dic[@"refreshToken"];
        _accessToken = dic[@"accessToken"];
        _expirationDate = dic[@"expirationDate"];
    }
    return self;
}

@end
