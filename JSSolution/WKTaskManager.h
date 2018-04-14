//
//  WKTaskManager.h
//
//
//  Created by Fly on 2017/12/26.
//  Copyright © 2018年 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WKTaskBlock)(NSDictionary * argsDic); 

@class WKTask;

@protocol WKTaskDelegate <NSObject>

- (void)wkTask:(WKTask *)task performJSCallBack:(NSString *)args;

@end

@interface WKTask : NSObject

@property (nonatomic, strong) NSDictionary      *  nativeDict;                   //native要执行方法的参数
@property (nonatomic, strong) NSMutableArray    *  relatedTasks;                 //与当前task执行相同方法，不再重复执
@property (nonatomic, copy)   NSString          *  key;                          //key值，区分不同方法
@property (nonatomic, copy)   NSString          *  nativeMethod;                 //native要执行的方法
@property (nonatomic, copy)   NSString          *  jsMethod;                     //要执行的js方法
@property (nonatomic, copy)   WKTaskBlock          block;                        //native方法执行后的回调，成功才执行js回调
@property (nonatomic, weak)   id<WKTaskDelegate>   delegate;
@property (nonatomic, weak)   id<NSObject>         responder;                    //执行native方法的实例对象

- (instancetype)initWithDelegate:(id<WKTaskDelegate>)delegate
                  responseObject:(id<NSObject>)responder
                          jsDict:(NSDictionary *)jsDict;

- (void)setNativeMethod:(NSString *)nativeMethod nativeArgs:(NSDictionary *)nativeDic;

- (BOOL)isRelatedToTask:(WKTask *)object;

- (void)performNativeMethod;

- (void)performJSCallBackWithArgs:(NSString *)args;

@end

@interface WKTaskManager : NSObject

@property (nonatomic, copy) NSString  *  jsKey;
@property (nonatomic, copy) NSString  *  jsMenthod;

+ (instancetype)shareInstance;

- (void)startEventWithSEL:(SEL)selector
                 delegate:(id<WKTaskDelegate>)delegate
           responseObject:(id<NSObject>)responder
                nativeDic:(NSDictionary *)nativeDic
                    jsDic:(NSDictionary *)jsDic;

- (void)addTask:(WKTask *)task;

- (void)delTask:(WKTask *)task;

- (void)removeAllTask;

- (void)destroy;

@end
