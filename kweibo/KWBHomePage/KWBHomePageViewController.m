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

NSString * const kWeiboCell   = @"WeiboCell";

@interface KWBHomePageViewController ()<UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UIButton *      LoginButton;

@property (nonatomic, strong, readwrite) KWBUserModel *  currentUser;
@property (nonatomic, strong, readwrite) NSArray<KWBStatusModel *> * statuses;   // 微博列表
@property (nonatomic, strong, readwrite) KWBStatusModel * tempModel;
@property (nonatomic, strong, readwrite) KWBTabBarViewController * tabBarViewController;

@property (nonatomic, assign, readwrite) BOOL isQuerySuccess;

@end

@implementation KWBHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarLight];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"auth_dic"][@"access_token"]){
        [self queryUserInfo];
    }else{
        [self authAccountInCustomView];
    }
}

- (void)setupSubviews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = LightGrayColor;
    _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 100.0f;
    
    [_tableView registerClass:KWBStatusCell.class forCellReuseIdentifier:kWeiboCell];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:kNotification_AuthorizeSuccess object:nil];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _tabBarViewController = [[KWBTabBarViewController alloc] init];
    [self addChildViewController:_tabBarViewController];
    _tabBarViewController.delegate = self;
    [self.view addSubview:_tabBarViewController.view];
}

#pragma mark - UITableViewDDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KWBStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:kWeiboCell];
    cell.imageView.image = nil;
    [cell loadDataWithModel:_statuses[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _statuses.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _statuses[indexPath.row].cellHeight;
}


#pragma mark - query data

- (void)loginSuccess{
    [self queryUserInfo];
    if (_isQuerySuccess) {
        [self queryStatuses];
    }
}

- (void)queryUserInfo {
    NSString * kAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_dic"][@"access_token"];
    NSString * kUid = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_dic"][@"uid"];
    
    NSString *urlString = [[KWBBaseURLs apiURL] stringByAppendingFormat:@"2/users/show.json?access_token=%@&uid=%@", kAccessToken, kUid];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic[@"error"]) {
            self.isQuerySuccess = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:dic[@"error"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *conform = [UIAlertAction actionWithTitle:@"使用本地json数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self loadLocalStatuses];
                }];
                [alert addAction:conform];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }else{
            self.isQuerySuccess = YES;
            self.currentUser = [[KWBUserModel alloc] initWithDictionary:dic];
            [self queryStatuses];
        }
    }];
    [task resume];
}

- (void)queryStatuses {
    NSString * kAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_dic"][@"access_token"];
    NSString *urlString = [[KWBBaseURLs apiURL] stringByAppendingFormat:@"2/statuses/friends_timeline.json?access_token=%@", kAccessToken];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
    }];
    [task resume];
}

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

#pragma mark - auth account

- (void)authAccountInCustomView {  // 使用自定义的 WKWebView 进行微博登陆
    KWBOAuthWebViewController * oAuthViewController = [[KWBOAuthWebViewController alloc] init];
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
        [self.tabBarViewController.view setFrame:CGRectMake(kIntervelFromScreenLeft , SCREEN_HEIGHT - kTabBarHeight - 20, kStatusCellWidth, kTabBarHeight)];
    } completion:nil];
}

- (void)setNavigationBarLight{
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}


@end
