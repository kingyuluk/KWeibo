//
//  KWBHomePageViewController.m
//  kweibo
//
//  Created by Kingyu on 2021/3/12.
//

#import <Weibo_SDK/WeiboSDK.h>
#import "AppDelegate.h"
#import "KWBHomePageViewController.h"
#import "KWBStatusCell.h"
#import "KWBStatusModel.h"
#import "KWBTabBarViewController.h"
#import "KWBUserModel.h"
#import "KWBBaseURLs.h"
#import "KWBOAuthWebViewController.h"
#import "KWBLoadMoreControl.h"

NSString * const kWeiboCell   = @"WeiboCell";

@interface KWBHomePageViewController ()<UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) KWBUserModel *                                 currentUser;
@property (nonatomic, strong) NSMutableArray<KWBStatusModel *>                * statuses;   // 微博列表
@property (nonatomic, strong) KWBStatusModel                                 * tempModel;
@property (nonatomic, strong) KWBTabBarViewController             * tabBarViewController;
@property (nonatomic, strong) KWBLoadMoreControl                        *loadMoreControl;
@property (nonatomic, strong) NSMutableArray<NSNumber *>                   * offSetArray;

@property (nonatomic, assign, readwrite) BOOL isQuerySuccess;

@end

@implementation KWBHomePageViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pageSize = 20;
        _pageIndex = 1;
        _statuses = [NSMutableArray array];
        _offSetArray = [[NSMutableArray alloc] initWithObjects:@0.0, @0.0, @0.0, nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarLight];
    self.view.userInteractionEnabled = YES;
    self.view.backgroundColor = LightGrayColor;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setupTableView];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"auth_dic"][@"access_token"]){
        [self queryUserInfo];
    }else{
        [self authAccountInCustomView];
    }
//    [self queryStatusesFromServer:NO pageIndex:self.pageIndex pageSize:self.pageSize];
}

- (void)viewWillAppear:(BOOL)animated{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = LightGrayColor;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    [self.tableView registerClass:KWBStatusCell.class forCellReuseIdentifier:kWeiboCell];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:kNotification_AuthorizeSuccess object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.tabBarViewController = [[KWBTabBarViewController alloc] init];
    [self addChildViewController:self.tabBarViewController];
    self.tabBarViewController.delegate = self;
    [self.view addSubview:self.tabBarViewController.view];
    
    self.loadMoreControl = [[KWBLoadMoreControl alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.loadMoreControl.backgroundColor = WhiteColor;
    self.loadMoreControl.hidden = YES;
    self.loadMoreControl.loadDelegate = self;
    [self.tableView addSubview:self.loadMoreControl];
    
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"] && object == self.tableView) {
        [self.loadMoreControl setFrame:CGRectMake(0, _tableView.contentSize.height - 10, SCREEN_WIDTH, 40)];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KWBStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:kWeiboCell forIndexPath:indexPath];
    KWBStatusModel * model = self.statuses[indexPath.row];
    [cell updateDataWithModel:model];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.statuses.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - query data

- (void)loginSuccess{
    [self queryUserInfo];
    if (self.isQuerySuccess) {
        [self queryStatusesFromServer:YES pageIndex:self.pageIndex pageSize:self.pageSize];
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
                    [self queryStatusesFromServer:NO pageIndex:self.pageIndex pageSize:self.pageSize];
                }];
                [alert addAction:conform];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }else{
            self.isQuerySuccess = YES;
            self.currentUser = [[KWBUserModel alloc] initWithDictionary:dic];
            [self queryStatusesFromServer:YES pageIndex:self.pageIndex pageSize:self.pageSize];
        }
    }];
    [task resume];
}

- (void)queryStatusesFromServer:(BOOL)fromServer pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    if (!fromServer) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"statuses" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        [self handlerStatusesData:data];
        return;
    }
    NSString * kAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_dic"][@"access_token"];
    NSString *urlString = [[KWBBaseURLs apiURL] stringByAppendingFormat:@"2/statuses/friends_timeline.json?access_token=%@&page=%ld&count=%ld", kAccessToken, pageIndex, pageSize];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.pageIndex++;
        [self handlerStatusesData:data];
    }];
    [task resume];
}

- (void)handlerStatusesData:(NSData *)data{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray<NSDictionary *> *statusTemps = dic[@"statuses"];
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NSDictionary *status in statusTemps) {
        KWBStatusModel *model = [[KWBStatusModel alloc] initWithDictionary:status];
        [models addObject:model];
    }
    [self.statuses addObjectsFromArray:models];
    if(self.statuses.count > 0) {
        NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
        for(NSInteger row = self.statuses.count - models.count; row < self.statuses.count; row++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
        }
        dispatch_async_in_mainqueue_safe(^{
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
            [self.tableView endUpdates];
            [self.loadMoreControl endLoading];
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
CGFloat lastReloadY = 400;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    lastOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // loadmore control
    CGFloat bottomOffset = scrollView.contentSize.height - scrollView.contentOffset.y - SCREEN_HEIGHT;
    if (bottomOffset < 0 && bottomOffset > -40) {
        [self.loadMoreControl readyToLoad];
    }else if (bottomOffset <= -40) {
        [self.loadMoreControl willload];
    }
    
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    if (currentOffsetY - lastReloadY > 200) {
        [self.tableView reloadData];
        lastReloadY = currentOffsetY;
    }
    
    [self.offSetArray removeObjectAtIndex:0];
    [self.offSetArray addObject:[NSNumber numberWithFloat:currentOffsetY]];
    if ([self judgeDirection] == 1) {
        [self showupTabBar];
    }else if([self judgeDirection] == 2){
        [self dissmissTabBar];
    }
}

- (NSInteger)judgeDirection{
    NSInteger increasingFlag = 0;
    NSInteger decreasingFlag = 0;
    for (int i = 1; i < self.offSetArray.count; ++i) {
        if (self.offSetArray[i].floatValue - self.offSetArray[i-1].floatValue < 0) {
            ++decreasingFlag;
        }
        
        if (self.offSetArray[i].floatValue - self.offSetArray[i-1].floatValue > 0) {
            ++increasingFlag;
        }
    }
    
    if (decreasingFlag > 1) {
        return 1;
    }else if (increasingFlag > 1){
        return 2;
    }else{
        return 0;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat bottomOffset = scrollView.contentSize.height - scrollView.contentOffset.y - SCREEN_HEIGHT;
    if (bottomOffset < 1) {
        [self.loadMoreControl startLoading];
        
    }
}

- (void)dissmissTabBar {
    [UIView transitionWithView:self.tabBarViewController.view duration:0.3f options:UIViewAnimationOptionCurveLinear animations:^{
        self.tabBarViewController.view.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT + kTabBarHeight + 20);
    } completion:nil];
}

- (void)showupTabBar {
    [UIView transitionWithView:self.tabBarViewController.view duration:0.3f options:UIViewAnimationOptionCurveLinear animations:^{
        [self.tabBarViewController.view setFrame:CGRectMake(kIntervelFromScreenLeft , SCREEN_HEIGHT - kTabBarHeight - 20, kStatusCellWidth, kTabBarHeight)];
    } completion:nil];
}

- (void)setNavigationBarLight{
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

@end
