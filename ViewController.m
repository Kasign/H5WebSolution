//
//  ViewController.m
//  Unity-iPhone
//
//  Created by qiuShan on 2018/2/11.
//

#import "ViewController.h"
#import "WKScriptManager.h"

@interface ViewController ()<WKNavigationDelegate,WeakScriptMessageDelegate,WKUIDelegate>

@property (nonatomic, strong) WKWebView     *  wkWebView;
@property (nonatomic, copy)   WKScriptBlock    payBlock;//回调block

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self cleanCacheAndCookie];
    
    [self initloadWebView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [WKScriptManager destroy];
}

- (void)dealloc {
    
    [self cleanCacheAndCookie];

}

/**清除缓存和cookie*/
- (void)cleanCacheAndCookie {
    
    if ([UIDevice currentDevice].systemVersion.integerValue >= 9.0) {
        // 清除所有
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            NSLog(@"清除缓存完毕");
        }];
        return;
    }
    
    //清除cookies
    NSHTTPCookie * cookie;
    NSHTTPCookieStorage * storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

#pragma mark - init subview
- (void)initloadWebView {
    
    WKUserContentController * userContentController = [[WKUserContentController alloc] init];
    
    WKScriptManager * scriptManager = [[WKScriptManager alloc] initWithDelegate:self];
    scriptManager.jsKey = @"key"; //设置与h5协议的参数值，可根据需要改变
    scriptManager.jsMethod = @"callBack"; //设置与h5协议的参数值，可根据需要改变
    [userContentController addScriptMessageHandler:scriptManager name:scriptManager.iOSMethodName];
    
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    
    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 375, 667) configuration:configuration];
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    scriptManager.weakWebView = _wkWebView;
    [self.view addSubview:_wkWebView];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [_wkWebView loadRequest:request];
}

#pragma mark - delegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSString *hostString = [NSString stringWithFormat:@"%@",webView.URL.host];
    NSString *sender = [NSString stringWithFormat:@"%@", hostString];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:sender
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler
{
    NSString *hostString = [NSString stringWithFormat:@"%@",webView.URL.host];
    NSString *sender = [NSString stringWithFormat:@"%@", hostString];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt
                                                                             message:sender
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
                                                          completionHandler(input);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(alertController.textFields[0].text?:@"");
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    NSString *hostString = [NSString stringWithFormat:@"%@",webView.URL.host];
    NSString *sender = [NSString stringWithFormat:@"%@", hostString];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:sender
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(NO);
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 在此方法里区分方法
 dict:
 */
#pragma mark - delegate
- (void)differMethodWithKey:(NSString *)key jsDic:(NSDictionary *)jsDic finishBlock:(WKScriptFinishBlock)block{
    
    SEL selector = nil;
    NSMutableDictionary * nativeDic = [NSMutableDictionary dictionary];//native要执行方法的参数，执行的时候会把此字典传过去
    
    if ([key isEqualToString:@"exple"]) {
        selector = @selector(exple:block:);//方法必须带block
        [nativeDic setObject:@"123" forKey:@"goodId"];
    }
    jsDic = @{@"key":@"callPay",@"data":@{@"参数1":@"参数1"},@"callBack":@"finishBack"};//此处@"key"和@"callBack"是跟H5协议好的，让他们以这种方式传参数就好，@"key"和@"callBack"也可以根据协议的不同值在初始化时自行设置
    if ([key isEqualToString:@"callPay"]) {
        selector = @selector(callPay:block:);//方法必须带block
        [nativeDic setObject:@"123" forKey:@"goodId"];
    }
    block(selector,nativeDic);
}

#pragma mark - native method
//例1
- (void)exple:(NSDictionary *)argsDic block:(WKScriptBlock)block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary * dic = @{@"a1":@"10",@"a2":@"20"};//返回传给js的数据
        block(dic,YES);//传YES，会执行回调
    });
}

//例2
- (void)callPay:(NSDictionary *)argsDic block:(WKScriptBlock)block
{
    NSString *  goodId = @"com.66rpg.OrangeNewBox.six1";
    if (goodId) {
        [self orangePurchaseSuccessTransaction:nil andReceiptData:nil];
    } else {
        [self orangePurchaseFailedAndError:@"失败了"];
    }
    _payBlock = block;
}

//支付回调
- (void)orangePurchaseFailedAndError:(NSString *)error
{
    NSMutableDictionary * callBackDict = [NSMutableDictionary dictionary];
    if (error && [[error class] isKindOfClass:[NSString class]]) {
        if (error.length) {
            [callBackDict setObject:error forKey:@"message"];
        }
    }
    [callBackDict setObject:@"支付失败" forKey:@"status"];
    [callBackDict setObject:@NO forKey:@"is_success"];
    
    _payBlock(callBackDict,NO);//发起js回调,由于此时是NO，所以不会执行回调
}

//支付回调
- (void)orangePurchaseSuccessTransaction:(NSData *)transaction andReceiptData:(NSData *)receipt
{
    NSMutableDictionary * callBackDict = [NSMutableDictionary dictionary];
    [callBackDict setObject:@"成功" forKey:@"message"];
    [callBackDict setObject:@"支付成功" forKey:@"status"];
    [callBackDict setObject:@NO forKey:@"is_success"];
    
    _payBlock(callBackDict,YES);//发起js回调，此时是YES，会发起JS回调
}

@end
