//
//  ACStyleLayerCounter.h
//  BuildingLayerTest
//
//  Created by Wenzhi WU on 15/9/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ACStyleLayerCounter <NSObject>

- (BOOL)isEmpty;
- (NSString *)counterType;
- (NSString *)lastLayerIdentifier;

@end

NS_ASSUME_NONNULL_END
