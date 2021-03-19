//
//  NSString+KWBDateFormat.m
//  kweibo
//
//  Created by Kingyu on 2021/3/16.
//

#import "NSString+KWBDateFormat.h"

@implementation NSString (KWBDateFormat)

+ (NSString *)kwb_stringFormatWithDateString:(NSString *)dateStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *inputDate = [formatter dateFromString:dateStr];
    
    NSTimeInterval timeInterval = -1 * [inputDate timeIntervalSinceNow];
    NSString *result;
    
    NSDateFormatter *resultFormatter = [[NSDateFormatter alloc] init];
    [resultFormatter setLocale:[NSLocale currentLocale]];
    [resultFormatter setDateFormat:@"HH:mm"];
    
    long dateInterval = timeInterval / 60 / 60;
    if (dateInterval < 24) {
        
        result = [NSString stringWithFormat:@"今天 %@", [resultFormatter stringFromDate:inputDate]];
    }else if (dateInterval < 48) {
        
        result = [NSString stringWithFormat:@"昨天 %@", [resultFormatter stringFromDate:inputDate]];
    }else{
        [resultFormatter setDateFormat:@"M.dd HH:mm"];
        result = [resultFormatter stringFromDate:inputDate];
    }
    return result;
}


@end
