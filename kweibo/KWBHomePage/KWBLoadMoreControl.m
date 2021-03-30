//
//  KWBLoadMoreControl.m
//  kweibo
//
//  Created by Kingyu on 2021/3/23.
//

#import "KWBLoadMoreControl.h"
#import "KWBHomePageViewController.h"

@interface KWBLoadMoreControl ()

@property (nonatomic, strong, readonly)  UILabel                     * label;
@property (nonatomic, strong, readwrite) UIImageView                 * indicatorView;
@property (nonatomic, strong, readwrite) UITableView                 * superView;

@end

@implementation KWBLoadMoreControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        _label.text = @"Pull to refresh";
        _label.backgroundColor = LightGrayColor;
        _label.textColor = LightFontColor;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        _indicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon30BlackSmall"]];
        _indicatorView.frame = CGRectMake(SCREEN_WIDTH / 2 - 20, 0, 40, 40);
        [self addSubview:_indicatorView];
    }
    return self;
}

- (void)layoutSubviews{
    if (!self.superView) {
        self.superView = (UITableView *)[self superview];
    }
    [self.superView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    self.indicatorView.frame = CGRectMake(SCREEN_WIDTH / 2 - 20, 0, 40, 40);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"] && object == self.superView) {
        if (self.type == KWBLoadMoreTypeMore) {
            [self setFrame:CGRectMake(0, self.superView.contentSize.height, SCREEN_WIDTH, 40)];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setLoadStatus:(KWBLoadMoreStatus)loadStatus{
    _loadStatus = loadStatus;
    switch (_loadStatus) {
        case KWBLoadMoreStatusFinish:
        {
            _label.text = @"Finished";
            UIEdgeInsets insets = self.loadDelegate.tableView.contentInset;
            if (self.type == KWBLoadMoreTypeMore) {
                insets.bottom -= 50.0;
            }else if (self.type == KWBLoadMoreTypeRefresh) {
                insets.top -= 50.0;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.loadDelegate.tableView.contentInset = insets;
            });
            break;
        }
            
        case KWBLoadMoreStatusLoading:
        {
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
            [generator impactOccurred];
            _label.text = @"loading...";
            UIEdgeInsets insets = self.loadDelegate.tableView.contentInset;
//            [self.loadDelegate queryStatusesFromServer:YES pageIndex:self.loadDelegate.pageIndex pageSize:self.loadDelegate.pageSize];
            if (self.type == KWBLoadMoreTypeMore) {
                insets.bottom += 50.0;
                self.loadDelegate.tableView.contentInset = insets;
                [self.loadDelegate queryStatusesFromServer:NO pageIndex:self.loadDelegate.pageIndex pageSize:self.loadDelegate.pageSize];
            }else if (self.type == KWBLoadMoreTypeRefresh) {
                insets.top += 50.0;
                self.loadDelegate.tableView.contentInset = insets;
                [self.loadDelegate getNewestStatus];
            }
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
    if (self.loadStatus == KWBLoadMoreStatusFinish || self.loadStatus == KWBLoadMoreStatusWillLoad) {
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
        self.loadStatus = KWBLoadMoreStatusFinish;
    }
}

- (void)dealloc
{
    [self.superview removeObserver:self forKeyPath:@"contentSize"];
}

@end
