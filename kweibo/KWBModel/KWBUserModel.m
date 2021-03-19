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
    self = [super initWithDictionary:dic];
    if (self) {
        _description_text = dic[@"description"];
    }
    return self;
}

@end
