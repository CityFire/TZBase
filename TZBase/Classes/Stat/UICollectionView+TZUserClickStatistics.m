//
//  UICollectionView+TZUserClickStatistics.m
//  TZGame
//
//  Created by wjc on 2017/12/19.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import "UICollectionView+TZUserClickStatistics.h"
#import "TZHookUtil.h"
#import <objc/runtime.h>
#import <Aspects/Aspects.h>
#import "TZUserStatistics.h"
#import "AOPLoggerClickProtocol.h"
#import "TZStatisticInterceptionManager.h"

static const void *delegateCollectionViewIsHook = &delegateCollectionViewIsHook;

@implementation UICollectionView (TZUserClickStatistics)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(setDelegate:);
        SEL swizzledSelector = @selector(swiz_setDelegate:);
        [TZHookUtil tz_swizzlingInClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
    });
}

- (void)swiz_setDelegate:(id<UICollectionViewDelegate>)delegate {
    [self swiz_setDelegate:delegate];
    if (delegate && [delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        NSNumber *isHook = objc_getAssociatedObject(delegate, delegateCollectionViewIsHook);
        if (isHook == nil || ![isHook boolValue]) {
            @try {
                NSError *error = nil;
                [(NSObject *)delegate aspect_hookSelector:@selector(collectionView:didSelectItemAtIndexPath:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
                    
                    TZUserStatistics<AOPLoggerClickProtocol> *aopLoggerEngine=(TZUserStatistics<AOPLoggerClickProtocol>*)[TZStatisticInterceptionManager sharedStatLogger];
                    if ([aopLoggerEngine respondsToSelector:@selector(alcp_collectionView:didSelectItemAtIndexPath:from:)]) {
                        [aopLoggerEngine alcp_collectionView:aspectInfo.arguments[0] didSelectItemAtIndexPath:aspectInfo.arguments[1] from:aspectInfo.instance];
                    }
                    
                } error:&error];
                objc_setAssociatedObject(delegate, delegateCollectionViewIsHook, @(YES), OBJC_ASSOCIATION_RETAIN);
            }
            @catch (NSException *exception) {
            }
            
        }
    }
}

@end
