//
//  ACTileCollection.h
//  TilesnameTest
//
//  Created by Wenzhi WU on 24/6/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACTileRegion.h"
#import "ACTileCollectionChanges.h"

NS_ASSUME_NONNULL_BEGIN

/// A structure that contains map tile within x/y ranges
///
/// Fields:
///    zoom:
///        Zoom level
///    xRange:
///        Tile x range
///    yRange:
///        Tile y range
struct ACTileCollectionRange {
    NSInteger zoom;
    NSRange xRange;
    NSRange yRange;
};
typedef struct ACTileCollectionRange ACTileCollectionRange;

/// Designate initializer for ACTilesCollectionRange struct
/// @param zoom Zoom level
/// @param xRange Tile x range
/// @param yRange Tile y range
ACTileCollectionRange ACTileCollectionRangeMake(NSInteger zoom, NSRange xRange, NSRange yRange);

/// Compare ACTilesCollectionRange structs equality
/// @param lh Left hand side collection range
/// @param rh Right hand side collection range
BOOL ACTileCollectionRangeIsEqualsTo(ACTileCollectionRange lh, ACTileCollectionRange rh);


@interface ACTileCollection : NSObject <NSCopying>

/// Range contains x/y ranges
@property (nonatomic, assign)   ACTileCollectionRange   range;

/// Tiles contains with range
@property (nonatomic, copy) NSArray <NSString *>    *tileCodes;


/// Designate initializer for ACTileCollection object
/// @param range Tile x/y range
/// @param tileCodes Tile codes within range
- (instancetype)initWithRange:(ACTileCollectionRange)range tileCodes:(NSArray <NSString *>*)tileCodes;

/// Check if tile with tile code has been included in collection
/// @param tileCode Tile code
- (BOOL)containsTileWithTileCode:(NSString *)tileCode;

/// Get tile at x/y
- (NSString *(^)(NSInteger, NSInteger))tileCodeAt;

/// Get intersection tiles with input tiles collection
- (NSArray <NSString *>*(^)(ACTileCollection *))intersect;

/// Do minus calculation with input tiles
- (NSArray <NSString *>*(^)(NSArray <NSString *>*))minus;

/// Get changes information comparing to collection before
/// @param from Target collection
- (ACTileCollectionChanges *)changesFrom:(ACTileCollection *)from;


@end

NS_ASSUME_NONNULL_END
