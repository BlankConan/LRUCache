//
//  LRUCache.h
//  LRUCache
//
//  Created by me on 2025/1/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LRUCache<__covariant KeyType, __covariant ObjectType> : NSObject

// 初始化方法
- (instancetype)initWithCapacity:(NSUInteger)capacity;

// 设置缓存大小（字节）
@property (nonatomic, assign) NSUInteger cacheSizeLimit;

// 设置缓存数量上限
@property (nonatomic, assign) NSUInteger cacheCountLimit;

// 添加缓存（带大小）
- (void)setObject:(ObjectType)object forKey:(KeyType)key cost:(NSUInteger)cost;

// 添加缓存（不带大小，默认大小为 0）
- (void)setObject:(ObjectType)object forKey:(KeyType)key;

// 获取缓存
- (ObjectType)objectForKey:(KeyType)key;

// 移除缓存
- (void)removeObjectForKey:(KeyType)key;

// 清空缓存
- (void)removeAllObjects;

// 当前缓存大小（字节）
@property (nonatomic, readonly) NSUInteger currentCacheSize;

// 当前缓存数量
@property (nonatomic, readonly) NSUInteger currentCacheCount;

@end


NS_ASSUME_NONNULL_END
