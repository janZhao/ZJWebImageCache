//
//  ZJMemoryCacheManager.h
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZJMemoryCacheManager : NSObject

// 根据URL缓存去取图片
-(UIImage *)imageForKey:(NSString *)key;

// 设置URL缓存
-(void)setImageForKey:(UIImage *)image ForKey:(NSString *)key;

@end
