//
//  ACTileCollectionChanges.m
//  HKU Campus
//
//  Created by Wenzhi WU on 6/9/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import "ACTileCollectionChanges.h"

@implementation ACTileCollectionChanges

- (instancetype)initWithEntered:(NSArray<NSString *> *)entered exited:(NSArray<NSString *> *)exited remained:(NSArray<NSString *> *)remained {
    self = [super init];
    if (self) {
        _entered = entered;
        _exited = exited;
        _remained = remained;
    }
    return self;
}

@end
