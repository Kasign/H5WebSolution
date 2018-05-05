//
//  WKScriptManager.h
//
//
//  Created by Fly on 2017/12/26.
//  Copyright © 2018年 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void(^WKScriptBlock)(NSDictionary * argsDic);          //native方法执行完成后，以字典形式返回给js数据<NSString,NSString>，success:为yes执行js回调，否则不执行

NS_ASSUME_NONNULL_BEGIN
/**
 针对WkWebView与js回调的代理方法，提供一套完整的回调协议，方便两端代码维护。
 js端每次只需调用：
             window.webkit.messageHandlers.iOSWKMethod.postMessage({
                                                               "key":"pay",
                                                               "data":{"a":arg},
                                                               "callBack":""
                                                               })
 方法即可，只在调用ios不同方法时改变"pay"即可。ios端只需实现 - (void)pay:(NSDictionary *)argDict block:(WKScriptBlock)block方法即可，在block中回调给js必要的参数，这一些都会自动执行。
 以上 key data callBack 都可以根据喜好更改。
 此封装还会避免多次点击H5调用方法引起的不必要问题。
 */
@interface WKScriptManager : NSObject<WKScriptMessageHandler>

/**
 与H5协议好的iOS注入到js的方法，供js传消息
 default: "iOSWKMethod"
 */
@property (nonatomic, copy, nullable) NSString   *  iOSMethodName;

/**
 与H5协议好的iOS注入到js的方法，取key值的对应的key
 defalut: "key"
 */
@property (nonatomic, copy, nullable) NSString   *  jsKey;

/**
 与H5协议好的iOS注入到js的方法，取js回调方法的key
 default: "callBack"
 */
@property (nonatomic, copy, nullable) NSString   *  jsMethod;

/**
 与H5协议好的iOS注入到js的方法，取js传递给ios参数的key，取出的一般应为NSDictionary
 default: "data"
 */
@property (nonatomic, copy, nullable) NSString   *  jsArgumentKey;

/**
 必传,否则会导致js回调失败
 */
@property (nonatomic, weak) WKWebView  *  weakWebView;

- (instancetype)initWithDelegate:(id)scriptDelegate;

/**
 移除所有未执行完的js方法，在willDisAppear中调用
 */
+ (void)destroy;

@end
NS_ASSUME_NONNULL_END
