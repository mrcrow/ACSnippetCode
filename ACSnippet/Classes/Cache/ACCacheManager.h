//
//  ACCacheManager.h
//  FMDBTest
//
//  Created by Wenzhi WU on 23/5/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACCacheManagerDownloader.h"
#import "ACCache.h"
#import "ACCacheObject.h"


@class ACCacheManager;

/// Delegate of ACCacheManager object
@protocol ACCacheManagerDelegate <NSObject>
@optional

/// Invoked when caches has been updated by checkout strategy
/// @param manager ACCacheManager object
/// @param keys Updated cache keys
- (void)cacheManager:(ACCacheManager *)manager didUpdateObjectsForKeys:(NSArray <NSString *>*)keys;

/// Invoked when memory cache trimmed object due to limits
/// @param manager ACCacheManager object
/// @param keys Trimmed keys
- (void)cacheManager:(ACCacheManager *)manager didTrimMemoryCachedObjectsForKeys:(NSArray<NSString *> *)keys;

/// Invoked when checkout strategy is enabled, the return keys will request versions for comparing
///  1) If downloader is not checkout enabled, then whis method will not get called
///  2) If this method is not been implemented in the delegate, then default checkout all the keys in monitoring
///
///  @param manager ACCacheManager object
///  @param keys Keys in monitoring list
- (NSArray <NSString *>*)cacheManager:(ACCacheManager *)manager shouldCheckoutObjectVersionsForKeys:(NSArray <NSString *>*)keys;

/// Invoked when ACCacheManager failed to download cache for keys
/// @param manager ACCacheManager object
/// @param keys Request keys
/// @param error Request failed with error
- (void)cacheManager:(ACCacheManager *)manager didFailToDownloadObjectsForKeys:(NSArray <NSString *>*)keys withError:(NSError *)error;

/// Invoked when failed object has been successfully download by downloader
/// @param manager ACCacheManager object
/// @param objects Objects that once in retry stack
- (void)cacheManager:(ACCacheManager *)manager didDownloadRetryObjects:(NSArray <id <ACCacheObject>>*)objects;

@end

@interface ACCacheManager : NSObject

/// Name of ACCacheManager, this should be unique in the app namespace
@property (nonatomic, copy, readonly)   NSString    *name;

/// Set to YES to avoid version checkout and update monitored cache
@property (nonatomic, assign)   BOOL    avoidVersionCheckout;

/// Cache content save to disk or not
@property (nonatomic, assign, readonly) BOOL    cacheToDisk;

/// Disk cache storage
@property (nonatomic, strong, readonly) ACCache *storage;

/// Downloader for object retrieving
@property (nonatomic, strong, readonly) id <ACCacheManagerDownloader>   downloader;

/// Delegate object for ACCacheManager
@property (nonatomic, weak) id <ACCacheManagerDelegate> delegate;

/// Designate initialzer for ACCacheManager with name, downloader and setting up cache object to disk or not
/// @param name Name of ACCacheManager
/// @param downloader Cache downloader
/// @param disk Cache to disk or not
/// @param interval Monitored cache refresh interval
- (instancetype)initWithName:(NSString *)name downloader:(id <ACCacheManagerDownloader>)downloader cacheToDisk:(BOOL)disk refreshInterval:(NSTimeInterval)interval;

/// Retrieve single cache object from ACCacheManager or download from provided ACCacheManagerDownloader, if downloader is not set, then cache will only load from local store
/// @param key Key for object
/// @param handler Completion handler for object retrieving
- (void)objectForKey:(NSString *)key completionHandler:(void (^)(NSError *error, id <ACCacheObject> cache))handler;

/// Force to download objects for input keys
/// @param keys Keys for downloading
/// @param completion Completion hander
- (void)downloadObjectsForKeys:(NSArray <NSString *>*)keys completion:(void (^)(NSError *))completion;

/// Retrieve multiple cache objects from ACCacheManager or download from provided ACCacheManagerDownloader, storage find out handler and request completion handler are seperated as two completion blocks, if downloader is not set, then cache will only load from local storage
///
/// @param keys Keys for cache objects
/// @param storage Local storage callback handler
/// @param completion Request download completion handler
- (void)objectsForKeys:(NSArray<NSString *> *)keys storageHandler:(void (^)(NSArray<ACCacheObject> *))storage requestCompletionHandler:(void (^)(NSError *, NSArray<NSString *> *, NSArray<ACCacheObject> *))completion;

/// Add keys in download queue for retry downloading
/// @param keys Keys for object downloading
- (void)retryDownloadObjectsForKeys:(NSArray <NSString *>*)keys;

/// Remove downloading object keys from request stack
/// @param keys Keys for object listing in downloader retry stack
- (void)removeRetryObjectsForKeys:(NSArray <NSString *>*)keys;

/// Store object and assign corresponed key for retrieving
/// @param object Object to be stored
/// @param key Key for object in storage
- (void)setObject:(id <ACCacheObject>)object forKey:(NSString *)key;

/// Check if object with given key is exist in storage
/// @param key Key for object in storage
- (BOOL)containsObjectForKey:(NSString *)key;

/// Remove corresponded stored object with key
/// @param key Key for object in storage
- (void)removeObjectForKey:(NSString *)key;

/// Get stored object for key
/// @param key Key for obejct in storage
- (id <ACCacheObject>)objectForKey:(NSString *)key;


@end
