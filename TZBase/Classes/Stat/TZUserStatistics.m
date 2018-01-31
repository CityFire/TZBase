//
//  TZUserStatistics.m
//  TZGame
//
//  Created by wjc on 2017/12/14.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import "TZUserStatistics.h"
//#import "BaiduMobStat.h"

@interface TZUserStatistics ()

@end

@implementation TZUserStatistics

+ (void)sendEventToServer:(NSString *)pageID {
    NSLog(@"pageID:%@", pageID);
}

+ (void)sendPageEnterToServer:(NSString *)pageName {
    NSLog(@"pageName:%@", pageName);
//    [[BaiduMobStat defaultStat] pageviewStartWithName:pageName];
}

+ (void)sendPageLeaveToServer:(NSString *)pageName {
    NSLog(@"pageName:%@", pageName);
//    [[BaiduMobStat defaultStat] pageviewEndWithName:pageName];
}

+ (void)sendControlEventToServer:(NSString *)eventID {
    NSLog(@"controlEventID:%@", eventID);
//    [[BaiduMobStat defaultStat] logEvent:eventID eventLabel:nil];
}

+ (void)sendControlEventToServer:(NSString *)eventID eventLabel:(NSString *)eventLabel {
    NSLog(@"controlEventID:%@", eventID);
//    [[BaiduMobStat defaultStat] logEvent:eventID eventLabel:eventLabel];
}

+ (void)sendControlEventToServer:(NSString *)eventID eventLabel:(NSString *)eventLabel eventAttribute:(NSDictionary *)eventAttribute {
    NSLog(@"controlEventID:%@", eventID);
//    [[BaiduMobStat defaultStat] logEvent:eventID eventLabel:eventLabel attributes:eventAttribute];
}

+ (void)sendControlEventStartToServer:(NSString *)eventID eventLabel:(NSString *)eventLabel {
    NSLog(@"controlEventID:%@", eventID);
//    [[BaiduMobStat defaultStat] eventStart:eventID eventLabel:eventLabel];
}

+ (void)sendControlEventEndToServer:(NSString *)eventID eventLabel:(NSString *)eventLabel {
    NSLog(@"controlEventID:%@", eventID);
//    [[BaiduMobStat defaultStat] eventEnd:eventID eventLabel:eventLabel];
}

@end
