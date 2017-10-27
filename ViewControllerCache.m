//
//  ViewControllerCache.m
//  RAC
//
//  Created by Vanke on 2017/3/16.
//  Copyright © 2017年 Vanke. All rights reserved.
//

#import "ViewControllerCache.h"
#import <objc/runtime.h>

@interface ViewControllerCache ()

@property (nonatomic, strong) NSMutableDictionary *viewControllers;

- (UIViewController *)loadViewControllerWithInstance:(UIViewController *)instance;

@end


@implementation ViewControllerCache


+ (instancetype)cacheManager {
    
    static id cacheManager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        cacheManager = [[self alloc] init];
        
    });
    
    return cacheManager;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        _viewControllers = [NSMutableDictionary dictionary];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearCache)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
    }
    
    return self;
}



- (UIViewController *)loadViewControllerWithInstance:(UIViewController *)instance  {
    
    Class class = [instance class];

    
    if ([class conformsToProtocol:@protocol(ViewControllerCacheDelegate)]) {
        
        if ([class respondsToSelector:@selector(shouldCached)]) {
            
            if (![(id <ViewControllerCacheDelegate>)class shouldCached]) {
                
                return instance;
            }
        }
        
    } else {
        
        return instance;
    }
    
    NSArray *array = [_viewControllers objectForKey:NSStringFromClass(class)];
    
    for (UIViewController *viewController in array) {
        
        if ([instance respondsToSelector:@selector(confirmIdentify:)]) {
            
            if ([(id <ViewControllerCacheDelegate>)instance confirmIdentify:viewController]) {
                
                return viewController;
            }
            
        } else {
            
            return viewController;
        }
        
    }
    
    return instance;
    
}


- (void)cachedViewController:(UIViewController *)vc {
    
    Class class = [vc class];
    
    if ([class conformsToProtocol:@protocol(ViewControllerCacheDelegate)]) {
        
        if ([class respondsToSelector:@selector(shouldCached)]) {
            
            if (![(id <ViewControllerCacheDelegate>)class shouldCached]) {
                
                return;
            }
        }
        
        NSMutableArray *array = [_viewControllers objectForKey:NSStringFromClass(class)];
        
        if (!array) {
            
            array = [NSMutableArray array];
            [_viewControllers setObject:array forKey:NSStringFromClass(class)];
            
        }
        
        if (![array containsObject:vc]) {
            NSUInteger maxCount = 5;
            if ([class respondsToSelector:@selector(maxCountShouldCached)]) {
                maxCount = [class respondsToSelector:@selector(maxCountShouldCached)];
            }
            if (array.count >= maxCount) {
                
                [array removeObjectAtIndex:0];
                
            }
            
            [array addObject:vc];
            
        }
    }
    
    
}

- (void)clearCacheWithClass:(Class)Class {
    
    [_viewControllers removeObjectForKey:NSStringFromClass(Class)];
}

- (void)clearCache {
    
    [_viewControllers removeAllObjects];
    
}

@end







@interface UINavigationController (Cache)

@end

@implementation UINavigationController (Cache)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL selectors[] = {
            
            @selector(popViewControllerAnimated:),
            @selector(pushViewController:animated:),
            @selector(showViewController:sender:),
            
        };
        
        for (int i = 0; i < sizeof(selectors) / sizeof(SEL); i ++) {
            
            SEL originalSelector = selectors[i];
            SEL swizzledSelector = NSSelectorFromString([@"dzl_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);
            
        }
    });
    
}


- (void)dzl_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    UIViewController *vc = [[ViewControllerCache cacheManager] loadViewControllerWithInstance:viewController];
    
    [self dzl_pushViewController:vc animated:animated];
}

- (UIViewController *)dzl_popViewControllerAnimated:(BOOL)animated {
    
    UIViewController *vc = [self dzl_popViewControllerAnimated:animated];

    [[ViewControllerCache cacheManager] cachedViewController:vc];
    
    return vc;
}

- (void)dzl_showViewController:(UIViewController *)vc sender:(id)sender {
    
    UIViewController *viewController = [[ViewControllerCache cacheManager] loadViewControllerWithInstance:vc];
    
    [self dzl_showViewController:viewController sender:sender];
    
}


@end

