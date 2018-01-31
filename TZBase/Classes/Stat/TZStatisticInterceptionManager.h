//
//  TZStatisticInterceptionManager.h
//  TZGame
//
//  Created by wjc on 2017/12/20.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TZStatisticInterceptionManager : NSObject

+ (TZStatisticInterceptionManager *)sharedStatLogger;

- (NSDictionary *)dictionaryFromUserStatisticsConfigPlist;

@end
