//
//  TZRouteMediator.m
//  TZGame
//
//  Created by wjc on 2018/1/20.
//  Copyright © 2018年 wjc. All rights reserved.
//

#import "TZRouteMediator.h"
#import "TZRouteNavigator.h"

NSString * const kTZRouteViewControllerKey = @"TZRouteViewController";
NSString *__nonnull const kTZRouteModeKey = @"kTZRouteType";

// 全部保存各个模块的connector实例
static NSMutableDictionary<NSString *, id<TZRouteConnectorProtocol>> *g_connectorMap = nil;

@implementation TZRouteMediator


+ (void)registerConnector:(id<TZRouteConnectorProtocol>)connector {
    if (![connector conformsToProtocol:@protocol(TZRouteConnectorProtocol)]) {
        return;
    }
    
    @synchronized(g_connectorMap) {
        if (g_connectorMap == nil) {
            g_connectorMap = [[NSMutableDictionary alloc] initWithCapacity:5];
        }
        
        NSString *connectroClsStr = NSStringFromClass([connector class]);
        if ([g_connectorMap objectForKey:connectroClsStr] == nil) {
            [g_connectorMap setObject:connector forKey:connectroClsStr];
        }
    }
}

#pragma mark - 页面跳转接口

// 判断某个URL能否导航
+ (BOOL)canRouteURL:(nonnull NSURL *)URL {
    if (!g_connectorMap || g_connectorMap.count <= 0) {
        return NO;
    }
    
    __block BOOL success = NO;
    // 遍历connector
    [g_connectorMap enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull key, id<TZRouteConnectorProtocol>  _Nonnull connector, BOOL * _Nonnull stop) {
        if ([connector respondsToSelector:@selector(canOpenURL:)]) {
            if ([connector canOpenURL:URL]) {
                success = YES;
                *stop = YES;
            }
        }
    }];
    
    return success;
}

+ (BOOL)routeURL:(NSURL *)URL {
    return [self routeURL:URL withParameters:nil];
}

+ (BOOL)routeURL:(nonnull NSURL *)URL withParameters:(nullable NSDictionary *)params {
    if (!g_connectorMap || g_connectorMap.count <= 0) {
        return NO;
    }
    
    __block BOOL success = NO;
    __block int queryCount = 0;
    NSDictionary *userParams = [self parseParametersWithURL:URL andParameters:params];
    [g_connectorMap enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull key, id<TZRouteConnectorProtocol>  _Nonnull connector, BOOL * _Nonnull stop) {
        queryCount++;
        if ([connector respondsToSelector:@selector(connectToOpenURL:params:)]) {
            id returnObj = [connector connectToOpenURL:URL params:userParams];
            if (returnObj && [returnObj isKindOfClass:[UIViewController class]]) {
                if ([returnObj class] == [UIViewController class]) {
                    success = YES;
                } else {
                    [[TZRouteNavigator navigator] hookShowURLController:returnObj baseViewController:params[kTZRouteViewControllerKey] routeMode:params[kTZRouteModeKey]?[params[kTZRouteModeKey] intValue]:NavigationModePush];
                    success = YES;
                }
                
                *stop = YES;
            }
        }
    }];
    
    return success;
}

+ (nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL {
    return [self viewControllerForURL:URL withParameters:nil];
}

+ (nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL withParameters:(nullable NSDictionary *)params {
    if (!g_connectorMap || g_connectorMap.count <= 0) {
        return nil;
    }
    
    __block UIViewController *returnObj = nil;
    __block int queryCount = 0;
    NSDictionary *userParams = [self parseParametersWithURL:URL andParameters:params];
    [g_connectorMap enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull key, id<TZRouteConnectorProtocol>  _Nonnull connector, BOOL * _Nonnull stop) {
        queryCount++;
        if ([connector respondsToSelector:@selector(connectToOpenURL:params:)]) {
            returnObj = [connector connectToOpenURL:URL params:userParams];
            if (returnObj && [returnObj isKindOfClass:[UIViewController class]]) {
                *stop = YES;
            }
        }
    }];
    
    if (returnObj) {
        if ([returnObj class] == [UIViewController class]) {
            return nil;
        } else {
            return returnObj;
        }
    }
    return nil;
}



/**
 * 从url获取query参数放入到参数列表中
 */
+ (NSDictionary *)parseParametersWithURL:(nonnull NSURL *)URL andParameters:(nullable NSDictionary *)params {
    NSArray *pairs = [URL.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *userParams = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if (kv.count == 2) {
            NSString *key = [kv objectAtIndex:0];
            NSString *value = [self URLDecodedString:[kv objectAtIndex:1]];
            [userParams setObject:value forKey:key];
        }
    }
    [userParams addEntriesFromDictionary:params];
    return [NSDictionary dictionaryWithDictionary:userParams];
}

/**
 * 对url的value部分进行urlDecoding
 */
+ (nonnull NSString *)URLDecodedString:(nonnull NSString *)urlString {
    NSString *result = urlString;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
    result = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                   (__bridge CFStringRef)urlString,
                                                                                                   CFSTR(""),
                                                                                                   kCFStringEncodingUTF8);
#else
    result = [urlString stringByRemovingPercentEncoding];
#endif
    return result;
}

@end
