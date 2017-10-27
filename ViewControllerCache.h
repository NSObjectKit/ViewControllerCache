//
//  ViewControllerCache.h
//  RAC
//
//  Created by Vanke on 2017/3/16.
//  Copyright © 2017年 Vanke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewControllerCacheDelegate <NSObject>

@optional

- (BOOL)confirmIdentify:(id)module;

+ (BOOL)shouldCached;

+ (NSUInteger)maxCountShouldCached;

@end





@interface ViewControllerCache : NSObject


+ (instancetype)cacheManager;


- (void)clearCache;


- (void)clearCacheWithClass:(Class)Class;


@end


