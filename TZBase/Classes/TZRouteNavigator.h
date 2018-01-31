//
//  TZRouteNavigator.h
//  TZGame
//
//  Created by wjc on 2018/1/20.
//  Copyright © 2018年 wjc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NavigationMode) {
    NavigationModeNone = 0,
    NavigationModePush, // push a viewController in NavigationController
    NavigationModePresent, // present a viewController in NavigationController
    NavigationModeShare    // pop to the viewController already in NavigationController or tabBarController
};

@interface TZRouteNavigator : NSObject

/**
 * 一个应用一个统一的navigator
 */
+ (nonnull TZRouteNavigator *)navigator;

/**
 * 设置通用的拦截跳转方式；
 */
- (void)setHookRouteBlock:(BOOL (^__nullable)(UIViewController *__nonnull controller, UIViewController *__nullable baseViewController, NavigationMode routeMode))routeBlock;

/**
 * 在BaseViewController下展示URL对应的Controller
 *  @param controller   当前需要present的Controller
 *  @param baseViewController 展示的BaseViewController
 *  @param routeMode  展示的方式
 */
- (void)showURLController:(nonnull UIViewController *)controller
      baseViewController:(nullable UIViewController *)baseViewController
               routeMode:(NavigationMode)routeMode;

@end

/**
 * 外部不能调用该类别中的方法，仅供RouteMediator中调用
 */
@interface TZRouteNavigator (HookRouteBlock)

- (void)hookShowURLController:(nonnull UIViewController *)controller
          baseViewController:(nullable UIViewController *)baseViewController
                   routeMode:(NavigationMode)routeMode;

@end
