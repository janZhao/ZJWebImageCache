//
//  ZJMemoryCacheManager.h
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol ZJImageCache <NSObject>

-(void)addImage:(UIImage *)image withIdentifier:(NSString *)identifier;
-(BOOL)removeImageWithIdentifier:(NSString *)identifier;
-(BOOL)removeAllImages;
-(UIImage *)imageWithIdentifier:(NSString *)identifier;

@end

//@protocol ZJImageRequestCache<ZJImageCache>
//
//- (void)addImage:(UIImage *)image forRequest:(NSURLRequest *)request withAdditionalIdentifier:(nullable NSString *)identifier;
//- (BOOL)removeImageforRequest:(NSURLRequest *)request withAdditionalIdentifier:(nullable NSString *)identifier;
//- (nullable UIImage *)imageforRequest:(NSURLRequest *)request withAdditionalIdentifier:(nullable NSString *)identifier;
//
//@end


@interface ZJMemoryCacheManager : NSObject<ZJImageCache>

/**
 The total memory capacity of the cache in bytes.
 */
@property (assign, nonatomic) UInt64 memoryCapacity;

@property (assign, nonatomic) UInt64 prferredMemoryUsageAfterPurge;

/** The current total Memory usage in bytes of all images stored with in the cache*/
@property (assign, nonatomic,readonly) UInt64 memoryUsage;

/** Initialies the `ZJImageCache` instance with default values for memory capacity and preferred memory usage after purge limit. `memoryCapcity` defaults to `100 MB`. `preferredMemoryUsageAfterPurge` defaults to `60 MB`. */
-(instancetype)init;
-(instancetype)initWithMemoryCapacity:(UInt64)memoryCapacity preferredMemoryCapacity:(UInt64)preferredMemoryCapacity;

// 1.简单的缓存方式
// 根据URL缓存去取图片
-(UIImage *)imageForKey:(NSString *)key;
// 设置URL缓存
-(void)setImageForKey:(UIImage *)image ForKey:(NSString *)key;

@end
