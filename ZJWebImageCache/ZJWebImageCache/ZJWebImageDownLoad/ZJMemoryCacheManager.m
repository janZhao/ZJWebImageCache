//
//  ZJMemoryCacheManager.m
//  TestZJSDWebImage
//
//  Created by ZJ on 2018/9/3.
//  Copyright © 2018年 jydZJ. All rights reserved.
//

#import "ZJMemoryCacheManager.h"
#import "ZJCachedImage.h"

#define  kMaxCacheCount 100

// 缓存字典
static NSMutableDictionary const *memoryCache;

@interface ZJMemoryCacheManager()

@property (strong, nonatomic) NSMutableDictionary<NSString *, ZJCachedImage *> *cachedImages;
@property (assign, nonatomic) UInt64 currentMemoryUsage;
@property (strong, nonatomic) dispatch_queue_t synchronizationQueue;

@end

@implementation ZJMemoryCacheManager

-(instancetype)init{
    if (self = [super init]) {
        // 监听内存警告事件
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return [self initWithMemoryCapacity:100*1024*1024 preferredMemoryCapacity:60*1024*1024];
}

-(instancetype)initWithMemoryCapacity:(UInt64)memoryCapacity preferredMemoryCapacity:(UInt64)preferredMemoryCapacity{
    
    if (self = [super init]) {
        self.memoryCapacity = memoryCapacity;
        self.prferredMemoryUsageAfterPurge = preferredMemoryCapacity;
        self.cachedImages = [[NSMutableDictionary alloc]init];
        
        NSString *queueName = [NSString stringWithFormat:@"com.jyd.%@",[[NSUUID UUID] UUIDString]];
        self.synchronizationQueue = dispatch_queue_create([queueName cStringUsingEncoding:queueName], DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

-(UInt64)memoryUsage{
    __block UInt64 result = 0;
    
    dispatch_sync(self.synchronizationQueue, ^{
        result = self.currentMemoryUsage;
    });
    
    return result;
}

+(void)initialize{
    memoryCache = [NSMutableDictionary dictionary];
}

-(void)addImage:(UIImage *)image withIdentifier:(NSString *)identifier{
    dispatch_barrier_async(self.synchronizationQueue, ^{
       
        ZJCachedImage *cacheImage = [[ZJCachedImage alloc]init];
        ZJCachedImage *previousCachedImage = self.cachedImages[identifier];
        
        if (previousCachedImage != nil) {
            self.currentMemoryUsage -= previousCachedImage.totalBytes;
        }
        
        self.cachedImages[identifier] = cacheImage;
        self.currentMemoryUsage += cacheImage.totalBytes;
    });
    
    dispatch_barrier_async(self.synchronizationQueue, ^{
        if (self.currentMemoryUsage > self.memoryCapacity) {
            UInt64 bytesToPurge = self.currentMemoryUsage - self.prferredMemoryUsageAfterPurge;
            NSMutableArray<ZJCachedImage*> *sortedImages = [NSMutableArray arrayWithArray:self.cachedImages.allValues];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastAcccessDate" ascending:YES];
            [sortedImages sortUsingDescriptors:@[sortDescriptor]];
            
            UInt64 bytesPurged = 0;
            
            for (ZJCachedImage *cachedImage in sortedImages) {
                [self.cachedImages removeObjectForKey:cachedImage.identifier];
                bytesPurged += cachedImage.totalBytes;
                if (bytesPurged >= bytesToPurge) {
                    break;
                }
            }
            self.currentMemoryUsage -= bytesToPurge;
        }
    });
}

- (BOOL)removeImageWithIdentifier:(NSString *)identifier {
    __block BOOL removed = NO;
    dispatch_barrier_sync(self.synchronizationQueue, ^{
        ZJCachedImage *cachedImage = self.cachedImages[identifier];
        if (cachedImage != nil) {
            [self.cachedImages removeObjectForKey:identifier];
            self.currentMemoryUsage -= cachedImage.totalBytes;
            removed = YES;
        }
    });
    return removed;
}

-(nullable UIImage *)imageWithIdentifier:(NSString *)identifier{
    __block UIImage *image = nil;
    dispatch_sync(self.synchronizationQueue, ^{
        ZJCachedImage *cachedImage = self.cachedImages[identifier];
        image = [cachedImage accessImage];
    });
    
    return image;
}


- (BOOL)removeAllImages {
    __block BOOL removed = NO;
    dispatch_barrier_sync(self.synchronizationQueue, ^{
        if (self.cachedImages.count > 0) {
            [self.cachedImages removeAllObjects];
            self.currentMemoryUsage = 0;
            removed = YES;
        }
    });
    return removed;
}

#pragma mark - 监听到内存警告通知，删除内存中所有图片
- (void)applicationDidReceiveMemoryWarningNotification {
    // 清空字典
    [memoryCache removeAllObjects];
    
    NSLog(@"收到了内存警告，清空内存字典!");
}

/** 根据 URL 取得缓存图片 */
-(UIImage *)imageForKey:(NSString *)key{
    return [memoryCache objectForKey:key];
}

/** 根据 URL 设置缓存 */
-(void)setImageForKey:(UIImage *)image ForKey:(NSString *)key{
    if ([memoryCache.allKeys containsObject:key]) {
        return;//取消重复缓存
    }
    [memoryCache setObject:image forKey:key];
    
    if (memoryCache.count > kMaxCacheCount) {
        [memoryCache removeObjectForKey: memoryCache.allKeys.firstObject];
    }
    
    //2.1 或者可以设计一套算法，根据图片的使用次数排序，当内存警告时，每次都删除使用次数最少的那张图片。
    
    //2.2 或者使用双列链表，来实现 **最近使用图片优先保留**算法，每次使用一张图片，就把这个图片放在链表的头部。每次内存警告的时候，从链表的尾部删除。
    
    // 淘汰策略
    // FIFO，LRU，LFU缓存过期策略。
    // 1.FIFO（First In First out）：先见先出，淘汰最先近来的页面，新进来的页面最迟被淘汰，完全符合队列。
          // 数据结构上使用队列来实现
          //1.1 新访问的数据插入FIFO队列尾部，数据在FIFO队列中顺序移动
         // 1.2 淘汰FIFO队列头部的数据；
    
    
    // 2.LRU（Least recently used）:最近最少使用，淘汰最近不使用的页面。
          // Least recently used，最近最少使用）算法根据数据的历史访问记录来进行淘汰数据，
         // 其核心思想是“如果数据最近被访问过，那么将来被访问的几率也更高”。
         // 最常见的实现是使用一个链表保存缓存数据
    // 2.1 新数据插入到链表头部；
    // 2.2 每当缓存命中（即缓存数据被访问），则将数据移到链表头部；
    // 2.3 当链表满的时候，将链表尾部的数据丢弃。
    
    
    // 3.LFU（Least frequently used）: 最近使用次数最少， 淘汰使用次数最少的页面
         //Least Frequently Used）算法根据数据的历史访问频率来淘汰数据
         //，其核心思想是“如果数据过去被访问多次，那么将来被访问的频率也更高”。
        // 3.1 LFU的每个数据块都有一个引用计数，所有数据块按照引用计数排序，具有相同引用计数的数据块则按照时间排序。
    
    // 4.自适应缓存替换算法(ARC)：
    // 在IBM Almaden研究中心开发，这个缓存算法同时跟踪记录LFU和LRU，以及驱逐缓存条目，来获得可用缓存的最佳使用。
}

@end
