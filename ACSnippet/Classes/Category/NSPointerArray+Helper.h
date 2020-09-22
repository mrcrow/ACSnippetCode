//
//  NSPointerArray+Helper.h
//  IndoorPositioning
//
//  Created by Wenzhi WU on 29/6/18.
//  Copyright © 2018年 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPointerArray (Helper)

- (BOOL)containsObject:(id)object;
- (void)removeObject:(id)object;
- (void)quickCompact;

@end
