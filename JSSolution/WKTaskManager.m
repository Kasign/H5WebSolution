//
//  WKTaskManager.m
//
//
//  Created by Fly on 2017/12/26.
//  Copyright © 2018年 Fly. All rights reserved.
//

#import "WKTaskManager.h"

@implementation WKTask

- (instancetype)initWithDelegate:(id<WKTaskDelegate>)delegate responseObject:(id<NSObject>)responder jsDict:(NSDictionary *)jsDict
{    
    self = [super init];
    if (self) {
        _relatedTasks = [NSMutableArray array];
        _nativeDict   = [NSDictionary dictionary];
        _delegate     = delegate;
        _responder    = responder;
        if (jsDict && [jsDict isKindOfClass:[NSDictionary class]]) {
            for (NSString * key in jsDict.allKeys) {
                if ([key isEqualToString:[WKTaskManager shareInstance].jsKey] && [jsDict objectForKey:key]) {
                    _key = [jsDict objectForKey:key];
                } else if ([key isEqualToString:[WKTaskManager shareInstance].jsMenthod] && [jsDict objectForKey:key]) {
                    _jsMethod = [jsDict objectForKey:key];
                }
            }
        }
    }
    return self;
}

- (void)setNativeMethod:(NSString *)nativeMethod nativeArgs:(NSDictionary *)nativeDic
{
    if (nativeMethod && [nativeMethod isKindOfClass:[NSString class]] && nativeMethod.length) {
        _nativeMethod = nativeMethod;
    }
    
    if (nativeDic && [nativeDic isKindOfClass:[NSDictionary class]] && [nativeDic.allValues count] > 0) {
        _nativeDict = [NSDictionary dictionaryWithDictionary:nativeDic];
    }
}

- (BOOL)isRelatedToTask:(WKTask *)object
{
    if ([self.key isEqualToString:object.key] && [self.nativeMethod isEqualToString:object.nativeMethod]) {
        return YES;
    }
    return NO;
}

- (void)performNativeMethod
{
    __block __typeof(self) weakSelf = self;
    self.block = ^(NSDictionary *argsDic) {
        [[WKTaskManager shareInstance] delTask:weakSelf];
        NSString * args = [WKTask converDicToJsonStr:argsDic];
        [weakSelf performJSCallBackWithArgs:args];
        for (WKTask * relatedTask in weakSelf.relatedTasks) {
            [relatedTask performJSCallBackWithArgs:args];
        }
        [weakSelf.relatedTasks removeAllObjects];
    };
    
    if (_responder && self.nativeMethod && self.nativeMethod.length) {
        if ([_responder respondsToSelector:NSSelectorFromString(self.nativeMethod)]) {
            NSMethodSignature * signature = [[_responder class] instanceMethodSignatureForSelector:NSSelectorFromString(_nativeMethod)];
            NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:_responder];
            [invocation setSelector:NSSelectorFromString(_nativeMethod)];
            [invocation setArgument:&_nativeDict atIndex:2];
            [invocation setArgument:&_block atIndex:3];
            [invocation invoke];
        }
    }
}

- (void)performJSCallBackWithArgs:(NSString *)args
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(wkTask:performJSCallBack:)]) {
        [self.delegate wkTask:self performJSCallBack:args];
    }
}

+ (NSString *)converDicToJsonStr:(NSDictionary *)dict
{
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSError * error;
        NSData  * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        if (!jsonData) {
            return @"{}";
        } else {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else {
        return @"{}";
    }
}

@end

@interface WKTaskManager()

@property (nonatomic, strong) NSMutableArray  *  performTasks;

@end

@implementation WKTaskManager

+ (instancetype)shareInstance
{
    static WKTaskManager * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[WKTaskManager alloc] init];
    });
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _performTasks = [NSMutableArray array];
    }
    return self;
}

- (void)startEventWithSEL:(SEL)selector
                 delegate:(id<WKTaskDelegate>)delegate
           responseObject:(id<NSObject>)responder
                nativeDic:(NSDictionary *)nativeDic
                    jsDic:(NSDictionary *)jsDic
{
    WKTask * task = [[WKTask alloc] initWithDelegate:delegate responseObject:responder jsDict:jsDic];
    [task setNativeMethod:NSStringFromSelector(selector) nativeArgs:nativeDic];
    [self addTask:task];
}

- (void)addTask:(WKTask *)task
{
    WKTask * performTask = nil;
    for (WKTask * subTask in _performTasks) {
        if ([task isRelatedToTask:subTask]) {
            performTask = subTask;
            break;
        }
    }
    
    if (performTask) {
        [performTask.relatedTasks addObject:task];
    } else {
        [_performTasks addObject:task];
        [task performNativeMethod];
    }
}

- (void)delTask:(WKTask *)task
{
    if ([self.performTasks containsObject:task]) {
        [self.performTasks removeObject:task];
    }
}

- (void)removeAllTask
{
    if (self.performTasks) {
        for (WKTask * subTask in self.performTasks) {
            [subTask.relatedTasks removeAllObjects];
        }
        [self.performTasks removeAllObjects];
    }
}

- (void)destroy
{
    [self removeAllTask];
}

@end
