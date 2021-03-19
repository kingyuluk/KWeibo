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

#import "KWBOAuthWebViewController.h"

extern NSString * kAccessToken;
NSString * const kWeiboCell   = @"WeiboCell";

@interface KWBHomePageViewController ()<UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong, readonly) UITableView *   tableView;
@property (nonatomic, strong, readonly) UIButton *      LoginButton;
@property (nonatomic, strong, readonly) KWBUserModel *  currentUser;

@property (nonatomic, strong, readwrite) NSArray<KWBStatusModel *> * statuses;   // 微博列表
@property (nonatomic, strong, readwrite) KWBStatusModel * tempModel;

@end

@implementation KWBHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStatuses) name:@"kNotification_AuthorizeSuccess" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarLight];
    
#ifdef DEBUG
    kAccessToken = @"2.00Pbjc4H0EJSwt7eebda3d7b0Mu14p";
    [self loadStatuses];
#endif
        if(!kAccessToken){
    //        [self loginAction];
            [self authAccount];
        }
}

- (void)initView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [_tableView registerClass:KWBStatusCell.class forCellReuseIdentifier:kWeiboCell];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStatuses) name:kNotification_AuthorizeSuccess object:nil];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    KWBTabBarViewController * tabBarViewController = [[KWBTabBarViewController alloc] init];
    [self addChildViewController:tabBarViewController];
    [self.view addSubview:tabBarViewController.view];
    
    _tempModel = [KWBStatusModel new];
    _tempModel.text = @"#与书连理#🎁 党成立100年来，涌现了许多优秀共产党员。他们“我以我血荐轩辕”，如李大钊、向警予、江竹筠，等等；他们“鞠躬尽瘁，死而后已”，如焦裕禄、谷文昌、孔繁森，等等；他们“甘作春蚕吐尽丝”、“捧着一颗心来，不带半棵草去”，如李贞、张闻天、朱德，等等。";
    _tempModel.created_at = @"Tue Mar 16 21:02:45 +0800 2021";
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
    if (cell == nil) {
        cell = [[KWBStatusCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kWeiboCell];
    }
    [cell setDataWithModel:_statuses[indexPath.row]];
    return cell;
}


#pragma mark - privete
- (void)setNavigationBarLight{
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)loadStatuses {
    NSString *urlString = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/friends_timeline.json?access_token=%@", kAccessToken];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic[@"error"]) {
            NSLog(@"%@", dic[@"error"]);
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
                [self.tableView endUpdates];
            });
        }
        
    }];
    [task resume];
}

- (void)authAccount {
//    [[[[UIApplication sharedApplication] delegate] window] makeKeyWindow];
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    [request setRedirectURI:kRedirectUri];
    [request setScope:@"all"];
    [WeiboSDK sendRequest:request];
}

- (void)loginAction {  // 使用自定义的 WKWebView 进行微博登陆
    KWBOAuthWebViewController * oAuthViewController = [[KWBOAuthWebViewController alloc] initWithCompleteBlock:^{
        [self loadStatuses];
    }];
    oAuthViewController.transitioningDelegate = self;
    oAuthViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:oAuthViewController animated:YES completion:nil];
}


@end
