//
//  ACTileManager.m
//  TilesnameTest
//
//  Created by Wenzhi WU on 23/6/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import "ACTileManager.h"
#import "ACMercatorProjector.h"

@interface ACTileManager ()

/// Mercator projector for point converting
@property (nonatomic, strong)   ACMercatorProjector *projector;

@end


@implementation ACTileManager

+ (instancetype)sharedManager {
    static ACTileManager *generator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        generator = [[ACTileManager alloc] initWithHightDPITileImages:NO];
    });
    
    return generator;
}

- (instancetype)init {
    return [self initWithHightDPITileImages:NO];
}

- (instancetype)initWithHightDPITileImages:(BOOL)high {
    self = [super init];
    if (self) {
        NSUInteger tileSize = high ? 512 : 256;
        _projector = [[ACMercatorProjector alloc] initWithTileSize:tileSize];
    }
    return self;
}

- (CGPoint)coordinateToMeters:(CLLocationCoordinate2D)coordinate {
    return [_projector coordinateToMeters:coordinate];
}

- (CLLocationCoordinate2D)metersToCoordinate:(CGPoint)meters {
    return [_projector metersToCoordinate:meters];
}

- (NSString *)tileCodeWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate {
    CGPoint tileXY = [_projector tileXYWithZoom:zoom atCoordinate:coordinate];
    return [_projector tileCodeWithZoom:zoom x:tileXY.x y:tileXY.y];
}

- (ACTileRegion *)tileWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate {
    return [_projector tileWithZoom:zoom atCoordinate:coordinate];
}

- (ACTileRegion *)tileWithTileCode:(NSString *)tileCode {
    NSArray *components = [tileCode componentsSeparatedByString:@"/"];
    if ([components count] < 3) {
        NSLog(@"ACTileManager: Invalid tile code %@", tileCode);
        return nil;
    }
    
    NSUInteger x = [components[0] integerValue];
    NSUInteger y = [components[1] integerValue];
    NSUInteger zoom = [components[2] integerValue];
    return [_projector tileWithZoom:zoom x:x y:y];
}

- (NSString *)tileCodeWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y {
    return [_projector tileCodeWithZoom:zoom x:x y:y];
}

- (ACTileRegion *)tileWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y {
    return [_projector tileWithZoom:zoom x:x y:y];
}

- (ACTileCollection *)tileCollectionWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate withDimension:(NSUInteger)dimension {
    ACTileCollectionRange range = [self tileCollectionRangeWithZoom:zoom atCoordinate:coordinate withDimension:dimension];
    return [self tileCollectionWithRange:range];
}

- (ACTileCollectionRange)tileCollectionRangeWithZoom:(NSUInteger)zoom atCoordinate:(CLLocationCoordinate2D)coordinate withDimension:(NSUInteger)dimension {
    CGPoint tileXY = [_projector tileXYWithZoom:zoom atCoordinate:coordinate];
    NSUInteger length = (dimension - 1) / 2;
    NSUInteger xOrigin = tileXY.x - length;
    NSUInteger xMax = xOrigin + dimension - 1;
    
    NSUInteger yOrigin = tileXY.y - length;
    NSUInteger yMax = yOrigin + dimension - 1;
    
    NSRange availableRange = [_projector tileYRangeInZoom:zoom];
    if (yOrigin < availableRange.location)  yOrigin = 0;
    if (yMax > NSMaxRange(availableRange))  yMax = NSMaxRange(availableRange);
    
    NSRange rangeX = NSMakeRange(xOrigin, xMax - xOrigin);
    NSRange rangeY = NSMakeRange(yOrigin, yMax - yOrigin);
    return ACTileCollectionRangeMake(zoom, rangeX, rangeY);
}

- (ACTileCollectionRange)tileCollectionRangeWithZoom:(NSUInteger)zoom fromCoordinate:(CLLocationCoordinate2D)from toCoordinates:(CLLocationCoordinate2D)to {
    CGPoint fromXY = [_projector tileXYWithZoom:zoom atCoordinate:from];
    CGPoint toXY = [_projector tileXYWithZoom:zoom atCoordinate:to];
    
    NSUInteger fromX = MIN(fromXY.x, toXY.x);
    NSUInteger toX = MAX(fromXY.x, toXY.x);
    NSUInteger fromY = MIN(fromXY.y, toXY.y);
    NSUInteger toY = MAX(fromXY.y, toXY.y);
    
    NSRange rangeX = NSMakeRange(fromX, toX - fromX);
    NSRange rangeY = NSMakeRange(fromY, toY - fromY);
    return ACTileCollectionRangeMake(zoom, rangeX, rangeY);
}

- (ACTileCollection *)tileCollectionWithRange:(ACTileCollectionRange)range {
    NSMutableArray *tileCodes = @[].mutableCopy;
    for (NSUInteger x = range.xRange.location; x <= NSMaxRange(range.xRange); x++) {
        for (NSUInteger y = range.yRange.location; y <= NSMaxRange(range.yRange); y++) {
            NSString *tile = [_projector tileCodeWithZoom:range.zoom x:x y:y];
            [tileCodes addObject:tile];
        }
    }
    
    return [[ACTileCollection alloc] initWithRange:range tileCodes:tileCodes.copy];
}

- (NSArray <ACTileRegion *>*)tilesFrom:(CGPoint)fromXY to:(CGPoint)toXY withZoom:(NSUInteger)zoom {
    NSMutableArray *mutable = @[].mutableCopy;
    NSUInteger fromX = MIN(fromXY.x, toXY.x);
    NSUInteger toX = MAX(fromXY.x, toXY.x);
    NSUInteger fromY = MIN(fromXY.y, toXY.y);
    NSUInteger toY = MAX(fromXY.y, toXY.y);
    for (NSUInteger x = fromX; x <= toX; x++) {
        for (NSUInteger y = fromY; y <= toY; y++) {
            ACTileRegion *tile = [self tileWithZoom:zoom x:x y:y];
            if (tile) {
                [mutable addObject:tile];
            }
        }
    }
    
    return mutable.copy;
}

@end
