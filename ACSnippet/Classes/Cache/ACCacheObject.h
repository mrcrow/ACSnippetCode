//
//  ACCacheObject.h
//  FMDBTest
//
//  Created by Wenzhi WU on 24/5/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>

/// ACCacheManager cache object protocol, extense 'NSCoding' for version control
@protocol ACCacheObject <NSCoding>

/// Object ID to cache object
- (NSString *)objectID;

/// Object version for comparision
- (NSString *)objectVersion;


@end
