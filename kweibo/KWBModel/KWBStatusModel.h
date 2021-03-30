//
//  KWBStatusModel.h
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import <UIKit/UIKit.h>
#import "KWBBaseModel.h"
#import "KWBHomePageViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class KWBUserModel;

@interface KWBStatusModel : KWBBaseModel

// 用户地理信息字段
@property (strong, nonatomic) NSDictionary *geo;

// 用户ID
@property (assign, nonatomic) NSInteger ID;

// 用户对象
@property (strong, nonatomic) KWBUserModel *user;

// 评论内容
@property (copy, nonatomic) NSString *text;

// 创建时间
@property (copy, nonatomic) NSString *created_at;

// 微博的可见性及指定可见分组信息
@property (copy, nonatomic) id visible;

// 表态数量
@property (assign, nonatomic) NSInteger attitudes_count;

// 微博来源
@property (strong, nonatomic) NSString *source;

// 是否被截断，true：是，false：否
@property (assign, nonatomic) BOOL truncated;

// 来源type
@property (assign, nonatomic) NSInteger source_type;

// 微博字符串型id
@property (copy, nonatomic) NSString *idstr;

// 微博id
@property (assign, nonatomic) long long id;

// 微博mid
@property (assign, nonatomic) long long mid;

// 评论数
@property (assign, nonatomic) NSInteger comments_count;

// 图片数组
@property (strong, nonatomic) NSArray *pic_urls;

// 缩略图片地址，没有时不返回此字段
@property (copy, nonatomic) NSString *thumbnail_pic;

// 中等尺寸图片地址，没有时不返回此字段
@property (copy, nonatomic) NSString *bmiddle_pic;

// 原始图片地址，没有时不返回此字段
@property (copy, nonatomic) NSString *original_pic;;

// 转发数
@property (assign, nonatomic) NSInteger reposts_count;

// 是否已收藏，true：是，false：否
@property (assign, nonatomic) BOOL favorited;

// 用户类型
@property (assign, nonatomic) NSInteger userType;

// 被转发的原微博信息字段，当该微博为转发微博时返回
@property (strong, nonatomic) NSDictionary *retweeted_status;

@property (assign, nonatomic, readwrite) NSData * imageData;

@end

NS_ASSUME_NONNULL_END
