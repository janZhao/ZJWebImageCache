//
//  ZJImageDownLoadOperation.m
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import "ZJImageDownLoadOperation.h"

@interface ZJImageDownLoadOperation()

@property (strong, nonatomic) NSURL *URL;

@property (copy, nonatomic) void(^downloadCompletionBlock)(UIImage *image,NSError *error);

@end

@implementation ZJImageDownLoadOperation

+(instancetype)downLoadWithURLString:(NSString *)urlString completionBlock:(void (^)(UIImage *image, NSError *error))completionBlock
{
    ZJImageDownLoadOperation *obj = [ZJImageDownLoadOperation new];
    obj.URL = [NSURL URLWithString:urlString];
    obj.downloadCompletionBlock = completionBlock;
    obj.urlString = urlString;
    
    return obj;
}

// 重写main方法 开启下载任务dataTask
-(void)main{
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:self.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        error ? self.downloadCompletionBlock(nil,error) : self.downloadCompletionBlock([UIImage imageWithData:data],nil);
    }];
    [task resume];
}


@end
