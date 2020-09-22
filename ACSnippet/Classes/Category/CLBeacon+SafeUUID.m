//
//  CLBeacon+SafeUUID.m
//  BeaconLocationMonitor
//
//  Created by Wenzhi WU on 23/12/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import "CLBeacon+SafeUUID.h"

@implementation CLBeacon (SafeUUID)

- (NSUUID *)safeUUID {
    if (@available(iOS 13.0, *)) {
        return self.UUID;
    }
    
    return self.proximityUUID;
}

- (NSString *)safeUUIDString {
    return self.safeUUID.UUIDString;
}

@end
