//
//  ZJImageDownLoadOperation.h
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZJImageDownLoadOperation : NSOperation

@property (nonatomic, copy) NSString *urlString;

/// 下载任务是由一个 URL 字符串开始的。
+(instancetype)downLoadWithURLString:(NSString *)string completionBlock:(void (^)(UIImage *image,NSError *error))completionBlock;

@end
