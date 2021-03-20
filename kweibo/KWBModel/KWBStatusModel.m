//
//  KWBStatusModel.m
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import "KWBStatusModel.h"
#import "KWBStatusCell.h"

@implementation KWBStatusModel

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super initWithDictionary:dic];
    if (self && self.user) {
        _user = [[KWBUserModel alloc] initWithDictionary:(NSDictionary *)_user];
    }
    return self;
}

@end
