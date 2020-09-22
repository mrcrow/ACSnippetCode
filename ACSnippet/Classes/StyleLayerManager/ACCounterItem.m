//
//  ACCounterItem.m
//  BuildingLayerTest
//
//  Created by Wenzhi WU on 16/9/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import "ACCounterItem.h"

@implementation ACCounterItem

- (instancetype)initWithKey:(NSString *)key styleLayerIdentifiers:(NSArray<NSString *> *)layerIDs {
    self = [super init];
    if (self) {
        _key = key;
        _layerIdentifiers = layerIDs;
    }
    
    return self;
}

@end
