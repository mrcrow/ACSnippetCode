//
//  ACMercatorProjector.h
//  TilesnameTest
//
//  Created by Wenzhi WU on 23/6/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "ACTileRegion.h"


NS_ASSUME_NONNULL_BEGIN

@interface ACMercatorProjector : NSObject


/// Designate initliazer for ACMercatorProjector object
/// @param size Tile resolution in pixel
- (instancetype)initWithTileSize:(NSUInteger)size;

/// Convert coordinate in WGS84 Datum to Spherical Mercator EPSG:900913 xy point in meters
/// @param coordinate Location coordinate
- (CGPoint)coordinateToMeters:(CLLocationCoordinate2D)coordinate;

/// Converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum
/// @param meters XY point in meters
- (CLLocationCoordinate2D)metersToCoordinate:(CGPoint)meters;

/// Retrieve tile region from coordinate in zoom level
/// @param zoom Zoom level
/// @param coordinate Location coordinate
- (ACTileRegion *)tileWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate;

/// Get tile x/y with zoom level and location coordinate
/// @param zoom Zoom level
/// @param coordinate Location coordinate
- (CGPoint)tileXYWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate;

/// Get tile formatted code zoom/x/y with zoom, x, y input
/// @param zoom Zoom level
/// @param x Tile in x index
/// @param y Tile in y index
- (NSString *)tileCodeWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y;

/// Retrieve tile region with zoom, x, y input
/// @param zoom Zoom level
/// @param x Tile in x index
/// @param y Tile in y index
- (ACTileRegion *)tileWithZoom:(NSUInteger)zoom x:(NSInteger)x y:(NSUInteger)y;

/// Get validate range for Y value in zoom level
/// @param zoom Zoom level
- (NSRange)tileYRangeInZoom:(NSUInteger)zoom;


@end

NS_ASSUME_NONNULL_END
