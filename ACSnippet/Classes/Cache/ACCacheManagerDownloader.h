//
//  ACCacheManagerDownloader.h
//  FMDBTest
//
//  Created by Wenzhi WU on 23/5/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACCacheObject.h"

/// Protocol for implementing downloader for ACCacheManager
@protocol ACCacheManagerDownloader <NSObject>
@optional

/// Implement this method to enable version checkout control for cache
/// @param keys Keys for objects
/// @param handler Completion handler
- (void)checkoutObjectVesionsForKeys:(NSArray *)keys completionHandler:(void (^)(NSError *error, NSDictionary *versions, NSArray <NSString *> *keys))handler;

@required

/// Filter out keys in downloading queue and return the keys not in downloading
/// @param keys Keys for filtering
- (NSArray *)filterOutKeysInDownloading:(NSArray <NSString *>*)keys;

/// Keys in downloading queue
- (NSArray *)keysInDownloading;

/// Implement this method to download cachable object with keys
/// @param keys Keys for objects
/// @param handler Completion handler
- (void)downloadObjectsForKeys:(NSArray *)keys completionHandler:(void (^)(NSError *error, NSArray <id <ACCacheObject>> *download))handler;


@end
