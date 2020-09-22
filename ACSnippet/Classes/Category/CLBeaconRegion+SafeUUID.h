//
//  CLBeaconRegion+SafeUUID.h
//  MapboxTransform
//
//  Created by Wenzhi WU on 15/2/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLBeaconRegion (SafeUUID)

- (NSUUID *)safeUUID;
- (NSString *)safeUUIDString;

@end

NS_ASSUME_NONNULL_END
