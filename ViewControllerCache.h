

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


