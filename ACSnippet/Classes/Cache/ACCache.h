//
//  ACCache.h
//  HKU Campus
//
//  Created by Wenzhi WU on 12/7/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYKit/YYDiskCache.h>
#import "ACLRUCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACCache : NSObject

/// Name of cache storage
@property (copy, readonly) NSString *name;

/// A LRU based memory cache
@property (strong, readonly) ACLRUCache *memoryCache;

/// Disk storage for cache
@property (strong, readonly) YYDiskCache *diskCache;

/// Initialize ACCache object with unique name, file path will be auto-generated
/// @param name Name of cache storage
- (nullable instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

/// Initialize ACCache object with unique name and user specific file path
/// @param name Name of cahche storage
/// @param path File path
- (nullable instancetype)initWithName:(NSString *)name filePath:(NSString *)path NS_DESIGNATED_INITIALIZER;

/// Detect whether object with given key has been in cache
- (BOOL)containsObjectForKey:(NSString *)key;

/// Retrieve object for corresponded key
/// @param key Key for obeject
- (id <NSCoding>)objectForKey:(NSString *)key;

/// Retrieve object in completion block for corresponded key
/// @param key Key for object
/// @param block Retrieve completion block
- (void)objectForKey:(NSString *)key withBlock:(void (^)(NSString *key, id <NSCoding> object))block;

/// Store object in cache with a given key
/// @param object Cache target object
/// @param key Key for object
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key;

/// Store object in cache with a given key with completion block
/// @param object Cache target object
/// @param key Key for object
/// @param block Completion block
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key withBlock:(void(^)(void))block;

/// Remove cached object with corresponded key
/// @param key Key for object
- (void)removeObjectForKey:(NSString *)key;

/// Remove cached obejct with corresponded key and completion block for
/// @param key Key for object
/// @param block Removal completion block
- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block;

/// Remove all objects from memory cache and disk cache
- (void)removeAllObjects;

/// Remove all objects from memory cache and disk cache with completion block
/// @param block Removal completion block
- (void)removeAllObjectsWithBlock:(void(^)(void))block;

/// Remove all objects from memory cache and disk cache with progress and completion block
/// @param progress Removal progress block
/// @param end Removal completion block
- (void)removeAllObjectsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
                                 endBlock:(void(^)(BOOL error))end;


@end

NS_ASSUME_NONNULL_END
