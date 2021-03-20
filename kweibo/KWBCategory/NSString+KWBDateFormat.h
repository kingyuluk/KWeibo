//
//  NSString+KWBDateFormat.h
//  kweibo
//
//  Created by Kingyu on 2021/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (KWBDateFormat)

+ (NSString *)kwb_stringFormatWithDateString:(NSString *)dateStr;

@end

NS_ASSUME_NONNULL_END
