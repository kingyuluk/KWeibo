//
//  KWBLoadMoreControl.h
//  kweibo
//
//  Created by Kingyu on 2021/3/23.
//

#import <UIKit/UIKit.h>

@class KWBHomePageViewController;

NS_ASSUME_NONNULL_BEGIN

typedef void(^KWBLoadMoreActionBlock)(void);

typedef NS_ENUM(NSInteger, KWBLoadMoreStatus){
    KWBLoadMoreStatusIdle,
    KWBLoadMoreStatusReady,
    KWBLoadMoreStatusWillLoad,
    KWBLoadMoreStatusLoading,
};

@interface KWBLoadMoreControl : UIControl

@property (nonatomic, strong, readwrite) KWBLoadMoreActionBlock loadMoreActionBlock;
@property (nonatomic, weak, readwrite) KWBHomePageViewController * loadDelegate;

- (void)readyToLoad;
- (void)startLoading;
- (void)endLoading;
- (void)willload;

@end

NS_ASSUME_NONNULL_END
