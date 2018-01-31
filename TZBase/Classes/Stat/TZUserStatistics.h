//
//  TZUserStatistics.h
//  TZGame
//
//  Created by wjc on 2017/12/14.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TZUserStatistics : NSObject

+ (void)sendEventToServer:(NSString *)pageID;

+ (void)sendPageEnterToServer:(NSString *)pageName;

+ (void)sendPageLeaveToServer:(NSString *)pageName;

+ (void)sendControlEventToServer:(NSString *)eventID;

+ (void)sendControlEventToServer:(NSString *)eventID eventLabel:(NSString *)eventLabel;

+ (void)sendControlEventToServer:(NSString *)eventID eventLabel:(NSString *)eventLabel eventAttribute:(NSDictionary *)eventAttribute;

+ (void)sendControlEventStartToServer:(NSString *)eventID eventLabel:(NSString *)eventLabel;

+ (void)sendControlEventEndToServer:(NSString *)eventID eventLabel:(NSString *)eventLabel;

@end
