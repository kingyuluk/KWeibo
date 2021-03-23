//
//  OAuthWebViewController.m
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import "KWBOAuthWebViewController.h"
#import "KWBBaseURLs.h"

@interface KWBOAuthWebViewController ()<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong, readwrite) WKWebView * webView;

@end

@implementation KWBOAuthWebViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initTopBar];
    
    NSString *url = [[KWBBaseURLs apiURL] stringByAppendingFormat:@"oauth2/authorize?client_id=%@&redirect_uri=%@&response_type=code&display=mobile", kAppKey, kRedirectUri];
     NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT / 8, SCREEN_WIDTH, SCREEN_HEIGHT / 8 * 7)];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
}

#pragma mark - WKWebView Delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * url = navigationResponse.response.URL.absoluteString;
    if ([url hasPrefix:kRedirectUri]) {
            NSRange range = [url rangeOfString:@"code="];
            NSRange rangeOfCode = NSMakeRange(range.length + range.location, url.length - (range.length + range.location));
            NSString *code = [url substringWithRange:rangeOfCode];
    
            NSMutableString * accessTokenURLString = [NSMutableString stringWithString:[KWBBaseURLs apiURL]];
            [accessTokenURLString appendFormat:@"oauth2/access_token?client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@", kAppKey, kAppSecret, kRedirectUri, code];
    
            NSURL *accessTokenURL = [NSURL URLWithString:accessTokenURLString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:accessTokenURL];
            [request setHTTPMethod:@"POST"];
            NSString *bodyString = @"type=focus-c";
            NSData *body = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:body];
            
            NSURLSession * session =  [NSURLSession sharedSession];
            NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:dictionary forKey:@"auth_dic"];                
                [userDefaults synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismiss];
                });
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_AuthorizeSuccess" object:nil];
            }];
            [task resume];
        }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark -

- (void) dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) initTopBar {
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT / 8 - SCREEN_HEIGHT / 14, SCREEN_WIDTH, SCREEN_HEIGHT / 14)];
    topBar.backgroundColor = [UIColor darkGrayColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 4, 0, SCREEN_WIDTH / 2, topBar.frame.size.height)];
    title.text = @"登陆 - 新浪微博";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;

    [topBar addSubview:title];
    
    [self.view addSubview:topBar];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(15.0f, topBar.frame.origin.y + topBar.frame.size.height / 2 - 10, 20.0f, 20.0f);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"icon_left_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
}

@end
