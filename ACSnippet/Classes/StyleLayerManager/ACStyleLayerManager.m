//
//  ACStyleLayerManager.m
//  BuildingLayerTest
//
//  Created by Wenzhi WU on 31/8/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import "ACStyleLayerManager.h"
#import "ACSourceCounter.h"
#import "ACKeyCounter.h"

NSString *const ACStyleLayerTypeMapViewBaseLayer = @"com.aicity.layer.map.base";
NSString *const ACStyleLayerTypeBackgroundLayer = @"com.aicity.layer.background";
NSString *const ACStyleLayerTypeBuildingOutlineLayer = @"com.aicity.layer.building.outline";
NSString *const ACStyleLayerTypeBuildingFloorPlanBaseLayer = @"com.aicity.layer.building.floor.base";
NSString *const ACStyleLayerTypeBuildingAbstractionRegionLayer = @"com.aicity.layer.building.floor.abstraction.region";
NSString *const ACStyleLayerTypeBuildingAbstractionLabelLayer = @"com.aicity.layer.building.floor.abstraction.label";
NSString *const ACStyleLayerTypeBuildingFloorPlanPatternLayer = @"com.aicity.layer.building.floor.pattern";
NSString *const ACStyleLayerTypeBuildingFloorPlanLineLayer = @"com.aicity.layer.building.floor.line";
NSString *const ACStyleLayerTypeBuildingFloorPlanPointLayer = @"com.aicity.layer.building.floor.point";
NSString *const ACStyleLayerTypeBuildingFloorPlanStructureLayer = @"com.aicity.layer.building.floor.structure";
NSString *const ACStyleLayerTypeBuildingFloorPlanPOILayer = @"com.aicity.layer.building.floor.poi";;
NSString *const ACStyleLayerTypeNavigationRoadsLayer = @"com.aicity.layer.navigation.roads";
NSString *const ACStyleLayerTypeNavigationWaypointsLayer = @"com.aicity.layer.navigation.waypoints";
NSString *const ACStyleLayerTypeNavigationInstructionsLayer = @"com.aicity.layer.navigation.instructions";
NSString *const ACStyleLayerTypeOutdoorPOILayer = @"com.aicity.layer.outdoor.poi";

@interface ACStyleLayerManager ()
@property (nonatomic, weak) MGLMapView  *mapView;
@property (nonatomic, strong)   NSMutableArray  *styleTypes;
@property (nonatomic, strong)   NSMutableDictionary <NSString *, id <ACStyleLayerCounter>> *counterMap;
@end

@implementation ACStyleLayerManager

+ (instancetype)sharedManager {
    static ACStyleLayerManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [ACStyleLayerManager new];
    });
    
    return _manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _styleTypes = @[ACStyleLayerTypeMapViewBaseLayer,
                        ACStyleLayerTypeBackgroundLayer,
                        ACStyleLayerTypeBuildingFloorPlanBaseLayer,
                        ACStyleLayerTypeBuildingAbstractionRegionLayer,
                        ACStyleLayerTypeBuildingAbstractionLabelLayer,
                        ACStyleLayerTypeBuildingFloorPlanPatternLayer,
                        ACStyleLayerTypeBuildingFloorPlanLineLayer,
                        ACStyleLayerTypeNavigationRoadsLayer,
                        ACStyleLayerTypeNavigationInstructionsLayer,
                        ACStyleLayerTypeBuildingFloorPlanStructureLayer,
                        ACStyleLayerTypeNavigationWaypointsLayer,
                        ACStyleLayerTypeBuildingFloorPlanPointLayer,
                        ACStyleLayerTypeBuildingFloorPlanPOILayer,
                        ACStyleLayerTypeBuildingOutlineLayer,
                        ACStyleLayerTypeOutdoorPOILayer].mutableCopy;
        _counterMap = @{}.mutableCopy;
    }
    
    return self;
}

- (void)addToMapView:(MGLMapView *)mapView withBaseLayer:(nonnull MGLStyleLayer *)styleLayer {
    if (_mapView) return;
    
    _mapView = mapView;
    _readyForLayerManagement = YES;
    ACKeyCounter *counter = [[ACKeyCounter alloc] initWithType:ACStyleLayerTypeMapViewBaseLayer];
    [counter addKey:@"default" withStyleLayers:@[styleLayer]];
    [_counterMap setObject:counter forKey:ACStyleLayerTypeMapViewBaseLayer];
}

- (void)registerLayerType:(NSString *)type aboveLayerType:(NSString *)above {
    if (![_styleTypes containsObject:above]) {
        NSLog(@"ACStyleLayerManager failed to add %@ above %@, %@ not exist", type, above, above);
        return;
    }
    
    if ([_styleTypes containsObject:type]) {
        NSLog(@"ACStyleLayerManager failed to add %@ above %@, %@ already exists", type, above, type);
        return;
    }
    
    NSInteger index = [_styleTypes indexOfObject:above];
    if (index + 1 >= [_styleTypes count]) {
        [_styleTypes addObject:type];
    } else {
        [_styleTypes insertObject:type atIndex:index + 1];
    }
}

- (void)registerLayerType:(NSString *)type belowLayerType:(NSString *)below {
    if (![_styleTypes containsObject:below]) {
        NSLog(@"ACStyleLayerManager failed to add %@ below %@, %@ not exist", type, below, below);
        return;
    }
    
    if ([_styleTypes containsObject:type]) {
        NSLog(@"ACStyleLayerManager failed to add %@ below %@, %@ already exists", type, below, type);
        return;
    }
    
    NSInteger index = [_styleTypes indexOfObject:below];
    [_styleTypes insertObject:type atIndex:index];
}

- (void)addSource:(MGLSource *)source withStyleLayers:(NSArray<MGLStyleLayer *> *)layers ofType:(NSString *)type {
    ACSourceCounter *counter = _counterMap[type];
    if (!counter) {
        counter = [[ACSourceCounter alloc] initWithType:type];
        [_counterMap setObject:counter forKey:type];
    }

    if (counter.lastLayerIdentifier) {
        MGLStyleLayer *aboveLayer = [_mapView.style layerWithIdentifier:counter.lastLayerIdentifier];
        [_mapView.style addSource:source];
        
        for (MGLStyleLayer *layer in layers) {
            [_mapView.style insertLayer:layer aboveLayer:aboveLayer];
            aboveLayer = layer;
        }
        
        [counter addSource:source withStyleLayers:layers];
    } else {
        ACSourceCounter *target = [self lowerCounterForInsertingLayerType:type];
        if (!target) {
            NSLog(@"ACStyleLayerManager lack of first counter");
        } else {
            MGLStyleLayer *aboveLayer = [_mapView.style layerWithIdentifier:target.lastLayerIdentifier];
            [_mapView.style addSource:source];
            
            for (MGLStyleLayer *layer in layers) {
                [_mapView.style insertLayer:layer aboveLayer:aboveLayer];
                aboveLayer = layer;
            }
            
            [counter addSource:source withStyleLayers:layers];
        }
    }
}

- (void)addKey:(NSString *)key withStyleLayers:(NSArray<MGLStyleLayer *> *)layers ofType:(NSString *)type {
    ACKeyCounter *counter = _counterMap[type];
    if (!counter) {
        counter = [[ACKeyCounter alloc] initWithType:type];
        [_counterMap setObject:counter forKey:type];
    }

    if (counter.lastLayerIdentifier) {
        MGLStyleLayer *aboveLayer = [_mapView.style layerWithIdentifier:counter.lastLayerIdentifier];
        
        for (MGLStyleLayer *layer in layers) {
            [_mapView.style insertLayer:layer aboveLayer:aboveLayer];
            aboveLayer = layer;
        }
        
        [counter addKey:key withStyleLayers:layers];
    } else {
        id <ACStyleLayerCounter> target = [self lowerCounterForInsertingLayerType:type];
        if (!target) {
            NSLog(@"ACStyleLayerManager lack of first counter");
        } else {
            MGLStyleLayer *aboveLayer = [_mapView.style layerWithIdentifier:target.lastLayerIdentifier];
            
            for (MGLStyleLayer *layer in layers) {
                [_mapView.style insertLayer:layer aboveLayer:aboveLayer];
                aboveLayer = layer;
            }
            
            [counter addKey:key withStyleLayers:layers];
        }
    }
}

- (void)removeSource:(MGLSource *)source ofType:(NSString *)type {
    ACSourceCounter *counter = _counterMap[type];
    if (!counter) {
        NSLog(@"ACStyleLayerManager counter not found for type: %@", type);
        return;
    }
    
    NSArray <NSString *> *layerIDs = [counter layerIdentifiersForSource:source];
    if ([layerIDs count]) {
        for (NSString *identifier in layerIDs) {
            MGLStyleLayer *layer = [_mapView.style layerWithIdentifier:identifier];
            if (layer) {
                [_mapView.style removeLayer:layer];
            }
        }
        
        [_mapView.style removeSource:source];
    }
    
    [counter removeSource:source];
}

- (void)removeKey:(NSString *)key ofType:(NSString *)type {
    ACKeyCounter *counter = _counterMap[type];
    if (!counter) {
        NSLog(@"ACStyleLayerManager counter not found for type: %@", type);
        return;
    }
    
    NSArray <NSString *> *layerIDs = [counter layerIdentifiersForKey:key];
    if ([layerIDs count]) {
        for (NSString *identifier in layerIDs) {
            MGLStyleLayer *layer = [_mapView.style layerWithIdentifier:identifier];
            if (layer) {
                [_mapView.style removeLayer:layer];
            }
        }
    }
    
    [counter removeKey:key];
}

- (id <ACStyleLayerCounter>)lowerCounterForInsertingLayerType:(NSString *)type {
    id <ACStyleLayerCounter> result = nil;
    NSInteger index = [_styleTypes indexOfObject:type];
    if (index == NSNotFound) return nil;
    if (index == 0) {
        NSString *target = _styleTypes.firstObject;
        id <ACStyleLayerCounter> counter = _counterMap[target];
        return counter;
    }
    
    for (int i = (int)index - 1; i >= 0; i--) {
        NSString *target = _styleTypes[i];
        id <ACStyleLayerCounter> counter = _counterMap[target];
        if (counter && ![counter isEmpty]) {
            result = counter;
            break;
        }
    }
    
    return result;
}

@end
