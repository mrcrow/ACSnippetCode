//
//  ACKeyCounter.m
//  BuildingLayerTest
//
//  Created by Wenzhi WU on 15/9/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import "ACKeyCounter.h"
#import "ACCounterItem.h"

@interface ACKeyCounter ()
@property (nonatomic, copy) NSString    *type;
@property (nonatomic, strong)   NSMutableArray <ACCounterItem *> *keyItems;
@end

@implementation ACKeyCounter

- (instancetype)initWithType:(NSString *)type {
    self = [super init];
    if (self) {
        _type = type;
        _keyItems = @[].mutableCopy;
    }
    
    return self;
}

- (void)addKey:(NSString *)key withStyleLayers:(NSArray<MGLStyleLayer *> *)layers {
    NSMutableArray *mutable = @[].mutableCopy;
    for (MGLStyleLayer *layer in layers) {
        [mutable addObject:layer.identifier];
    }
    
    ACCounterItem *item = [[ACCounterItem alloc] initWithKey:key styleLayerIdentifiers:mutable.copy];
    [_keyItems addObject:item];
}

- (void)removeKey:(NSString *)key {
    NSArray *result = [_keyItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key == %@", key]];
    if (![result count]) return;
    
    ACCounterItem *item = result.firstObject;
    [_keyItems removeObject:item];
}

- (NSArray <NSString *> *)layerIdentifiersForKey:(NSString *)key {
    NSArray <ACCounterItem *> *result = [_keyItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key == %@", key]];
    if (![result count]) return nil;
    
    ACCounterItem *item = result.firstObject;
    return item.layerIdentifiers;
}

#pragma mark - ACStyleLayerCounter
- (BOOL)isEmpty {
    return [_keyItems count] == 0;
}

- (NSString *)lastLayerIdentifier {
    if (![_keyItems count]) return nil;
    
    ACCounterItem *item = [_keyItems lastObject];
    return item.layerIdentifiers.lastObject;
}

- (NSString *)counterType {
    return _type;
}

@end
