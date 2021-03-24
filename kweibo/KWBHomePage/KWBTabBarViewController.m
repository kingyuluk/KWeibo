//
//  KWBTabBarViewController.m
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import <AudioToolbox/AudioToolbox.h>
#import "KWBTabBarViewController.h"
#import "KWBOAuthWebViewController.h"
#import "KWBHomePageViewController.h"
#import "KWBStatusModel.h"
#import "KWBCacheManager.h"
#import "KWBUserModel.h"
#import "UIButton+KWBButton.h"
#import "UIImageView+KWBImage.h"

@interface KWBTabBarViewController ()<UIViewControllerTransitioningDelegate>

@property (nonatomic, strong, readwrite) UIButton * postButton;
@property (nonatomic, strong, readwrite) UIButton * userCenterButton;
@property (nonatomic, strong, readwrite) UIButton * searchButton;
@property (nonatomic, strong, readwrite) UIView       *avatarContainerView;
@property (nonatomic, strong, readwrite) UIImageView  *avatarImageView;

@end

@implementation KWBTabBarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(kIntervelFromScreenLeft , SCREEN_HEIGHT - kTabBarHeight - 20, kStatusCellWidth, kTabBarHeight);
    self.view.backgroundColor = DarkGrayColor;
    self.view.layer.cornerRadius = 15;
    self.view.layer.masksToBounds = YES;
    [self.delegate addObserver:self forKeyPath:@"currentUser" options:NSKeyValueObservingOptionNew context:nil];
    
    [self setupSubviews];
}

- (void)setupSubviews {
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = self.view.bounds;
    [self.view addSubview:effectview];
    
    CGFloat kPostButtonWidth = 20;
    self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.postButton.frame = CGRectMake(kPostButtonWidth, self.view.frame.size.height / 2 - kPostButtonWidth / 2, kPostButtonWidth, kPostButtonWidth);
    self.postButton.tag = KWBTabBarTagPost;
    [self.postButton setImage:[UIImage imageNamed:@"icon_post"] forState:UIControlStateNormal];
    [self.postButton setEnLargeEdge:-kPostButtonWidth * 2];
    [self.postButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [self.view addSubview:self.postButton];
    
    CGFloat kUserCenterButtonWidth = 30;
    self.userCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.userCenterButton.frame = CGRectMake(self.view.frame.size.width / 2 - kUserCenterButtonWidth / 2, self.view.frame.size.height / 2 - kUserCenterButtonWidth / 2, kUserCenterButtonWidth, kUserCenterButtonWidth);
    self.userCenterButton.tag = KWBTabBarTagUserCenter;
    [self.userCenterButton setImage:[UIImage imageNamed:@"icon_userCenter"] forState:UIControlStateNormal];
    [self.userCenterButton setEnLargeEdge:-kUserCenterButtonWidth * 2];
    [self.userCenterButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [self.view addSubview:self.userCenterButton];
    
    CGFloat kSearchButtonWidth = 20;
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchButton.frame = CGRectMake(self.view.frame.size.width - 2 * kSearchButtonWidth, self.view.frame.size.height / 2 - kSearchButtonWidth / 2, kSearchButtonWidth, kSearchButtonWidth);
    self.searchButton.tag = KWBTabBarTagSearch;
    [self.searchButton setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
    [self.searchButton setEnLargeEdge:-kSearchButtonWidth * 2];
    [self.searchButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [self.view addSubview:self.searchButton];
    
    self.avatarContainerView = [[UIView alloc] initWithFrame:CGRectMake(-5, -5, 40, 40)];
    self.avatarContainerView.layer.cornerRadius = self.avatarContainerView.frame.size.width / 2;
    self.avatarContainerView.clipsToBounds = YES;
    self.avatarContainerView.backgroundColor = [UIColor whiteColor];
    
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 36, 36)];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    self.avatarImageView.clipsToBounds = YES;
    [self.avatarContainerView addSubview:self.avatarImageView];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentUser"] && object == self.delegate) {
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
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"auth_dic"][@"access_token"]) {
        [self.delegate authAccountInCustomView];
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
                [self.delegate.tableView reloadData];
                break;
                
            default:
                break;
        }
    }
}

- (void)dealloc {
    [self.delegate removeObserver:self forKeyPath:@"currentUser"];
}

@end
