//
//  ACKeyCounter.h
//  BuildingLayerTest
//
//  Created by Wenzhi WU on 15/9/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapbox/Mapbox.h>
#import "ACStyleLayerCounter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACKeyCounter : NSObject <ACStyleLayerCounter>

/// Designate initializer for ACKeyCounter object
/// @param type Layer type
- (instancetype)initWithType:(NSString *)type;

/// Add style layers with key
/// @param key Reference key
/// @param layers Style layers
- (void)addKey:(NSString *)key withStyleLayers:(NSArray <MGLStyleLayer *> *)layers;

/// Remove style layers with key from counter
/// @param key Reference key
- (void)removeKey:(NSString *)key;

/// Get style layer identifiers for key
/// @param key Reference key
- (NSArray <NSString *> *)layerIdentifiersForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
