//
//  UIViewController+TZUserPageStatistics.m
//  TZGame
//
//  Created by wjc on 2017/12/14.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import "UIViewController+TZUserPageStatistics.h"
#import "TZHookUtil.h"
#import "TZUserStatistics.h"
#import "TZStatisticInterceptionManager.h"

@implementation UIViewController (TZUserPageStatistics)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(viewDidAppear:);
        SEL swizzledSelector = @selector(swiz_viewDidAppear:);
        [TZHookUtil tz_swizzlingInClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
        
        SEL originalSelector2 = @selector(viewDidDisappear:);
        SEL swizzledSelector2 = @selector(swiz_viewDidDisappear:);
        [TZHookUtil tz_swizzlingInClass:[self class] originalSelector:originalSelector2 swizzledSelector:swizzledSelector2];
    });
}

- (BOOL)swiz_viewIgnore {
    NSString *screenName = NSStringFromClass([self class]);
    if ([screenName isEqualToString:@"SFBrowserRemoteViewController"] ||
        [screenName isEqualToString:@"UIRemoteInputViewController"] ||
        [screenName isEqualToString:@"SFSafariViewController"] ||
        [screenName isEqualToString:@"UIAlertController"] ||
        [screenName isEqualToString:@"UIInputWindowController"] ||
        [screenName isEqualToString:@"UINavigationController"] ||
        [screenName isEqualToString:@"IPNPluginViewController"] ||
        [screenName isEqualToString:@"UIKeyboardCandidateGridCollectionViewController"] ||
        [screenName isEqualToString:@"UICompatibilityInputViewController"] ||
        [screenName isEqualToString:@"UIApplicationRotationFollowingController"] ||
        [screenName isEqualToString:@"UIApplicationRotationFollowingControllerNoTouches"] ||
        [screenName isEqualToString:@"UIViewController"] || [screenName isEqualToString:@"UISystemKeyboardDockController"] || [screenName isEqualToString:@"UIKeyboardCandidateRowViewController"] || [screenName isEqualToString:@"_UIRemoteInputViewController"] || [screenName isEqualToString:@"UIKeyboardHiddenViewController"]
        ) {
        return YES;
    }
    if ([self isKindOfClass:NSClassFromString(@"UINavigationController")] ||
        [self isKindOfClass:NSClassFromString(@"UITabBarController")] || [self isKindOfClass:NSClassFromString(@"TZSkeletonTableViewController")] || [self isKindOfClass:NSClassFromString(@"UIAlertController")] || [self isKindOfClass:NSClassFromString(@"UIRemoteInputViewController")]) {
        return YES;
    }
    return NO;
}

#pragma mark - Method Swizzling
- (void)swiz_viewDidAppear:(BOOL)animated {
    if ([self swiz_viewIgnore]) {
        return;
    }
    [self inject_viewDidApper];
    [self swiz_viewDidAppear:animated];
}

- (void)swiz_viewDidDisappear:(BOOL)animated {
    if ([self swiz_viewIgnore]) {
        return;
    }
    [self inject_viewDidDisappear];
    [self swiz_viewDidDisappear:animated];
}

// 利用hook 统计所有页面的停留时长
- (void)inject_viewDidApper {
//    NSString *pageID = [self pageEventID:YES];
//    if (pageID) {
//        [TZUserStatistics sendEventToServer:pageID];
//    }
    NSString *selfClassName = NSStringFromClass([self class]);
    [TZUserStatistics sendPageEnterToServer:selfClassName];
}

- (void)inject_viewDidDisappear {
//    NSString *pageID = [self pageEventID:NO];
//    if (pageID) {
//        [TZUserStatistics sendEventToServer:pageID];
//    }
    NSString *selfClassName = NSStringFromClass([self class]);
    [TZUserStatistics sendPageLeaveToServer:selfClassName];
}

- (NSString *)pageEventID:(BOOL)bEnterPage {
    NSDictionary *configDict = [[TZStatisticInterceptionManager sharedStatLogger] dictionaryFromUserStatisticsConfigPlist];
    if (!configDict.allKeys.count) {
        return nil;
    }
    NSString *selfClassName = NSStringFromClass([self class]);
//    NSString *pageEventID = nil;
//    if ([selfClassName isEqualToString:@"TZGameHomeViewController"]) {
//        pageEventID = bEnterPage ? @"EVENT_HOME_ENTER_PAGE" : @"EVENT_HOME_LEAVE_PAGE";
//    } else if ([selfClassName isEqualToString:@"TZGameDetailViewController"]) {
//        pageEventID = bEnterPage ? @"EVENT_DETAIL_ENTER_PAGE" : @"EVENT_DETAIL_LEAVE_PAGE";
//    }
    return configDict[selfClassName][@"PageEventIDs"][bEnterPage ? @"Enter" : @"Leave"];
}


@end
