//
//  ACTileRegion.h
//  TilesnameTest
//
//  Created by Wenzhi WU on 23/6/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>


NS_ASSUME_NONNULL_BEGIN


/// A structure that contains map tile basic info
/// Basically, tiles normally are 256 x 256 pixel size image
/// Origin is the north-west point from the map
///
/// Fields:
///    pixelSize:
///        Tile pixel size, normally 256
///    zoom:
///        The zoom level of tile
///    x:
///        The column number
///    y:
///        The row number
struct ACTileData {
    NSInteger   pixelSize;
    NSInteger   zoom;
    NSInteger   x;
    NSInteger   y;
};
typedef struct ACTileData ACTileData;


/// Designate initliazer for ACTileData struct
/// @param size Tile pixel size
/// @param zoom Zoom level
/// @param x Tile x index
/// @param y Tile y index
ACTileData ACTileDataMake(NSInteger size, NSInteger zoom, NSInteger x, NSInteger y);
    
/// Compare ACTileData structs equality
/// @param lh Left hand side tile data
/// @param rh Right hand side tile data
BOOL ACTileDataIsEqualsTo(ACTileData lh, ACTileData rh);

/// A structure that contains tile bounding corner coordinates
///
/// Fields:
///    northEast:
///        Box north east coordinate
///    northWest:
///        Box north west coordinate
///    southEast:
///        Box south east coordinate
///    southWest:
///        Box south west coordinate
struct ACTileBoundingBox {
    CLLocationCoordinate2D  northEast;
    CLLocationCoordinate2D  northWest;
    CLLocationCoordinate2D  southEast;
    CLLocationCoordinate2D  southWest;
};
typedef struct ACTileBoundingBox ACTileBoundingBox;

/// Designate initializer for ACTileBoundingBox struct
/// @param northWest North west coordinate
/// @param northEast North east coordinate
/// @param southEast South east coordinate
/// @param southWest South west coordinate
ACTileBoundingBox ACTileBoundingBoxMake(CLLocationCoordinate2D northWest,
                                        CLLocationCoordinate2D northEast,
                                        CLLocationCoordinate2D southEast,
                                        CLLocationCoordinate2D southWest);

/// Return a invalid bounding box
ACTileBoundingBox ACTileBoundingBoxInvalid(void);


@interface ACTileRegion : NSObject <NSCopying>


/// Tile code for region under Google schema
@property (nonatomic, copy) NSString    *tileCode;

/// ACTileRegion tile info, contains x, y, zoom and size
@property (nonatomic, assign)   ACTileData  data;

/// ACTileRegion bounding info, contains four corner's coordinate
@property (nonatomic, assign)   ACTileBoundingBox   bounding;


/// Designate initializer for ACTileRegion object
///  @param size Tile pixel size
///  @param zoom ZZoom level
///  @param x Coloum index
///  @param y Row index
///  @param code Formatted tile code
///  @param box Bounding box
- (instancetype)initWithTilePixelSize:(NSInteger)size
                                 zoom:(NSInteger)zoom
                                    x:(NSInteger)x
                                    y:(NSInteger)y
                             tileCode:(NSString *)code
                          boundingBox:(ACTileBoundingBox)box;

@end

NS_ASSUME_NONNULL_END
