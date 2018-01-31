//
//  UIApplication+TZUserActionStatistics.m
//  TZGame
//
//  Created by wjc on 2017/12/14.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import "UIApplication+TZUserActionStatistics.h"
#import "TZHookUtil.h"
#import "TZUserStatistics.h"
#import "TZStatisticInterceptionManager.h"

@implementation UIApplication (TZUserActionStatistics)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(sendAction:to:from:forEvent:);
        SEL swizzledSelector = @selector(swiz_sendAction:to:from:forEvent:);
        [TZHookUtil tz_swizzlingInClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
    });
}

#pragma mark - Method Swizzling
- (void)swiz_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    // 插入埋点代码
    [self performUserStastisticsAction:action to:target from:sender forEvent:event];
    [self swiz_sendAction:action to:target from:sender forEvent:event];
}

- (void)performUserStastisticsAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    NSLog(@"\n***hook success.\n[1]action:%@\n[2]target:%@ \n[3]event:%ld", NSStringFromSelector(action), target, (long)event);
    if ([target respondsToSelector:action]) {
//        NSString *actionString = NSStringFromSelector(action);// 获取SEL string
        NSString *targetName = NSStringFromClass([target class]);// viewController name
        NSDictionary *configDict = [[TZStatisticInterceptionManager sharedStatLogger] dictionaryFromUserStatisticsConfigPlist];
        if (!configDict.allKeys.count) {
            return;
        }
        for (NSDictionary *event in configDict[targetName]) {
            NSString *eventID = event[@"EventId"];
            NSString *eventLabel = event[@"EventLabel"];
            NSDictionary *eventAttribute = event[@"EventAttribute"];
            NSString *attributeKey = eventAttribute.allKeys[0];
            NSString *attributeValue = eventAttribute[attributeKey];
            UIButton *btn = (UIButton *)sender;
            if (eventID.length && eventAttribute) {
                if ([attributeValue integerValue] == btn.tag) {
                    [TZUserStatistics sendControlEventToServer:eventID eventLabel:eventLabel eventAttribute:eventAttribute];
                    break;
                }
            }
            else {
                NSString *selectorName = event[@"EventSelectorName"];
                NSString *actionName = NSStringFromSelector(action);
                if ([selectorName isEqualToString:actionName]) {
                    [TZUserStatistics sendControlEventToServer:eventID eventLabel:eventLabel];
                    break;
                }
            }
        }
    }
}

@end
