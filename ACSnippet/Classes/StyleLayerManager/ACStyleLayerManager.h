//
//  ACStyleLayerManager.h
//  BuildingLayerTest
//
//  Created by Wenzhi WU on 31/8/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapbox/Mapbox.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ACStyleLayerTypeMapViewBaseLayer;
extern NSString *const ACStyleLayerTypeBackgroundLayer;
extern NSString *const ACStyleLayerTypeBuildingOutlineLayer;
extern NSString *const ACStyleLayerTypeBuildingFloorPlanBaseLayer;
extern NSString *const ACStyleLayerTypeBuildingAbstractionRegionLayer;
extern NSString *const ACStyleLayerTypeBuildingAbstractionLabelLayer;
extern NSString *const ACStyleLayerTypeBuildingFloorPlanPatternLayer;
extern NSString *const ACStyleLayerTypeBuildingFloorPlanLineLayer;
extern NSString *const ACStyleLayerTypeBuildingFloorPlanPointLayer;
extern NSString *const ACStyleLayerTypeBuildingFloorPlanStructureLayer;
extern NSString *const ACStyleLayerTypeBuildingFloorPlanPOILayer;
extern NSString *const ACStyleLayerTypeNavigationRoadsLayer;
extern NSString *const ACStyleLayerTypeNavigationWaypointsLayer;
extern NSString *const ACStyleLayerTypeNavigationInstructionsLayer;
extern NSString *const ACStyleLayerTypeOutdoorPOILayer;

@interface ACStyleLayerManager : NSObject

@property (nonatomic, assign, readonly) BOOL    readyForLayerManagement;

+ (instancetype)sharedManager;
- (void)addToMapView:(MGLMapView *)mapView withBaseLayer:(MGLStyleLayer *)styleLayer;
- (void)registerLayerType:(NSString *)type aboveLayerType:(NSString *)above;
- (void)registerLayerType:(NSString *)type belowLayerType:(NSString *)below;
- (void)addSource:(MGLSource *)source withStyleLayers:(NSArray <MGLStyleLayer *> *)layers ofType:(NSString *)type;
- (void)addKey:(NSString *)key withStyleLayers:(NSArray <MGLStyleLayer *> *)layers  ofType:(NSString *)type;
- (void)removeSource:(MGLSource *)source ofType:(NSString *)type;
- (void)removeKey:(NSString *)key ofType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
