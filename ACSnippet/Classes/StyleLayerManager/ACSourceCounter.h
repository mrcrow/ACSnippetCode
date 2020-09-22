//
//  ACSourceCounter.h
//  BuildingLayerTest
//
//  Created by Wenzhi WU on 31/8/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapbox/Mapbox.h>
#import "ACStyleLayerCounter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACSourceCounter : NSObject <ACStyleLayerCounter>

/// Designate initializer for ACSourceCounter object
/// @param type Layer type
- (instancetype)initWithType:(NSString *)type;

/// Add soure with related style layers
/// @param source MGLSource item
/// @param layers Style layers
- (void)addSource:(nullable MGLSource *)source withStyleLayers:(NSArray <MGLStyleLayer *> *)layers;

/// Remove source from counter
/// @param source Source item
- (void)removeSource:(MGLSource *)source;

/// Get style layer identifiers for source
/// @param source Target source 
- (NSArray <NSString *> *)layerIdentifiersForSource:(MGLSource *)source;


@end

NS_ASSUME_NONNULL_END
