//
//  ACSourceCounter.m
//  BuildingLayerTest
//
//  Created by Wenzhi WU on 31/8/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import "ACSourceCounter.h"
#import "ACCounterItem.h"

@interface ACSourceCounter ()
@property (nonatomic, copy) NSString    *type;
@property (nonatomic, strong)   NSMutableArray <ACCounterItem *> *sourceItems;
@end

@implementation ACSourceCounter

- (instancetype)initWithType:(NSString *)type {
    self = [super init];
    if (self) {
        _type = type;
        _sourceItems = @[].mutableCopy;
    }
    
    return self;
}

+ (instancetype)counterWithType:(NSString *)type styleLayer:(MGLStyleLayer *)layer {
    ACSourceCounter *counter = [[ACSourceCounter alloc] initWithType:type];
    [counter addSource:nil withStyleLayers:@[layer]];
    return counter;
}

- (void)addSource:(MGLSource *)source withStyleLayers:(nonnull NSArray<MGLStyleLayer *> *)layers {
    NSMutableArray *mutable = @[].mutableCopy;
    for (MGLStyleLayer *layer in layers) {
        [mutable addObject:layer.identifier];
    }
    
    ACCounterItem *item = [[ACCounterItem alloc] initWithKey:source.identifier styleLayerIdentifiers:mutable.copy];
    [_sourceItems addObject:item];
}

- (void)removeSource:(MGLSource *)source {
    NSArray *result = [_sourceItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key == %@", source.identifier]];
    if (![result count]) return;
    
    ACCounterItem *item = result.firstObject;
    [_sourceItems removeObject:item];
}

- (NSArray <NSString *> *)layerIdentifiersForSource:(MGLSource *)source {
    NSArray <ACCounterItem *> *result = [_sourceItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key == %@", source.identifier]];
    if (![result count]) return nil;
    
    ACCounterItem *item = result.firstObject;
    return item.layerIdentifiers;
}

#pragma mark - ACStyleLayerCounter
- (BOOL)isEmpty {
    return [_sourceItems count] == 0;
}

- (NSString *)lastLayerIdentifier {
    if (![_sourceItems count]) return nil;
    
    ACCounterItem *item = [_sourceItems lastObject];
    return item.layerIdentifiers.lastObject;
}

- (NSString *)counterType {
    return _type;
}

@end
