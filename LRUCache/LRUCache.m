//
//  LRUCache.m
//  LRUCache
//
//  Created by me on 2025/1/24.
//

#import "LRUCache.h"

#import <Foundation/Foundation.h>
#import <os/lock.h>

@implementation LRUCache {
    NSMutableDictionary *_cache; // 缓存存储
    NSMutableDictionary *_costs; // 缓存对象的大小
    NSMutableArray *_lruKeys; // 最近使用的键
    NSUInteger _currentCacheSize; // 当前缓存大小
    os_unfair_lock _lock; // 高性能锁
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _cache = [NSMutableDictionary dictionaryWithCapacity:capacity];
        _costs = [NSMutableDictionary dictionaryWithCapacity:capacity];
        _lruKeys = [NSMutableArray arrayWithCapacity:capacity];
        _cacheSizeLimit = NSUIntegerMax;
        _cacheCountLimit = capacity;
        _currentCacheSize = 0;
        _lock = OS_UNFAIR_LOCK_INIT; // 初始化锁
    }
    return self;
}

- (void)setObject:(id)object forKey:(id)key cost:(NSUInteger)cost {
    if (!key || !object) {
        return;
    }
    
    os_unfair_lock_lock(&_lock); // 加锁
    @try {
        // 如果键已存在，先移除旧值
        if (_cache[key]) {
            [self removeObjectForKey:key];
        }
        
        // 添加新值
        _cache[key] = object;
        _costs[key] = @(cost);
        [_lruKeys addObject:key];
        _currentCacheSize += cost;
        
        // 检查缓存是否超出限制
        [self evictIfNeeded];
    } @finally {
        os_unfair_lock_unlock(&_lock); // 解锁
    }
}

- (void)setObject:(id)object forKey:(id)key {
    [self setObject:object forKey:key cost:0]; // 默认大小为 0
}

- (id)objectForKey:(id)key {
    if (!key) {
        return nil;
    }
    
    os_unfair_lock_lock(&_lock); // 加锁
    @try {
        // 获取缓存对象
        id object = _cache[key];
        if (object) {
            // 将键移动到最近使用的位置
            [_lruKeys removeObject:key];
            [_lruKeys addObject:key];
        }
        return object;
    } @finally {
        os_unfair_lock_unlock(&_lock); // 解锁
    }
}

- (void)removeObjectForKey:(id)key {
    if (!key) {
        return;
    }
    
    os_unfair_lock_lock(&_lock); // 加锁
    @try {
        // 移除缓存对象
        id object = _cache[key];
        if (object) {
            [_cache removeObjectForKey:key];
            [_costs removeObjectForKey:key];
            [_lruKeys removeObject:key];
            _currentCacheSize -= [_costs[key] unsignedIntegerValue];
        }
    } @finally {
        os_unfair_lock_unlock(&_lock); // 解锁
    }
}

- (void)removeAllObjects {
    os_unfair_lock_lock(&_lock); // 加锁
    @try {
        [_cache removeAllObjects];
        [_costs removeAllObjects];
        [_lruKeys removeAllObjects];
        _currentCacheSize = 0;
    } @finally {
        os_unfair_lock_unlock(&_lock); // 解锁
    }
}

- (NSUInteger)currentCacheSize {
    os_unfair_lock_lock(&_lock); // 加锁
    @try {
        return _currentCacheSize;
    } @finally {
        os_unfair_lock_unlock(&_lock); // 解锁
    }
}

- (NSUInteger)currentCacheCount {
    os_unfair_lock_lock(&_lock); // 加锁
    @try {
        return _cache.count;
    } @finally {
        os_unfair_lock_unlock(&_lock); // 解锁
    }
}

// 检查并清除超出限制的缓存
- (void)evictIfNeeded {
    while (_currentCacheSize > _cacheSizeLimit || _cache.count > _cacheCountLimit) {
        if (_lruKeys.count == 0) {
            break;
        }
        
        // 移除最近最少使用的键
        id lruKey = _lruKeys.firstObject;
        [self removeObjectForKey:lruKey];
    }
}

@end
