//
//  ZJDiskCacheManager.m
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import "ZJDiskCacheManager.h"


/** 磁盘缓存阈值*/
#define kMaxDiskCacheSize 1024 * 1024 *40 // 40MB

/**沙盒目录路径*/
static NSString *dirCachePath;

@implementation ZJDiskCacheManager

+(void)load{
    // 配置沙盒目录路径
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    
     /** xxxCache/bundleID_imageCache */
    dirCachePath = [cacheDir stringByAppendingPathComponent:[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:@"_imageCache"]];
    // 计算文件总大小。
    NSUInteger totalSize = [self calculatorTotalSize];
    
    if (totalSize > kMaxDiskCacheSize) {
        // 清除磁盘缓存
        [[NSFileManager defaultManager] removeItemAtPath:dirCachePath error:nil];
        NSLog(@"-------------磁盘清理成功!------------");
        /** 立即创建目录 */
        [[NSFileManager defaultManager] createDirectoryAtPath:dirCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
}

+(NSUInteger)calculatorTotalSize{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *subFilePaths = [manager subpathsAtPath:dirCachePath];
    
    if (subFilePaths.count == 0) {
        return 0;
    }
    
    __block NSUInteger totalSize = 0;
    
    [subFilePaths enumerateObjectsUsingBlock:^(id  _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSString *filePath = [dirCachePath stringByAppendingPathComponent:fileName];
        totalSize += [manager attributesOfItemAtPath:filePath error:nil].fileSize;
        
    }];
    
    return totalSize;
}

/** 存储图片到目录 */
-(void)saveImage:(UIImage *)image urlString:(NSString *)urlString{
    
    if (!image) {
        return;
    }
    
    // 1.获取图片的hash值
    // url(hash) + 后缀名
    NSString *hashName = [self hashFileNameWithKey:urlString];
    NSString *subfixName = [@"." stringByAppendingString:urlString.pathExtension];
    
    NSString *fileSavePath = [dirCachePath stringByAppendingPathComponent:[hashName stringByAppendingString:subfixName]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:fileSavePath];
        NSData *data = UIImagePNGRepresentation(image);
        BOOL result = [data writeToFile:fileSavePath atomically:YES];
        result ? NSLog(@"%@ 存储成功!",fileSavePath) : NSLog(@"%@",@"沙盒存储失败!");
    });
}

-(NSString *)hashFileNameWithKey:(NSString *)key{
    NSString *hashedName = @( [key hash]).description;
    return hashedName;
}

/** 根据图片下载链接，在沙盒中找到此文件 */
- (void)imageForKey:(NSString *)key complectionBlock:(void(^)(UIImage *))complectionBlock {
    NSAssert(complectionBlock && key, @"complectionBlock 和 key 不能为空!");
    //
    NSString *lastComponent = [@"." stringByAppendingString: key.pathExtension];
    // 文件存储的 hash 命
    NSString *hashName = [self hashFileNameWithKey:key];
    // 文件搜索路径
    NSString *fileName = [dirCachePath stringByAppendingPathComponent:[hashName stringByAppendingString:lastComponent]];
    
    // 因为 I/O 操作时比较耗时的，所以，使用 block 回传图片
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:fileName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            complectionBlock(image);
            NSLog(@"%@",dirCachePath);
        });
    });
    
}

@end
