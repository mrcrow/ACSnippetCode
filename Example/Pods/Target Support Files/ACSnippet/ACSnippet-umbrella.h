#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ACCache.h"
#import "ACCacheManager.h"
#import "ACCacheManagerDownloader.h"
#import "ACCacheObject.h"
#import "ACLRUCache.h"
#import "CLBeacon+SafeUUID.h"
#import "CLBeaconRegion+SafeUUID.h"
#import "NSPointerArray+Helper.h"
#import "NSString+HexColor.h"
#import "ACMercatorProjector.h"
#import "ACTileCollection.h"
#import "ACTileCollectionChanges.h"
#import "ACTileManager.h"
#import "ACTileRegion.h"

FOUNDATION_EXPORT double ACSnippetVersionNumber;
FOUNDATION_EXPORT const unsigned char ACSnippetVersionString[];

