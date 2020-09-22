//
//  NSPointerArray+Helper.m
//  IndoorPositioning
//
//  Created by Wenzhi WU on 29/6/18.
//  Copyright © 2018年 Wenzhi WU. All rights reserved.
//

#import "NSPointerArray+Helper.h"

@implementation NSPointerArray (Helper)

- (BOOL)containsObject:(id)object {
    NSArray *array = self.allObjects;
    return [array containsObject:object];
}

- (void)removeObject:(id)object {
    NSInteger index = -1;
    for (int i = 0; i < self.count; i++) {
        void *pointer = [self pointerAtIndex:i];
        if (pointer == (__bridge void*)object) {
            index = i;
            break;
        }
    }
    
    if (index >= 0 && index < [self count]) {
        [self removePointerAtIndex:index];
    }
}

- (void)quickCompact {
    [self addPointer:NULL];
    [self compact];
}

@end
