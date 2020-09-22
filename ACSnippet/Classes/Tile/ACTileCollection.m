//
//  ACTileCollection.m
//  TilesnameTest
//
//  Created by Wenzhi WU on 24/6/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import "ACTileCollection.h"

ACTileCollectionRange  ACTileCollectionRangeMake(NSInteger zoom, NSRange xRange, NSRange yRange) {
    ACTileCollectionRange range;
    range.zoom = zoom;
    range.xRange = xRange;
    range.yRange = yRange;
    return range;
}

BOOL ACTileCollectionRangeIsEqualsTo(ACTileCollectionRange lh, ACTileCollectionRange rh) {
    return lh.zoom == rh.zoom && NSEqualRanges(lh.xRange, rh.xRange) && NSEqualRanges(lh.yRange, rh.yRange);
}

@implementation ACTileCollection

- (instancetype)initWithRange:(ACTileCollectionRange)range tileCodes:(NSArray<NSString *> *)tileCodes {
    self = [super init];
    if (self) {
        _range = range;
        _tileCodes = tileCodes;           
    }
    return self;
}

- (BOOL)containsTileWithTileCode:(NSString *)tileCode {
    return [_tileCodes containsObject:tileCode];
}

- (NSString *(^)(NSInteger, NSInteger))tileCodeAt {
    return ^NSString *(NSInteger x, NSInteger y) {
        NSAssert(x < self.range.xRange.location || x > NSMaxRange(self.range.xRange) || y < self.range.yRange.location || y >= NSMaxRange(self.range.yRange), @"x/y should within range");
        NSInteger column = x - self.range.xRange.location;
        NSInteger row = y - self.range.yRange.location;
        return self.tileCodes[column + row * self.range.xRange.length];
    };
}

- (NSArray <NSString *>*(^)(ACTileCollection *))intersect {
    return ^NSArray <NSString *>*(ACTileCollection *input) {
        NSMutableSet *left = [NSMutableSet setWithArray:self.tileCodes];
        NSSet *right = [NSSet setWithArray:input.tileCodes];
        if (![left intersectsSet:right]) return @[];
        
        [left intersectSet:right];
        return left.allObjects;
    };
}

- (NSArray <NSString *>*(^)(NSArray <NSString *>*))minus {
    return ^NSArray <ACTileRegion *>*(NSArray <ACTileRegion *>* input) {
        NSMutableSet *left = [NSMutableSet setWithArray:self.tileCodes];
        NSSet *right = [NSSet setWithArray:input];
        
        [left minusSet:right];
        return left.allObjects;
    };
}

- (ACTileCollectionChanges *)changesFrom:(ACTileCollection *)from {
    NSArray *entered = nil;
    NSArray *exited = nil;
    NSArray *remained = nil;
    if (!from) {
        entered = self.tileCodes;
    } else {
        NSArray <NSString *> *intersectTileCodes = from.intersect(self);
        if (![intersectTileCodes count]) {
            entered = self.tileCodes;
            exited = from.tileCodes;
        } else {
            exited = from.minus(intersectTileCodes);
            entered = self.minus(intersectTileCodes);
            remained = intersectTileCodes;
        }
    }
    
    return [[ACTileCollectionChanges alloc] initWithEntered:entered exited:exited remained:remained];
}

#pragma mark - Equality
- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[ACTileCollection class]])   return NO;
    return [self isEqualsToTileCollection:(ACTileCollection *)object];
}

- (BOOL)isEqualsToTileCollection:(ACTileCollection *)collection {
    if (!collection) return NO;
    return ACTileCollectionRangeIsEqualsTo(_range, collection.range);
}

- (NSUInteger)hash {
    NSUInteger zoomHash = [@(self.range.zoom) hash];
    NSUInteger xHash = [NSStringFromRange(_range.xRange) hash];
    NSUInteger yHash = [NSStringFromRange(_range.yRange) hash];
    return zoomHash ^ xHash ^ yHash;
}

#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone {
    return [[ACTileCollection allocWithZone:zone] initWithRange:_range
                                                      tileCodes:_tileCodes.copy];
}

@end
