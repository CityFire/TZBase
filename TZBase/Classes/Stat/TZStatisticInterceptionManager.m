//
//  TZStatisticInterceptionManager.m
//  TZGame
//
//  Created by wjc on 2017/12/20.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import "TZStatisticInterceptionManager.h"
#import "AOPLoggerClickProtocol.h"
#import "TZUserStatistics.h"
#import "Aspects.h"

#define TZLoggingPageImpression @"TZLoggingPageImpression"
#define TZLoggingEventIDs @"TZLoggingEventIDs"
#define TZLoggingEventName @"TZLoggingEventName"
#define TZLoggingEventAttribute @"TZLoggingEventAttribute"
#define TZLoggingEventSelectorName @"EventSelectorName"
#define TZLoggingEventId @"EventId"
#define TZLoggingEventLabel @"EventLabel"
#define TZLoggingEventHandlerBlock @"EventHandlerBlock"

@interface TZStatisticInterceptionManager ()<AOPLoggerClickProtocol>

@end

@implementation TZStatisticInterceptionManager

+ (TZStatisticInterceptionManager *)sharedStatLogger {
    static TZStatisticInterceptionManager *sharedStatLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStatLogger = [[self alloc] init];
    });
    return sharedStatLogger;
}

#pragma mark -

- (NSDictionary *)dictionaryFromUserStatisticsConfigPlist {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TZGlobalUserStatisticsConfig" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return dict;
}

- (void)setupLogging {
    NSDictionary *config = @{
                             @"TZGameHomeViewController": @{
                                     TZLoggingPageImpression: @"page - home page",
                                     TZLoggingEventIDs: @[
                                             @{
                                                 TZLoggingEventName: @"button one clicked",
                                                 TZLoggingEventSelectorName: @"buttonOneClicked:",
                                                 TZLoggingEventHandlerBlock: ^(id<AspectInfo> aspectInfo) {
                                                     NSLog(@"button one clicked");
                                                 },
                                                 },
                                             @{
                                                 TZLoggingEventName: @"button two clicked",
                                                 TZLoggingEventSelectorName: @"buttonTwoClicked:",
                                                 TZLoggingEventHandlerBlock: ^(id<AspectInfo> aspectInfo) {
                                                     NSLog(@"button two clicked");
                                                 },
                                                 },
                                             ],
                                     },
                             
                             @"TZGameDetailViewController": @{
                                     TZLoggingPageImpression: @"page imp - game detail page",
                                     }
                             };
    
    [self setupWithConfiguration:config];
}

typedef void (^AspectHandlerBlock)(id<AspectInfo> aspectInfo);

- (void)setupWithConfiguration:(NSDictionary *)configs {
    // Hook Page Impression
    [UIViewController aspect_hookSelector:@selector(viewDidAppear:)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo) {
                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                       NSString *className = NSStringFromClass([[aspectInfo instance] class]);
                                       NSString *pageImp = configs[className][TZLoggingPageImpression];
                                       if (pageImp) {
                                           NSLog(@"%@", pageImp);
                                       }
                                   });
                               } error:NULL];
    
    // Hook Events
    for (NSString *className in configs) {
        Class clazz = NSClassFromString(className);
        NSDictionary *config = configs[className];
        
        if (config[TZLoggingEventIDs]) {
            for (NSDictionary *event in config[TZLoggingEventIDs]) {
                SEL selekor = NSSelectorFromString(event[TZLoggingEventSelectorName]);
                AspectHandlerBlock block = event[TZLoggingEventHandlerBlock];
                
                [clazz aspect_hookSelector:selekor
                               withOptions:AspectPositionAfter
                                usingBlock:^(id<AspectInfo> aspectInfo) {
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        block(aspectInfo);
                                    });
                                } error:NULL];
                
            }
        }
    }
}

#pragma mark - AOPLoggerClickProtocol

- (void)alcp_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath from:(id)sender {
    NSLog(@"tableView:%@, indexPath:%@, sender:%@", tableView, indexPath, sender);
    if ([sender isKindOfClass:NSClassFromString(@"TZMineViewController")]) {
        NSDictionary *configDict = [[TZStatisticInterceptionManager sharedStatLogger] dictionaryFromUserStatisticsConfigPlist];
        if (!configDict.allKeys.count) {
            return;
        }
        for (NSDictionary *event in configDict[@"TZMineViewController"]) {
            NSString *eventID = event[@"EventId"];
            NSString *eventLabel = event[@"EventLabel"];
            NSDictionary *eventAttribute = event[@"EventAttribute"];
            NSString *attributeKey = eventAttribute.allKeys[0];
            NSString *attributeValue = eventAttribute[attributeKey];
            if ([attributeValue integerValue] == 100 + indexPath.row) {
                [TZUserStatistics sendControlEventToServer:eventID eventLabel:eventLabel eventAttribute:eventAttribute];
                break;
            }
        }
    }
}

- (void)alcp_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath from:(id)sender {
    NSLog(@"collectionView:%@, indexPath:%@, sender:%@", collectionView, indexPath, sender);
    if ([sender isKindOfClass:NSClassFromString(@"TZHomeCategoryCell")]) {
        NSDictionary *configDict = [[TZStatisticInterceptionManager sharedStatLogger] dictionaryFromUserStatisticsConfigPlist];
        if (!configDict.allKeys.count) {
            return;
        }
        for (NSDictionary *event in configDict[@"TZHomeCategoryCell"]) {
            NSString *eventID = event[@"EventId"];
            NSString *eventLabel = event[@"EventLabel"];
            [TZUserStatistics sendControlEventToServer:eventID eventLabel:eventLabel];
            break;
        }
    }
    else if ([sender isKindOfClass:NSClassFromString(@"SDCycleScrollView")]) {
        NSDictionary *configDict = [[TZStatisticInterceptionManager sharedStatLogger] dictionaryFromUserStatisticsConfigPlist];
        if (!configDict.allKeys.count) {
            return;
        }
        for (NSDictionary *event in configDict[@"SDCycleScrollView"]) {
            NSString *eventID = event[@"EventId"];
            NSString *eventLabel = event[@"EventLabel"];
            [TZUserStatistics sendControlEventToServer:eventID eventLabel:eventLabel];
            break;
        }
    }
}

@end
