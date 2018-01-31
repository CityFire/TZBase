//
//  UITableView+TZUserClickStatistics.m
//  TZGame
//
//  Created by wjc on 2017/12/19.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import "UITableView+TZUserClickStatistics.h"
#import "TZHookUtil.h"
#import <objc/runtime.h>
#import <Aspects/Aspects.h>
#import "TZStatisticInterceptionManager.h"
#import "AOPLoggerClickProtocol.h"

static const void *delegateTableViewIsHook = &delegateTableViewIsHook;

@implementation UITableView (TZUserClickStatistics)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(setDelegate:);
        SEL swizzledSelector = @selector(swiz_setDelegate:);
        [TZHookUtil tz_swizzlingInClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
    });
}

- (void)swiz_setDelegate:(id<UITableViewDelegate>)delegate {
    [self swiz_setDelegate:delegate];
    if (delegate && [delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        NSNumber *isHook = objc_getAssociatedObject(delegate, delegateTableViewIsHook);
        if (isHook == nil || ![isHook boolValue]) {
            @try {
                NSError *error = nil;
                [(NSObject *)delegate aspect_hookSelector:@selector(tableView:didSelectRowAtIndexPath:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
                    TZStatisticInterceptionManager<AOPLoggerClickProtocol> *aopLoggerEngine = (TZStatisticInterceptionManager<AOPLoggerClickProtocol> *)[TZStatisticInterceptionManager sharedStatLogger];
                    if ([aopLoggerEngine respondsToSelector:@selector(alcp_tableView:didSelectRowAtIndexPath:from:)]) {
                        [aopLoggerEngine alcp_tableView:aspectInfo.arguments[0] didSelectRowAtIndexPath:aspectInfo.arguments[1] from:aspectInfo.instance];
                    }
                    
                } error:&error];
                objc_setAssociatedObject(delegate, delegateTableViewIsHook, @(YES), OBJC_ASSOCIATION_RETAIN);
            }
            @catch (NSException *exception) {
            }
            
        }
    }
}

@end
