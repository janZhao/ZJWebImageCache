//
//  ZJDiskCacheManager.h
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ZJDiskCacheManager : NSObject

// 根据图片下载链接、在沙盒中找到此文件
-(void)imageForKey:(NSString *)urlString completionBlock:(void (^)(UIImage *))completionBlock;

// 保存图片到沙盒
-(void)saveImage:(UIImage *)image urlString:(NSString *)urlString;


@end
