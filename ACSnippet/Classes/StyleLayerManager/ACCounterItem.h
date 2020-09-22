//
//  ACCounterItem.h
//  BuildingLayerTest
//
//  Created by Wenzhi WU on 16/9/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACCounterItem : NSObject

/// Item reference key
@property (nonatomic, copy) NSString    *key;

/// Corresponded style layer identifiers
@property (nonatomic, copy) NSArray <NSString *>    *layerIdentifiers;

/// Designnate initializer for ACCounterItem object
/// @param key Reference key
/// @param layerIDs Layer identifiers
- (instancetype)initWithKey:(NSString *)key styleLayerIdentifiers:(NSArray <NSString *> *)layerIDs;


@end

NS_ASSUME_NONNULL_END
