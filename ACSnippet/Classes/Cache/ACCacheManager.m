//
//  ACCacheManager.m
//  FMDBTest
//
//  Created by Wenzhi WU on 23/5/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import "ACCacheManager.h"
#import <Reachability/Reachability.h>
#import <YYKit/YYKit.h>

/// Default retry request interval
#define RETRY_TIMER_INTERVAL 10


@interface ACCacheManager () <ACLRUCacheDelegate>

/// Checkout timer fire interval
@property (nonatomic, assign)   NSTimeInterval  refreshInterval;

/// Cache object which has been retrieved from server-side or get from memory cache or disk cache will be added to monitoring list
@property (nonatomic, strong)   YYThreadSafeDictionary  *monitoredKeysAndVersions;

/// Used to manage retry download for objects that failed to download
@property (nonatomic, strong)   NSMutableSet    *retryStack;

/// Cache refresh timer
@property (nonatomic, strong)   dispatch_source_t   refreshTimer;

/// Retry timer for failed object downloading
@property (nonatomic, strong)   dispatch_source_t   retryTimer;

/// Network reachibility status
@property (nonatomic, strong)   Reachability    *reachibility;

@end

@implementation ACCacheManager

- (instancetype)initWithName:(NSString *)name downloader:(id<ACCacheManagerDownloader>)downloader cacheToDisk:(BOOL)disk refreshInterval:(NSTimeInterval)interval {
    self = [super init];
    if (self) {
        _name = name;
        NSString *path = [self cacheToPathForName:name toDisk:disk];
        _storage = [[ACCache alloc] initWithName:name filePath:path];
        _storage.memoryCache.delegate = self;
        
        _refreshInterval = interval;
        _downloader = downloader;
        _monitoredKeysAndVersions = [YYThreadSafeDictionary new];
        _retryStack = [NSMutableSet set];
        
        [self registerReachibilityChanges];
    }
    
    return self;
}

- (void)dealloc {
    [self invalidateRefreshTimer];
    [self invalidateRetryTimer];
}

/// Get directory path for cache name and disk setting
/// @param name Cache name
/// @param disk Save to disk setting
- (NSString *)cacheToPathForName:(NSString *)name toDisk:(BOOL)disk {
    NSSearchPathDirectory domain = disk ? NSDocumentDirectory : NSCachesDirectory;
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(domain, NSUserDomainMask, YES) firstObject];
    return [cacheDirectory stringByAppendingPathComponent:name];
}

/// Register reachibility changes
- (void)registerReachibilityChanges {
    Reachability *reachibility = [Reachability reachabilityForInternetConnection];
    
    __weak typeof(self) weakSelf = self;
    [_reachibility setReachableBlock:^(Reachability *reachability) {
        __strong typeof(weakSelf) self = weakSelf;
        [self registerRefreshTimer];
        [self registerRetryTimer];
    }];
    [_reachibility setUnreachableBlock:^(Reachability *reachability) {
        __strong typeof(weakSelf) self = weakSelf;
        [self invalidateRefreshTimer];
        [self invalidateRetryTimer];
    }];
    
    _reachibility = reachibility;
    if ([reachibility currentReachabilityStatus] == NotReachable) return;

    [self registerRefreshTimer];
}

/// Register refresh timer for content update
- (void)registerRefreshTimer {
    if (!_downloader || ![_downloader respondsToSelector:@selector(downloadObjectsForKeys:completionHandler:)]) return;
    if (!_avoidVersionCheckout && ![_downloader respondsToSelector:@selector(checkoutObjectVesionsForKeys:completionHandler:)]) {
        NSLog(@"Invalid setting for content update");
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    _refreshTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_refreshTimer,
                              dispatch_time(DISPATCH_TIME_NOW, _refreshInterval * NSEC_PER_SEC),
                              NSEC_PER_SEC * _refreshInterval,
                              NSEC_PER_SEC * _refreshInterval * 0.1);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(_refreshTimer, ^{
        __strong typeof(weakSelf) self = weakSelf;
        NSArray *keys = self.monitoredKeysAndVersions.allKeys;
        if (![keys count]) return;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(cacheManager:shouldCheckoutObjectVersionsForKeys:)]) {
            keys = [self.delegate cacheManager:self shouldCheckoutObjectVersionsForKeys:keys];
        }
        
        if (![keys count]) return;
        
        if (self.avoidVersionCheckout) {
            [self downloadObjectsForKeys:keys completion:nil];
        } else {
            [self.downloader checkoutObjectVesionsForKeys:keys completionHandler:^(NSError *error, NSDictionary *versions, NSArray<NSString *> *keys) {
                if (error) return;
                
                NSArray *expiredKeys = [self expiredKeysForKeys:keys compareToVersions:versions];
                if (![expiredKeys count]) return;

                [self downloadObjectsForKeys:expiredKeys completion:nil];
            }];
        }
    });
    dispatch_resume(_refreshTimer);
}

/// Stop refresh timer
- (void)invalidateRefreshTimer {
    if (!_refreshTimer) return;
    
    dispatch_source_cancel(_refreshTimer);
    _refreshTimer = nil;
}

/// Filter out expired keys comparing to new version info
/// @param keys Keys for filter
/// @param versions Updated version info
- (NSArray *)expiredKeysForKeys:(NSArray *)keys compareToVersions:(NSDictionary *)versions {
    NSMutableArray *mutable = @[].mutableCopy;
    for (NSString *key in keys) {
        NSString *oldVersion = _monitoredKeysAndVersions[key];
        NSString *newVersion = versions[key];
        if ([oldVersion isEqualToString:newVersion]) continue;
        
        [mutable addObject:key];
    }
    
    return mutable.copy;
}

- (void)downloadObjectsForKeys:(NSArray <NSString *>*)keys completion:(void (^)(NSError *))completion {
    __weak typeof(self) _self = self;
    [self.downloader downloadObjectsForKeys:keys completionHandler:^(NSError *error, NSArray<id<ACCacheObject>> *download) {
        __strong typeof(_self) self = _self;
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(cacheManager:didFailToDownloadObjectsForKeys:withError:)]) {
                [self.delegate cacheManager:self didFailToDownloadObjectsForKeys:keys withError:error];
            }
            
            if (completion) {
                completion(error);
            }
            
            return;
        }
        
        if (![download count]) {
            if (completion) {
                completion(nil);
            }
            
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableArray *updated = @[].mutableCopy;
            for (id <ACCacheObject> obj in download) {
                BOOL update = [self.storage containsObjectForKey:obj.objectID];
                [self.storage setObject:obj forKey:obj.objectID];
                [self.monitoredKeysAndVersions setObject:obj.objectVersion forKey:obj.objectID];
                
                if (!update) continue;
                [updated addObject:obj.objectID];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(cacheManager:didUpdateObjectsForKeys:)]) {
                    [self.delegate cacheManager:self didUpdateObjectsForKeys:updated.copy];
                }
                
                if (completion) {
                    completion(nil);
                }
            });
        });
    }];
}

- (void)objectForKey:(NSString *)key completionHandler:(void (^)(NSError *, id<ACCacheObject>))handler {
    NSAssert(handler, @"the only one completion handler should not be nil");
    
    if ([_storage containsObjectForKey:key]) {
        id <ACCacheObject> cache = (id <ACCacheObject>)[self.storage objectForKey:key];
        if (!_monitoredKeysAndVersions[key]) {
            [_monitoredKeysAndVersions setObject:cache.objectVersion forKey:key];
        }
        
        handler(nil, cache);
    } else {
        if (!_downloader) return;
        
        NSArray *filtered = [_downloader filterOutKeysInDownloading:@[key]];
        if (![filtered count]) return;
        
        __weak typeof(self) _self = self;
        [_downloader downloadObjectsForKeys:filtered completionHandler:^(NSError *error, NSArray<id<ACCacheObject>> *download) {
            if (error) {
                handler(error, nil);
                return;
            }
            
            __strong typeof(_self) self = _self;
            for (id <ACCacheObject> object in download) {
                [self.storage setObject:object forKey:object.objectID];
                [self.monitoredKeysAndVersions setObject:object.objectVersion forKey:object.objectID];
            }
            
            handler(nil, download.firstObject);
        }];
    }
}

- (void)objectsForKeys:(NSArray<NSString *> *)keys storageHandler:(void (^)(NSArray<ACCacheObject> *))storage requestCompletionHandler:(void (^)(NSError *, NSArray<NSString *> *, NSArray<ACCacheObject> *))completion {
    NSAssert((storage || completion), @"at lease one completion block should be set not nil");
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSMutableArray *caches = @[].mutableCopy;
        NSMutableArray *requestKeys = @[].mutableCopy;
        
        for (NSString *key in keys) {
            id <ACCacheObject> object = (id <ACCacheObject>)[self.storage objectForKey:key];
            if (object) {
                if (!self.monitoredKeysAndVersions[key]) {
                    [self.monitoredKeysAndVersions setObject:object.objectVersion forKey:key];
                }
                
                [caches addObject:object];
            } else {
                [requestKeys addObject:key];
            }
        }
        
        if ([caches count] && storage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                storage(caches.copy);
            });
        }
        
        if (!self.downloader) return;
        NSArray *filtered = [self.downloader filterOutKeysInDownloading:requestKeys.copy];
        if ([filtered count]) {
            __weak typeof(self) _self = self;
            [self.downloader downloadObjectsForKeys:filtered completionHandler:^(NSError *error, NSArray<id<ACCacheObject>> *download) {
                __strong typeof(_self) self = _self;
                if (error) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(cacheManager:didFailToDownloadObjectsForKeys:withError:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate cacheManager:self didFailToDownloadObjectsForKeys:filtered withError:error];
                        });
                    }
                       
                    if (!completion) {
                        [self retryDownloadObjectsForKeys:filtered];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(error, filtered, nil);
                        });
                    }
                    
                    return;
                }
                   
                NSMutableArray *objects = @[].mutableCopy;
                for (id <ACCacheObject> obj in download) {
                    [self.storage setObject:obj forKey:obj.objectID];
                    [self.monitoredKeysAndVersions setObject:obj.objectVersion forKey:obj.objectID];
                    [objects addObject:obj];
                }
                
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, filtered, objects.copy);
                    });
                }
            }];
        }
    });
}

- (void)retryDownloadObjectsForKeys:(NSArray<NSString *> *)keys {
    if (!_downloader) return;
    
    [_retryStack addObjectsFromArray:keys];
    [self registerRetryTimer];
}

/// Register retry timer for failed object request
- (void)registerRetryTimer {
    if (_retryTimer || ![_retryStack count] || [_reachibility currentReachabilityStatus] == NotReachable) return;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    _retryTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_retryTimer,
                              dispatch_time(DISPATCH_TIME_NOW, RETRY_TIMER_INTERVAL * NSEC_PER_SEC),
                              NSEC_PER_SEC * RETRY_TIMER_INTERVAL,
                              NSEC_PER_SEC * RETRY_TIMER_INTERVAL * 0.1);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(_retryTimer, ^{
        __strong typeof(weakSelf) self = weakSelf;
        NSArray *keys = [self.retryStack allObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downloader downloadObjectsForKeys:keys completionHandler:^(NSError *error, NSArray<id<ACCacheObject>> *download) {
                if (error) {
                    NSLog(@"ACCacheManager failed to download retry objects for keys: %@", keys);
                } else {
                    for (id <ACCacheObject> object in download) {
                        [self.retryStack removeObject:object.objectID];
                        [self setObject:object forKey:object.objectID];
                    }
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(cacheManager:didDownloadRetryObjects:)]) {
                        [self.delegate cacheManager:self didDownloadRetryObjects:download];
                    }
                }
                
                [self invalidateRetryTimer];
                [self registerRetryTimer];
            }];
        });
    });
    dispatch_resume(_retryTimer);
}

/// Stop retry timer
- (void)invalidateRetryTimer {
    if (!_retryTimer) return;
    
    dispatch_source_cancel(_retryTimer);
    _retryTimer = nil;
}

- (void)removeRetryObjectsForKeys:(NSArray<NSString *> *)keys {
    for (NSString *key in keys) {
        [_retryStack removeObject:key];
    }
    
    if ([_retryStack count]) return;
    [self invalidateRetryTimer];
}

- (void)setObject:(id<ACCacheObject>)object forKey:(NSString *)key {
    [_storage setObject:object forKey:key];
}

- (BOOL)containsObjectForKey:(NSString *)key {
    return [_storage containsObjectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
    [_storage removeObjectForKey:key];
}

- (id <ACCacheObject>)objectForKey:(NSString *)key {
    return (id <ACCacheObject>)[_storage objectForKey:key];
}

#pragma mark - ACLRUCacheDelegate
- (void)lruCache:(ACLRUCache *)cache didTrimObjectsForKeys:(NSArray<NSString *> *)keys {
    [self.monitoredKeysAndVersions removeObjectsForKeys:keys];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cacheManager:didTrimMemoryCachedObjectsForKeys:)]) {
        [self.delegate cacheManager:self didTrimMemoryCachedObjectsForKeys:keys];
    }
}

@end
