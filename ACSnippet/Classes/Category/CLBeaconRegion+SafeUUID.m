//
//  CLBeaconRegion+SafeUUID.m
//  MapboxTransform
//
//  Created by Wenzhi WU on 15/2/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import "CLBeaconRegion+SafeUUID.h"

@implementation CLBeaconRegion (SafeUUID)

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
