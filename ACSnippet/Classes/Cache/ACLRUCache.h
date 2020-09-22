//
//  ACLRUCache.h
//  TilesnameTest
//
//  Created by Wenzhi WU on 29/6/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ACLRUCache;

/// Delegate protocol of ACLRUCache object
@protocol ACLRUCacheDelegate <NSObject>

/// Invoked when object for keys were trimmed by limits
/// @param cache ACLRUCache object
/// @param keys Trimmed object keys
- (void)lruCache:(ACLRUCache *)cache didTrimObjectsForKeys:(NSArray <NSString *>*)keys;

@end

@interface ACLRUCache : NSObject

/// Name of lru cache
@property (nonatomic, copy) NSString    *name;

/// Delegate of ACLRUCache object
@property (nonatomic, weak) id <ACLRUCacheDelegate> delegate;

/// Number of cached objects
@property (nonatomic, assign, readonly) NSUInteger totalCount;

/// Total cache cost
@property (nonatomic, assign, readonly) NSUInteger totalCost;

/// Object count limit for auto-trimming
@property (nonatomic, assign) NSUInteger countLimit;

/// Cache cost limit for auto-trimming
@property (nonatomic, assign) NSUInteger costLimit;

/// Time limit for auto-trimming
@property (nonatomic, assign) NSTimeInterval timeLimit;

/// Clean cache when app receive memory warning
@property (nonatomic, assign) BOOL shouldRemoveAllObjectsOnMemoryWarning;

/// Clean cache when app enter background
@property (nonatomic, assign) BOOL shouldRemoveAllObjectsWhenEnteringBackground;

/// Check if obejct with specific key has been cached in ACLRUCache object
/// @param key Key for object
- (BOOL)containsObjectForKey:(NSString *)key;

/// Store object for given key with cache cost
/// @param object Object for cache
/// @param key Key for object
/// @param cost Cache cost
- (void)setObject:(id)object forKey:(NSString *)key cost:(NSUInteger)cost;

/// Store object for given key with cache cost default '0'
/// @param object Object for cache
/// @param key Key for object
- (void)setObject:(id)object forKey:(NSString *)key;

/// Remove object with corresponded key
/// @param key Key for object
- (void)removeObjectForKey:(NSString *)key;

/// Retrieve object with key
/// @param key Key for object
- (id)objectForKey:(NSString *)key;

/// Remove all objects from cache
- (void)removeAllObjects;

/// Trim objects in background
- (void)trimInBackground;

/// Retrieve all cached object keys
- (NSArray <NSString *>*)objectKeys;

@end

NS_ASSUME_NONNULL_END
