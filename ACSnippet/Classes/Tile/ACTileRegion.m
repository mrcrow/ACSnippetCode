//
//  ACTileRegion.m
//  TilesnameTest
//
//  Created by Wenzhi WU on 23/6/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import "ACTileRegion.h"


ACTileData ACTileDataMake(NSInteger size, NSInteger zoom, NSInteger x, NSInteger y) {
    ACTileData data;
    data.pixelSize = size;
    data.zoom = zoom;
    data.x = x;
    data.y = y;
    return data;
}

BOOL ACTileDataIsEqualsTo(ACTileData lh, ACTileData rh) {
    return lh.pixelSize == rh.pixelSize && lh.zoom == rh.zoom && lh.x == rh.x && lh.y == rh.y;
}

ACTileBoundingBox ACTileBoundingBoxMake(CLLocationCoordinate2D northWest,
                                        CLLocationCoordinate2D northEast,
                                        CLLocationCoordinate2D southEast,
                                        CLLocationCoordinate2D southWest) {
    ACTileBoundingBox box;
    box.northWest = northWest;
    box.northEast = northEast;
    box.southEast = southEast;
    box.southWest = southWest;
    return box;
}

ACTileBoundingBox ACTileBoundingBoxInvalid(void) {
    return ACTileBoundingBoxMake(kCLLocationCoordinate2DInvalid,
                                 kCLLocationCoordinate2DInvalid,
                                 kCLLocationCoordinate2DInvalid,
                                 kCLLocationCoordinate2DInvalid);
}

@implementation ACTileRegion

- (instancetype)init {
    NSLog(@"Please use \"initWithTilePixelSize:zoom:x:y:\" to create ACTileRegion object");
    return nil;
}

- (instancetype)initWithTilePixelSize:(NSInteger)size zoom:(NSInteger)zoom x:(NSInteger)x y:(NSInteger)y tileCode:(NSString *)code boundingBox:(ACTileBoundingBox)box {
    NSAssert(size > 0 && zoom >= 0 && x >= 0 && y >= 0 && [code length], @"zoom/x/y should both greater or equals to 0");
    self = [super init];
    if (self) {
        _data = ACTileDataMake(size, zoom, x, y);
        _bounding = box;
        _tileCode = code;
    }
    return self;
}

/// Initializer used only for copy
/// @param data Tile data
/// @param bounding Tile bounding box
/// @param code Tile code
- (instancetype)initWithTileData:(ACTileData)data boundingBox:(ACTileBoundingBox)bounding code:(NSString *)code {
    self = [super init];
    if (self) {
        _data = data;
        _bounding = bounding;
        _tileCode = code;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Tile: %@[%@]\nBounding:\n\tNW: (%6f, %6f)\n\tSW: (%6f, %6f)\n\tNE: (%6f, %6f)\n\tSE: (%6f, %6f)",
            _tileCode,
            @(_data.pixelSize),
            _bounding.northWest.latitude, _bounding.northWest.longitude,
            _bounding.southWest.latitude, _bounding.southWest.longitude,
            _bounding.northEast.latitude, _bounding.northEast.longitude,
            _bounding.southEast.latitude, _bounding.southEast.longitude];
}

#pragma mark - Equality
- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[ACTileRegion class]])   return NO;
    return [self isEqualsToTile:(ACTileRegion *)object];
}

- (BOOL)isEqualsToTile:(ACTileRegion *)tile {
    if (!tile) return NO;
    return ACTileDataIsEqualsTo(_data, tile.data);
}

- (NSUInteger)hash {
    NSUInteger pixelHash = [@(_data.pixelSize) hash];
    NSUInteger zoomHash = [@(_data.zoom) hash];
    NSUInteger xHash = [@(_data.x) hash];
    NSUInteger yHash = [@(_data.y) hash];
    return pixelHash ^ zoomHash ^ xHash ^ yHash;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    return [[ACTileRegion allocWithZone:zone] initWithTileData:_data
                                                   boundingBox:_bounding
                                                          code:_tileCode];
}

@end
