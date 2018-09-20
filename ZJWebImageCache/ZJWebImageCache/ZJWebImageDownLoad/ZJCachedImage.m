//
//  ZJCachedImage.m
//  ZJWebImageCache
//
//  Created by ZJ on 2018/9/19.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import "ZJCachedImage.h"

@implementation ZJCachedImage

-(instancetype)initWithImage:(UIImage *)image identifier:(NSString *)identifier{
    if (self = [super init]) {
        self.image = image;
        self.identifier = identifier;
        
        CGSize imageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
        CGFloat bytesPerPixel = 4.0;
        CGFloat bytesPerRow = imageSize.width * bytesPerPixel;
    
        self.totalBytes = (UInt64)imageSize.height *  bytesPerRow;
        self.lastAccessDate = [NSDate date];
    }
    
    return self;
}

-(UIImage *)accessImage{
    self.lastAccessDate = [NSDate date];
    return  self.image;
}

-(NSString *)description{
    NSString *descriptionString = [NSString stringWithFormat:@"Idenfitier: %@  lastAccessDate: %@ ", self.identifier, self.lastAccessDate];
    return descriptionString;
}


@end
