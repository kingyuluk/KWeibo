//
//  KWBTabBarViewController.m
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import "KWBTabBarViewController.h"
#import "KWBOAuthWebViewController.h"
#import "KWBHomePageViewController.h"
#import "KWBStatusModel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UIButton+KWBButton.h"
#import "UIImageView+KWBImage.h"

#import "KWBCacheManager.h"

extern NSString * kAccessToken;

@interface KWBTabBarViewController ()<UIViewControllerTransitioningDelegate>

@property (nonatomic, strong, readonly) UIButton * postButton;
@property (nonatomic, strong, readonly) UIButton * userCenterButton;
@property (nonatomic, strong, readonly) UIButton * searchButton;
@property (nonatomic, strong, readonly) UIView       *avatarContainerView;
@property (nonatomic, strong, readonly) UIImageView  *avatarImageView;

@end

@implementation KWBTabBarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(kIntervelFromScreenLeft , SCREEN_HEIGHT - kTabBarHeight - 20, kStatusCellWidth, kTabBarHeight);
    self.view.backgroundColor = DarkGrayColor;
    self.view.layer.cornerRadius = 15;
    self.view.layer.masksToBounds = YES;
    
    [self setupSubviews];
}

- (void)setupSubviews {
    [_delegate addObserver:self forKeyPath:@"currentUser" options:NSKeyValueObservingOptionNew context:nil];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = self.view.bounds;
    [self.view addSubview:effectview];
    
    CGFloat kPostButtonWidth = 20;
    _postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _postButton.frame = CGRectMake(kPostButtonWidth, self.view.frame.size.height / 2 - kPostButtonWidth / 2, kPostButtonWidth, kPostButtonWidth);
    _postButton.tag = KWBTabBarTagPost;
    [_postButton setImage:[UIImage imageNamed:@"icon_post"] forState:UIControlStateNormal];
    [_postButton setEnLargeEdge:-kPostButtonWidth * 2];
    [_postButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [self.view addSubview:_postButton];
    
    CGFloat kUserCenterButtonWidth = 30;
    _userCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _userCenterButton.frame = CGRectMake(self.view.frame.size.width / 2 - kUserCenterButtonWidth / 2, self.view.frame.size.height / 2 - kUserCenterButtonWidth / 2, kUserCenterButtonWidth, kUserCenterButtonWidth);
    _userCenterButton.tag = KWBTabBarTagUserCenter;
    [_userCenterButton setImage:[UIImage imageNamed:@"icon_userCenter"] forState:UIControlStateNormal];
    [_userCenterButton setEnLargeEdge:-kUserCenterButtonWidth * 2];
    [_userCenterButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [self.view addSubview:_userCenterButton];
    
    CGFloat kSearchButtonWidth = 20;
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchButton.frame = CGRectMake(self.view.frame.size.width - 2 * kSearchButtonWidth, self.view.frame.size.height / 2 - kSearchButtonWidth / 2, kSearchButtonWidth, kSearchButtonWidth);
    _searchButton.tag = KWBTabBarTagSearch;
    [_searchButton setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
    [_searchButton setEnLargeEdge:-kSearchButtonWidth * 2];
    [_searchButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [self.view addSubview:_searchButton];
    
    _avatarContainerView = [[UIView alloc] initWithFrame:CGRectMake(-5, -5, 40, 40)];
    _avatarContainerView.layer.cornerRadius = _avatarContainerView.frame.size.width / 2;
    _avatarContainerView.clipsToBounds = YES;
    _avatarContainerView.backgroundColor = [UIColor whiteColor];
    
    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 36, 36)];
    _avatarImageView.layer.cornerRadius = _avatarImageView.frame.size.width / 2;
    _avatarImageView.clipsToBounds = YES;
    [_avatarContainerView addSubview:_avatarImageView];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentUser"] && object == _delegate) {
        [self loginActionWithUserModel:[change valueForKey:@"new"]];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)loginActionWithUserModel:(KWBUserModel *)model {
    if(model.profile_image_url){
        dispatch_async_in_mainqueue_safe(^{
            [self.userCenterButton addSubview:self.avatarContainerView];
            [self.avatarImageView kwb_setImageWithUrl:[[NSURL alloc] initWithString:model.profile_image_url]];
        })
    }
}

#pragma mark - tap action

- (void)onTapAction:(UITapGestureRecognizer *)sender {
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [generator impactOccurred];
    if(!kAccessToken) {
        [_delegate authAccountInCustomView];
    }else{
        switch (sender.view.tag) {
            case KWBTabBarTagPost:{
                KWBCacheManager * manager = [KWBCacheManager sharedInstance];
                CGFloat cacheSize = [manager totalDiskSize] / 1024.0f / 1024.0f;
                [manager cleanAllCache];
                NSLog(@"clean cache:%.2fMB", cacheSize);
                break;
            }
            case KWBTabBarTagUserCenter:{
                KWBCacheManager * manager = [KWBCacheManager sharedInstance];
                CGFloat cacheSize = [manager totalDiskSize] / 1024.0f / 1024.0f;
                NSLog(@"Cache Size:%.2fMB", cacheSize);
                break;
            }
                
            case KWBTabBarTagSearch:
                NSLog(@"Search");
                break;
                
            default:
                break;
        }
    }
}

- (void)dealloc {
    [_delegate removeObserver:self forKeyPath:@"currentUser"];
}

@end
