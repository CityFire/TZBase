//
//  TZRouteMediator.h
//  TZGame
//
//  Created by wjc on 2018/1/20.
//  Copyright © 2018年 wjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TZRouteConnectorProtocol.h"

@interface TZRouteMediator : NSObject

+ (void)registerConnector:(nonnull id<TZRouteConnectorProtocol>)connector;

#pragma mark - 页面跳转接口

// 判断某个URL能否导航
+ (BOOL)canRouteURL:(nonnull NSURL *)URL;

// 通过URL直接完成页面跳转
+ (BOOL)routeURL:(nonnull NSURL *)URL;
+ (BOOL)routeURL:(nonnull NSURL *)URL withParameters:(nullable NSDictionary *)params;

// 通过URL获取viewController实例
+ (nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL;
+ (nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL withParameters:(nullable NSDictionary *)params;

@end
