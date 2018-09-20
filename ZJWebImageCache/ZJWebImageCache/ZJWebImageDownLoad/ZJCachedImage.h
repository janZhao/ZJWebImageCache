//
//  ZJCachedImage.h
//  ZJWebImageCache
//
//  Created by ZJ on 2018/9/19.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZJCachedImage : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *identifier;
@property (assign, nonatomic) UInt64 totalBytes;
@property (strong, nonatomic) NSDate *lastAccessDate;
@property (assign, nonatomic) UInt64 currentMemoryUsage;

-(UIImage *)accessImage;

@end
