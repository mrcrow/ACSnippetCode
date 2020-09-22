//
//  CLBeacon+SafeUUID.h
//  BeaconLocationMonitor
//
//  Created by Wenzhi WU on 23/12/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLBeacon (SafeUUID)

- (NSUUID *)safeUUID;
- (NSString *)safeUUIDString;

@end

NS_ASSUME_NONNULL_END
