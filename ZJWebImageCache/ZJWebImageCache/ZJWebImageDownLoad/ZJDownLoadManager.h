//
//  ZJDownLoadManager.h
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZJImageDownLoadOperation.h"
#import "ZJCacheManager.h"

// 使用typedef声明block、这就声明了一个TraverseTreeHandler类型的block
typedef void (^CompletionBlockHandler)(UIImage *image, NSError *error);

@interface ZJDownLoadManager : NSObject

// 声明一个block对象、注意对象属性设置为copy、接到block参数时、便会自动复制一份。
@property (nonatomic, copy) CompletionBlockHandler completionBlock;

+(instancetype)sharedManager;

-(void)cancelAllDownLoading;//取消所有下载任务
-(void)recoverAllDownLoadOperations;//继续所有下载任务

//下载图片
//-(void)downLoadImageWithURLString:(NSString *)url completionBlock:(void (^)(UIImage *,NSError *)) completionBlock;
-(void)downLoadImageWithURLString:(NSString *)url completionBlock:(CompletionBlockHandler)completionBlock;

@end
