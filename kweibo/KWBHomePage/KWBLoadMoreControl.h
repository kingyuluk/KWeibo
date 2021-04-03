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
    KWBLoadMoreStatusReady,
    KWBLoadMoreStatusWillLoad,
    KWBLoadMoreStatusLoading,
    KWBLoadMoreStatusFinish,
    KWBLoadMoreStatusIdle,
};

typedef NS_ENUM(NSInteger, KWBLoadMoreControlType){
    KWBLoadMoreControlTypeTop,
    KWBLoadMoreControlTypeBottom
};

@interface KWBLoadMoreControl : UIControl

@property (nonatomic, strong, readwrite) KWBLoadMoreActionBlock         loadMoreActionBlock;
@property (nonatomic, weak, readwrite)   KWBHomePageViewController           * loadDelegate;
@property (nonatomic, assign, readwrite) KWBLoadMoreStatus                       loadStatus;
@property (nonatomic, assign, readwrite) KWBLoadMoreControlType                        type;

- (void)readyToLoad;
- (void)startLoading;
- (void)endLoading;
- (void)willload;
- (void)resetLoad;

@end

NS_ASSUME_NONNULL_END
