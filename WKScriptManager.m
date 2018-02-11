//
//  WKScriptManager.m
//
//
//  Created by fly on 2017/12/26.
//

#import "WKScriptManager.h"
#import "WKTaskManager.h"

@interface WKScriptManager ()<WKTaskDelegate>

@property (nonatomic, weak) id<WeakScriptMessageDelegate> scriptDelegate;

@end

@implementation WKScriptManager

- (instancetype)initWithDelegate:(id<WeakScriptMessageDelegate>)scriptDelegate
{
    self = [super init];
    if (self) {
        self.scriptDelegate = scriptDelegate;
        self.iOSMethodName  = @"iOSWKMethod";
        self.jsKey          = @"key";
        self.jsMethod       = @"callBack";
    }
    return self;
}

- (void)setJsKey:(NSString *)jsKey
{
    _jsKey = jsKey;
    [WKTaskManager shareInstance].jsKey = jsKey;
}

- (void)setJsMethod:(NSString *)jsMethod
{
    _jsMethod = jsMethod;
    [WKTaskManager shareInstance].jsMenthod = jsMethod;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:_iOSMethodName]) {
        if (message.body && [message.body isKindOfClass:[NSDictionary class]]) {
            NSDictionary * jsDic = message.body;
            NSString * key       = [jsDic objectForKey:self.jsKey];
            if (key && [key isKindOfClass:[NSString class]] && key.length) {
                [self differMethodWithKey:key jsDic:jsDic];
            }
        }
    }
}

- (void)differMethodWithKey:(NSString *)key jsDic:(NSDictionary *)jsDic
{
    if ([self.scriptDelegate respondsToSelector:@selector(differMethodWithKey:jsDic:finishBlock:)]) {
        [self.scriptDelegate differMethodWithKey:key jsDic:jsDic finishBlock:^(SEL selector, NSDictionary *nativeDic) {
            [[WKTaskManager shareInstance] startEventWithSEL:selector delegate:self responseObject:_scriptDelegate nativeDic:nativeDic jsDic:jsDic];
        }];
    }
}

- (void)wkTask:(WKTask *)task performJSCallBack:(NSString *)args
{
    if (task && task.jsMethod && [task.jsMethod isKindOfClass:[NSString class]] && task.jsMethod.length) {
        NSString * jsMethod = task.jsMethod;
        if (jsMethod && jsMethod.length) {
            if (!args || ![[args  class] isKindOfClass:[NSString class]]) {
                args = @"";
            }
            NSString * jsCallBack = [NSString stringWithFormat:@"%@(%@)",jsMethod,args];
            if (_weakWebView) {
                [_weakWebView evaluateJavaScript:jsCallBack completionHandler:nil];
            }
        }
    }
}

+ (void)destroy
{
    [[WKTaskManager shareInstance] destroy];
}

@end
