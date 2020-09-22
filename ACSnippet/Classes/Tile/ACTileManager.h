//
//  ACTileManager.h
//  TilesnameTest
//
//  Created by Wenzhi WU on 23/6/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ACTileRegion.h"
#import "ACTileCollection.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACTileManager : NSObject

/// Get shared instance for ACTilesManager object
+ (instancetype)sharedManager;

/// High DPI tiles are 512 X 512 pixel size tile images, default is 256 x 256 pixel size
/// @param high High dpi tile option
- (instancetype)initWithHightDPITileImages:(BOOL)high;

/// Convert coordinate in WGS84 Datum to Spherical Mercator EPSG:900913 xy point in meters
/// @param coordinate Location coordinate
- (CGPoint)coordinateToMeters:(CLLocationCoordinate2D)coordinate;

/// Converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum
/// @param meters Location coordinate in meters
- (CLLocationCoordinate2D)metersToCoordinate:(CGPoint)meters;

/// Get tile code for coordinate at zoom level
/// @param zoom Zoom level
/// @param coordinate Location coordinate
- (NSString *)tileCodeWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate;
    
/// Get tile under certain zoom level and location coordinate,
/// Tile x, y are calculated under Google schema (not TMS)
/// @param zoom Zoom level
/// @param coordinate Location coordinate
- (ACTileRegion *)tileWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate;

/// Get tile region based on tile code
/// @param tileCode Tile code
- (ACTileRegion *)tileWithTileCode:(NSString *)tileCode;

/// Get tile formatted code zoom/x/y with zoom, x, y input
/// @param zoom Zoom level
/// @param x Tile x index
/// @param y Tile y index
- (NSString *)tileCodeWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y;

/// Retrieve tile region with zoom, x, y input
/// @param zoom Zoom level
/// @param x Tile x index
/// @param y Tile y index
- (ACTileRegion *)tileWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y;

/// Get tiles collection with certain zoom level, location coordinate and dimension
/// @param zoom Zoom level
/// @param coordinate Location coordinate
/// @param dimension Odd number described collection range
- (ACTileCollection *)tileCollectionWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate withDimension:(NSUInteger)dimension;

/// Get tile collection range with certain zoom level, location coordinate and dimension
/// @param zoom Zoom level
/// @param coordinate Location coordinate
/// @param dimension Collection dimension
- (ACTileCollectionRange)tileCollectionRangeWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate withDimension:(NSUInteger)dimension;

/// Get tile collection range with certain zoom level from one coordinate to another
/// @param zoom Zoom level
/// @param from North east coordinate
/// @param to South west coordinate
- (ACTileCollectionRange)tileCollectionRangeWithZoom:(NSUInteger)zoom fromCoordinate:(CLLocationCoordinate2D)from toCoordinates:(CLLocationCoordinate2D)to;

/// Get tile collection with range
/// @param range Collection range
- (ACTileCollection *)tileCollectionWithRange:(ACTileCollectionRange)range;

/// Get tiles from coordinate in meters to another
/// @param fromXY From coordinate in meters
/// @param toXY To coordinate in meters
/// @param zoom Zoom level
- (NSArray <ACTileRegion *>*)tilesFrom:(CGPoint)fromXY to:(CGPoint)toXY withZoom:(NSUInteger)zoom;


@end

NS_ASSUME_NONNULL_END
