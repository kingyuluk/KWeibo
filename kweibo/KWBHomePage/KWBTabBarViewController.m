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

extern NSString * kAccessToken;

@interface KWBTabBarViewController ()<UIViewControllerTransitioningDelegate>

@property (nonatomic, strong, readonly) UIButton * postButton;
@property (nonatomic, strong, readonly) UIButton * userCenterButton;
@property (nonatomic, strong, readonly) UIButton * searchButton;

@end

@implementation KWBTabBarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(SCREEN_WIDTH / 10 , SCREEN_HEIGHT - kTabBarHeight - 20, kTabBarWidth, kTabBarHeight);
    self.view.backgroundColor = DarkGrayColorAlpha40;
    self.view.layer.cornerRadius = 15;
    
    [self setupSubviews];
}

- (void)setupSubviews {
    CGFloat kPostButtonWidth = 20;
    _postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _postButton.frame = CGRectMake(kPostButtonWidth, self.view.frame.size.height / 2 - kPostButtonWidth / 2, kPostButtonWidth, kPostButtonWidth);
    _postButton.tag = KWBTabBarTagPost;
    [_postButton setImage:[UIImage imageNamed:@"icon_post"] forState:UIControlStateNormal];
    _postButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _postButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentFill;
    [_postButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [self.view addSubview:_postButton];
    
    CGFloat kUserCenterButtonWidth = 30;
    _userCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _userCenterButton.frame = CGRectMake(self.view.frame.size.width / 2 - kUserCenterButtonWidth / 2, self.view.frame.size.height / 2 - kUserCenterButtonWidth / 2, kUserCenterButtonWidth, kUserCenterButtonWidth);
    _userCenterButton.tag = KWBTabBarTagUserCenter;
    [_userCenterButton setImage:[UIImage imageNamed:@"icon_userCenter"] forState:UIControlStateNormal];
    _userCenterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _userCenterButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentFill;
    [_userCenterButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [self.view addSubview:_userCenterButton];
    
    CGFloat kSearchButtonWidth = 20;
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchButton.frame = CGRectMake(self.view.frame.size.width - 2 * kSearchButtonWidth, self.view.frame.size.height / 2 - kSearchButtonWidth / 2, kSearchButtonWidth, kSearchButtonWidth);
    _searchButton.tag = KWBTabBarTagSearch;
    [_searchButton setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
    _searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _searchButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentFill;
    [_searchButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [self.view addSubview:_searchButton];
}

- (void)onTapAction:(UITapGestureRecognizer *)sender {
    if(!kAccessToken) {
        for(UIView *next = self.view.superview; next; next = next.superview){
            UIResponder *nextResponder = [next nextResponder];
            if([nextResponder isKindOfClass:[KWBHomePageViewController class]]){
                KWBHomePageViewController *vc = (KWBHomePageViewController *)nextResponder;
                [vc authAccountInCustomView];
            }
        }
    }else{
        switch (sender.view.tag) {
            case KWBTabBarTagPost:
                NSLog(@"post");
                break;
                
            case KWBTabBarTagUserCenter:
                NSLog(@"usercenter");
                break;
                
            case KWBTabBarTagSearch:
                NSLog(@"Search");
                break;
                
            default:
                break;
        }
    }
}

@end
