//
//  KWBBaseModel.m
//  kweibo
//
//  Created by Kingyu on 2021/3/16.
//

#import "KWBBaseModel.h"
#import <objc/runtime.h>

@implementation KWBBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self modelFromDictionary:dic];
    }
    return self;
}

- (void)modelFromDictionary:(NSDictionary *)dic
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    
    u_int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *propertyCString = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:propertyCString encoding:NSUTF8StringEncoding];
        [keys addObject:propertyName];
    }
    free(properties);
    
    for (NSString *key in keys) {
        if ([dic valueForKey:key]) {
            [self setValue:[dic valueForKey:key] forKey:key];
        }
    }
}

@end
