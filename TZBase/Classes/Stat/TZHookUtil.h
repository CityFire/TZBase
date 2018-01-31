//
//  TZHookUtil.h
//  TZGame
//
//  Created by wjc on 2017/12/14.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TZHookUtil : NSObject

+ (void)tz_swizzlingInClass:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end
