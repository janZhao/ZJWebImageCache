//
//  ZJCacheManager.h
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ZJCacheManager : NSObject

/** 根据下载链接查询图片文件 */
- (void)imageForKey:(NSString *)key findImageBlock:(void(^)(UIImage *image))findIimageBlock;

/** 保存文件到内存和磁盘 */
-(void)saveImage:(UIImage *)image urlString:(NSString *)urlString;

@end
