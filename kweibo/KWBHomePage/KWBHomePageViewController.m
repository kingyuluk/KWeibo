//
//  KWBHomePageViewController.m
//  kweibo
//
//  Created by Kingyu on 2021/3/12.
//
#import "KWBHomePageViewController.h"
#import "KWBStatusCell.h"
#import "KWBTabBarViewController.h"
#import "KWBUserModel.h"
#import <Weibo_SDK/WeiboSDK.h>
#import "AppDelegate.h"
#import "KWBBaseURLs.h"
#import "KWBOAuthWebViewController.h"

extern NSString * kAccessToken;
NSString * const kWeiboCell   = @"WeiboCell";

@interface KWBHomePageViewController ()<UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UITableView *   tableView;
@property (nonatomic, strong, readonly) UIButton *      LoginButton;
@property (nonatomic, strong, readonly) KWBUserModel *  currentUser;

@property (nonatomic, strong, readwrite) NSArray<KWBStatusModel *> * statuses;   // 微博列表
@property (nonatomic, strong, readwrite) KWBStatusModel * tempModel;
@property (nonatomic, strong, readwrite) KWBTabBarViewController * tabBarViewController;

@end

@implementation KWBHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarLight];
    
#ifdef DEBUG
        kAccessToken = @"2.00Pbjc4H0EJSwt7eebda3d7b0Mu14p";
        [self loadLocalStatuses];
#endif
    if(!kAccessToken){
        [self authAccountInCustomView];
    }
}

- (void)setupSubviews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [_tableView registerClass:KWBStatusCell.class forCellReuseIdentifier:kWeiboCell];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStatuses) name:kNotification_AuthorizeSuccess object:nil];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _tabBarViewController = [[KWBTabBarViewController alloc] init];
    [self addChildViewController:_tabBarViewController];
    [self.view addSubview:_tabBarViewController.view];
    
}

#pragma mark - UITableViewDDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _statuses.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _statuses[indexPath.row].cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KWBStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:kWeiboCell];
    [cell loadDataWithModel:_statuses[indexPath.row]];
    return cell;
}


#pragma mark - privete
- (void)loadLocalStatuses{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"statuses" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray<NSDictionary *> *statusTemps = dic[@"statuses"];
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NSDictionary *status in statusTemps) {
        KWBStatusModel *model = [[KWBStatusModel alloc] initWithDictionary:status];
        [models addObject:model];
    }
    self.statuses = [models copy];
    
    if(self.statuses.count > 0) {
        NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
        for(NSInteger row = 0; row < self.statuses.count; row++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
        }
        dispatch_async_in_mainqueue_safe(^{
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
            [self.tableView endUpdates];
        })
    }
}

- (void)queryStatuses {
    NSString *urlString = [[KWBBaseURLs apiURL] stringByAppendingFormat:@"2/statuses/friends_timeline.json?access_token=%@", kAccessToken];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic[@"error"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:dic[@"error"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:conform];
            [self presentViewController:alert animated:YES completion:nil];
        }
        NSMutableArray<NSDictionary *> *statusTemps = dic[@"statuses"];
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for (NSDictionary *status in statusTemps) {
            KWBStatusModel *model = [[KWBStatusModel alloc] initWithDictionary:status];
            [models addObject:model];
        }
        self.statuses = [models copy];
        
        if(self.statuses.count > 0) {
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
            for(NSInteger row = 0; row < self.statuses.count; row++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
            }
            dispatch_async_in_mainqueue_safe(^{
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
                [self.tableView endUpdates];
            })
        }
    }];
    [task resume];
}

#pragma mark - auth account

- (void)authAccountInCustomView {  // 使用自定义的 WKWebView 进行微博登陆
    KWBOAuthWebViewController * oAuthViewController = [[KWBOAuthWebViewController alloc] initWithCompleteBlock:^{
        [self queryStatuses];
    }];
    oAuthViewController.transitioningDelegate = self;
    oAuthViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController presentViewController:oAuthViewController animated:YES completion:nil];
}

- (void)authAccount {
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    [request setRedirectURI:kRedirectUri];
    [request setScope:@"all"];
    [WeiboSDK sendRequest:request];
}

#pragma mark - UIScrollViewDelegate

CGFloat lastOffsetY = 0;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    lastOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    if (currentOffsetY - lastOffsetY > 5){
        [self dissmissTabBar];
    }
    else if (currentOffsetY - lastOffsetY < 5){
        [self showupTabBar];
    }
}

- (void)dissmissTabBar {
    [UIView transitionWithView:_tabBarViewController.view duration:0.3f options:UIViewAnimationOptionCurveLinear animations:^{
        self.tabBarViewController.view.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT + kTabBarHeight + 20);
    } completion:nil];
}

- (void)showupTabBar {
    [UIView transitionWithView:_tabBarViewController.view duration:0.3f options:UIViewAnimationOptionCurveLinear animations:^{
        [self.tabBarViewController.view setFrame:CGRectMake(SCREEN_WIDTH / 10 , SCREEN_HEIGHT - kTabBarHeight - 20, kTabBarWidth, kTabBarHeight)];
    } completion:nil];
}

- (void)setNavigationBarLight{
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}


@end
