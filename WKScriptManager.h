//
//  WKScriptManager.h
//
//
//  Created by fly on 2017/12/26.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void(^WKScriptBlock)(NSDictionary * argsDic, BOOL success);          //native方法执行完成后，以字典形式返回给js数据<NSString,NSString>，success:为yes执行js回调，否则不执行
typedef void(^WKScriptFinishBlock)(SEL selector,NSDictionary * nativeDic);   //回调要执行的nativeMethod，native方法需要的参数

@protocol WeakScriptMessageDelegate <NSObject>

- (void)differMethodWithKey:(NSString *)key jsDic:(NSDictionary *)jsDic finishBlock:(WKScriptFinishBlock)block;

@end

@interface WKScriptManager : NSObject<WKScriptMessageHandler>

@property (nonatomic, copy) NSString   *  iOSMethodName;        //与H5协议好的iOS注入到js的方法，供js传消息
@property (nonatomic, copy) NSString   *  jsKey;                //与H5协议好的iOS注入到js的方法，取key值的对应的key
@property (nonatomic, copy) NSString   *  jsMethod;             //与H5协议好的iOS注入到js的方法，取js回调方法的key
@property (nonatomic, weak) WKWebView  *  weakWebView;

- (instancetype)initWithDelegate:(id<WeakScriptMessageDelegate>)scriptDelegate;

/**
 移除所有未执行完的js方法
 */
+ (void)destroy;

@end
