//
//  KWBLoadMoreControl.m
//  kweibo
//
//  Created by Kingyu on 2021/3/23.
//

#import "KWBLoadMoreControl.h"
#import "KWBHomePageViewController.h"

@interface KWBLoadMoreControl ()

@property (nonatomic, strong, readonly) UILabel                     *label;

@end

@implementation KWBLoadMoreControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        _label.text = @"loading...";
        _label.backgroundColor = LightGrayColor;
        _label.textColor = LightFontColor;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

- (void)setLoadStatus:(KWBLoadMoreStatus)loadStatus{
    _loadStatus = loadStatus;
    switch (_loadStatus) {
        case KWBLoadMoreStatusIdle:
        {
            _label.text = @"Finished";
            UIEdgeInsets insets = self.loadDelegate.tableView.contentInset;
            insets.bottom -= 50.0;
            self.loadDelegate.tableView.contentInset = insets;
            break;
        }
            
        case KWBLoadMoreStatusLoading:
        {
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
            [generator impactOccurred];
            _label.text = @"loading...";
            UIEdgeInsets insets = self.loadDelegate.tableView.contentInset;
            insets.bottom += 50.0;
            self.loadDelegate.tableView.contentInset = insets;
//            [self.loadDelegate queryStatusesFromServer:YES pageIndex:self.loadDelegate.pageIndex pageSize:self.loadDelegate.pageSize];
            [self.loadDelegate queryStatusesFromServer:NO pageIndex:self.loadDelegate.pageIndex pageSize:self.loadDelegate.pageSize];
            break;
        }
            
        case KWBLoadMoreStatusReady:
            self.hidden = NO;
            _label.text = @"Pull to refresh";
            break;
            
        case KWBLoadMoreStatusWillLoad:
        {
            _label.text = @"Release to refresh";
            break;
        }
            
        default:
            break;
    }
}

- (void)readyToLoad{
    if (self.loadStatus == KWBLoadMoreStatusIdle || self.loadStatus == KWBLoadMoreStatusWillLoad) {
        self.loadStatus = KWBLoadMoreStatusReady;
    }
}

- (void)willload{
    if (self.loadStatus == KWBLoadMoreStatusReady) {
        self.loadStatus = KWBLoadMoreStatusWillLoad;
    }
}

- (void)startLoading{
    if (self.loadStatus != KWBLoadMoreStatusLoading) {
        self.loadStatus = KWBLoadMoreStatusLoading;
    }
}

- (void)endLoading{
    if (self.loadStatus == KWBLoadMoreStatusLoading){
        self.loadStatus = KWBLoadMoreStatusIdle;
    }
}


@end
