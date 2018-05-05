//
//  ViewController.m
//  H5WebSolutionDemo
//
//  Created by Walg on 2018/4/14.
//  Copyright © 2018年 Fly. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WKScriptManager.h"

#define ScreenWidth                     [UIScreen mainScreen].bounds.size.width
#define ScreenHeight                    [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UIScrollViewDelegate,WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, strong)WKWebView   *  webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL * fileURL = [NSURL fileURLWithPath:htmlPath];
    NSURL * baseURL = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:baseURL];
    [self.view addSubview:self.webView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [WKScriptManager destroy];//移除所有还没执行完的js回调
}

-(WKWebView *)webView{
    if (!_webView) {
        
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        WKScriptManager * manager = [[WKScriptManager alloc] initWithDelegate:self];
        
        [userContentController addScriptMessageHandler:manager name:manager.iOSMethodName];
        // WKWebView的配置
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController   = userContentController;
        //创建WKWebView
        
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) configuration:configuration];
        
        _webView.backgroundColor     = [UIColor whiteColor];
        [_webView.scrollView setBackgroundColor:[UIColor whiteColor]];
        _webView.scrollView.delegate = self;
        _webView.navigationDelegate  = self;
        _webView.UIDelegate          = self;
        manager.weakWebView = _webView;//必要的
    }
    return _webView;
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}
#pragma mark - WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    return [[WKWebView alloc]init];
}
// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    NSLog(@"输入框");
    completionHandler(@"http");
}
// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
}
// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"警告框%@",message);
    completionHandler();
}

- (void)getUrl:(NSDictionary *)argDict block:(WKScriptBlock)block
{
    NSLog(@"%@",argDict);
    NSDictionary * dict = [NSDictionary dictionaryWithObject:@"hello" forKey:@"world"];
    block(dict);
}

- (void)pay:(NSDictionary *)argDict block:(WKScriptBlock)block
{
    NSLog(@"%@",argDict);
    NSDictionary * dict = [NSDictionary dictionaryWithObject:@"hello" forKey:@"world"];
    block(dict);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
