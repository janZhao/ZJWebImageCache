//
//  ZJDownLoadManager.m
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import "ZJDownLoadManager.h"

#define KMaxConcurrentOperationCount 5

@interface ZJDownLoadManager()

// 缓存管理器
@property (strong, nonatomic) ZJCacheManager *cacheManager;

// 下载任务队列管理
@property (strong, nonatomic) NSOperationQueue *queue;

// 网络下载器
@property (strong, nonatomic) NSURLSession *session;

// 当前正在下载任务的队列
@property (strong, nonatomic) NSMutableArray<ZJImageDownLoadOperation *> *downloadingOperations;

@end

@implementation ZJDownLoadManager

+(instancetype)sharedManager{
    static ZJDownLoadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZJDownLoadManager alloc]init];
        instance.cacheManager = [[ZJCacheManager alloc]init];//缓存管理
        instance.queue = [[NSOperationQueue alloc]init];// 下载任务队列
        instance.session = [NSURLSession sharedSession];// 下载管理器
        instance.downloadingOperations = [NSMutableArray array]; //当前正在下载的任务
    });
    
    return  instance;
}

-(void)downLoadImageWithURLString:(NSString *)url completionBlock:(CompletionBlockHandler)completionBlock
{
    NSAssert(url && completionBlock, @"参数错误");
    // 1.检查当前任务是否正在下载中
    BOOL isDownloading = [self isDownloadingWithURLString:url];
    if (isDownloading) {
        NSLog(@"图片正在下载中...不要重复下载");
        return;
    }
    
    //2.根据urlString去缓存中查找
    [self.cacheManager imageForKey:url findImageBlock:^(UIImage *image) {
        if (image) {
            NSLog(@"图片来自于缓存");
            completionBlock(image,nil);
            return;
        }
    }];
    
    // 3.创建一个下载任务
    __block ZJImageDownLoadOperation *downloadOperation = [ZJImageDownLoadOperation downLoadWithURLString:url completionBlock:^(UIImage *image, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 将图片回调到外界
            completionBlock(image,nil);
        });
        
        // 3.1 本地缓存图片
        [self.cacheManager saveImage:image urlString:url];
        // 3.2 下载任务从队列中移除
        [self.downloadingOperations removeObject:downloadOperation];
        
    }];
    
    // 4.添加到当前下载任务
    [self.downloadingOperations addObject:downloadOperation];
    
    // 5.将当前操作添加到队列
    [self.queue addOperation:downloadOperation];
    
    
    
    
    
}

-(void)cancelAllDownLoading{
    self.queue.suspended = YES;
}

-(void)recoverAllDownLoadOperations{
    self.queue.suspended = NO;
}

-(BOOL)isDownloadingWithURLString:(NSString *)url{

    if (self.downloadingOperations.count == 0) {
        return  NO;
    }
    
    __block BOOL isLoading = NO;
    
    [self.downloadingOperations enumerateObjectsUsingBlock:^(ZJImageDownLoadOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.urlString isEqualToString:url]) {
            *stop = YES;
            isLoading = YES;
        }
    }];
    
    return  isLoading;
}


@end
