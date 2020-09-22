//
//  ACMercatorProjector.m
//  TilesnameTest
//
//  Created by Wenzhi WU on 23/6/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import "ACMercatorProjector.h"

/// A structure that used to store bounding corners of pixels coordinate or xy coordinate
///
/// Fields:
///   northEast:
///       North east point
///  northWest:
///       North west point
///   southEast:
///       South east point
///   southWest:
///       South west point
struct ACBoundingBox {
    CGPoint northEast;
    CGPoint northWest;
    CGPoint southEast;
    CGPoint southWest;
};
typedef struct ACBoundingBox ACBoundingBox;


@interface ACMercatorProjector ()

/// Tile size of each tile for calculation
@property (nonatomic, assign)   NSUInteger   tileSize;

/// Initial resolution
@property (nonatomic, assign)   CGFloat initialResolution;

/// Original shift value
@property (nonatomic, assign)   CLLocationDistance  originShift;


@end

@implementation ACMercatorProjector

- (instancetype)init {
    return [self initWithTileSize:256];
}

- (instancetype)initWithTileSize:(NSUInteger)size {
    self = [super init];
    if (self) {
        _tileSize = size;
        _initialResolution = 2 * M_PI * 6378137 / (CGFloat)size;
        _originShift = 2 * M_PI * 6378137 / 2.0;
    }
    return self;
}

- (CGPoint)coordinateToMeters:(CLLocationCoordinate2D)coordinate {
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        NSLog(@"ACMercatorProjector[%@]: invalid coordinate", NSStringFromSelector(_cmd));
        return CGPointZero;
    }
    
    CLLocationDistance x = coordinate.longitude * _originShift / 180.0;
    CLLocationDistance y = log(tan((90 + coordinate.latitude) * M_PI / 360.0)) / (M_PI / 180.0);
    y = y * _originShift / 180.0;
    return CGPointMake(x, y);
}

- (CLLocationCoordinate2D)metersToCoordinate:(CGPoint)meters {
    CLLocationDegrees longitude = (meters.x / _originShift) * 180.0;
    CLLocationDegrees latitude = (meters.y / _originShift) * 180.0;
    
    latitude = 180 / M_PI * (2 * atan(exp(latitude * M_PI / 180.0)) - M_PI / 2.0);
    return CLLocationCoordinate2DMake(latitude, longitude);
}

/// Convert XY point from Spherical Mercator EPSG:900913 to pixel coordinate
/// @param meters XY point in meters
/// @param zoom ZZoom level
- (CGPoint)metersToPixels:(CGPoint)meters inZoom:(NSUInteger)zoom {
    CGFloat resolution = [self resolutionInZoom:zoom];
    CGFloat x = (meters.x + _originShift) / resolution;
    CGFloat y = (meters.y + _originShift) / resolution;
    return CGPointMake(x, y);
}

/// Convert pixel coordinate to Spherical Mercator EPSG:900913 xy point
/// @param pixel Coordinate in pixel
/// @param zoom Zoom level
- (CGPoint)pixelToMeters:(CGPoint)pixel inZoom:(NSUInteger)zoom {
    CGFloat resolution = [self resolutionInZoom:zoom];
    CLLocationDistance x = pixel.x * resolution - _originShift;
    CLLocationDistance y = pixel.y * resolution - _originShift;
    return CGPointMake(x, y);
}

/// Convert pixel coordinate to tile x/y
/// @param pixel Coordinate in pixel
- (CGPoint)pixelToTileXY:(CGPoint)pixel {
    NSUInteger x = ceil(pixel.x / (CGFloat)_tileSize) - 1;
    NSUInteger y = ceil(pixel.y / (CGFloat)_tileSize) - 1;
    return CGPointMake(x, y);
}

/// Resolution under zoom level
/// @param zoom Zoom level
- (CGFloat)resolutionInZoom:(NSUInteger)zoom {
    return (2 * M_PI * 6378137) / (_tileSize * pow(2, zoom));
}

/// Pixel coordinate bounding box for tile x/y
/// @param x Tile in x index
/// @param y Tile in y index
- (ACBoundingBox)pixelBoundingBoxWithX:(NSUInteger)x y:(NSUInteger)y {
    ACBoundingBox box;
    box.northWest = CGPointMake(x * _tileSize, y * _tileSize);
    box.northEast = CGPointMake((x + 1) * _tileSize, y * _tileSize);
    box.southWest = CGPointMake(x * _tileSize, (y + 1) * _tileSize);
    box.southEast = CGPointMake((x + 1) * _tileSize, (y + 1) * _tileSize);
    return box;
}

/// Convert bounding box of mercator to tile bounding box with certain zoom level
/// @param zoom Zoom level
/// @param mercator Bounding box in mercator projection
- (ACTileBoundingBox)tileBoundingBoxWithZoom:(NSUInteger)zoom pixelBoundingBox:(ACBoundingBox)mercator {
    ACTileBoundingBox box;
    box.northWest = [self metersToCoordinate:[self pixelToMeters:mercator.northWest inZoom:zoom]];
    box.northEast = [self metersToCoordinate:[self pixelToMeters:mercator.northEast inZoom:zoom]];
    box.southEast = [self metersToCoordinate:[self pixelToMeters:mercator.southEast inZoom:zoom]];
    box.southWest = [self metersToCoordinate:[self pixelToMeters:mercator.southWest inZoom:zoom]];
    return box;
}

- (ACTileBoundingBox)tileBoundBoxWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y {
    ACBoundingBox pixelBounds = [self pixelBoundingBoxWithX:x y:y];
    return [self tileBoundingBoxWithZoom:zoom pixelBoundingBox:pixelBounds];
}

- (CGPoint)tileXYWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate {
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        NSLog(@"ACMercatorProjector[%@]: invalid coordinate input", NSStringFromSelector(_cmd));
        return CGPointMake(-1, -1);
    }
    
    CGPoint meters = [self coordinateToMeters:coordinate];
    CGPoint pixel = [self metersToPixels:meters inZoom:zoom];
    CGPoint tileXY = [self pixelToTileXY:pixel];
    
    // convert TMS y to Google
    tileXY.y = [self convertY:tileXY.y inZoom:zoom];
    return tileXY;
}

- (ACTileRegion *)tileWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate {
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        NSLog(@"ACMercatorProjector[%@]: invalid coordinate input", NSStringFromSelector(_cmd));
        return nil;
    }
    
    CGPoint tileXY = [self tileXYWithZoom:zoom atCoordinate:coordinate];
    return [self tileWithZoom:zoom x:tileXY.x y:tileXY.y];
}

- (NSString *)tileCodeWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y {
    return [NSString stringWithFormat:@"%ld/%ld/%ld", (long)x, (long)y, (long)zoom];
}

- (ACTileRegion *)tileWithZoom:(NSUInteger)zoom x:(NSInteger)x y:(NSUInteger)y {
    if (!ACTileYIsValid(zoom, y)) {
        NSLog(@"ACMercatorProjector[%@]: invalid tile y %@", NSStringFromSelector(_cmd), @(y));
        return nil;
    }
    
    x = ACAvailableTileX(zoom, x);
    NSUInteger yGoogle = y;
    NSUInteger yTMS = [self convertY:yGoogle inZoom:zoom];
    ACTileBoundingBox box = [self tileBoundBoxWithZoom:zoom x:x y:yTMS];
    NSString *tileCode = [self tileCodeWithZoom:zoom x:x y:yGoogle];
    return [[ACTileRegion alloc] initWithTilePixelSize:_tileSize zoom:zoom x:x y:yGoogle tileCode:tileCode boundingBox:box];
}

/// Convert y to Google schema or versus TMS
/// @param y Tile y index in TMS
/// @param zoom Zoom level
- (NSUInteger)convertY:(NSUInteger)y inZoom:(NSUInteger)zoom {
    return pow(2, zoom) - 1 - y;
}

- (NSRange)tileYRangeInZoom:(NSUInteger)zoom {
    return NSMakeRange(0, pow(2, zoom) - 1);
}

/// Return available tile x within range
/// @param zoom Zoom level
/// @param x Tile in x index
NSUInteger ACAvailableTileX(NSUInteger zoom, NSInteger x) {
    NSUInteger max = pow(2, zoom);
    if (x < 0)  return x + max;
    if (x > max) return x - max;
    return x;
}

/// Detect if tile y is invalid
/// @param zoom Zoom level
/// @param y Tile in y index
BOOL ACTileYIsValid(NSUInteger zoom, NSUInteger y) {
    return y >= 0 && y <= (pow(2, zoom) - 1);
}

@end
