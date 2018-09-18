//
//  ZJCacheManager.m
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import "ZJCacheManager.h"
#import "ZJDiskCacheManager.h"
#import "ZJMemoryCacheManager.h"


@interface ZJCacheManager()

@property (strong, nonatomic) ZJDiskCacheManager *diskCache;

@property (strong, nonatomic) ZJMemoryCacheManager *memoryCache;

@end

@implementation ZJCacheManager

-(instancetype)init{
    if (self = [super init]) {
        self.diskCache = [[ZJDiskCacheManager alloc]init];
        self.memoryCache = [[ZJMemoryCacheManager alloc]init];
    }
    
    return self;
}

-(void)imageForKey:(NSString *)key findImageBlock:(void (^)(UIImage *))findIimageBlock{
    
    // 1.先从内存缓存中查找
    UIImage *image = [self.memoryCache imageForKey:key];
    if (image) {
        findIimageBlock(image);
        return;
    }
    
    // 2.从沙盒中查找
    [self.diskCache imageForKey:key completionBlock:^(UIImage *image) {
        findIimageBlock(image);
        
        //把当前图片存放到内存缓存中去
        if (image) {
            [self.memoryCache setImageForKey:image ForKey:key];
        }
    }];
    
}

// 保存文件到内存和磁盘
-(void)saveImage:(UIImage *)image urlString:(NSString *)urlString{
    [self.memoryCache setImageForKey:image ForKey:urlString];
    [self.diskCache saveImage:image urlString:urlString];
}



@end
