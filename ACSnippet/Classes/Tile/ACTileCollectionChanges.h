//
//  ACTileCollectionChanges.h
//  HKU Campus
//
//  Created by Wenzhi WU on 6/9/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACTileRegion.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACTileCollectionChanges : NSObject

/// Entered tile codes in changes
@property (nonatomic, copy) NSArray <NSString *>    *entered;

/// Exited tile codes in changes
@property (nonatomic, copy) NSArray <NSString *>    *exited;

/// Remained tile codes in changes
@property (nonatomic, copy) NSArray <NSString *>    *remained;


/// Designate initializer for ACTileCollectionChanges object
/// @param entered Entered tile codes
/// @param exited Exited tile codes
/// @param remained Remained tile codes
- (instancetype)initWithEntered:(NSArray <NSString *> *)entered
                         exited:(NSArray <NSString *> *)exited
                       remained:(NSArray <NSString *> *)remained;

@end

NS_ASSUME_NONNULL_END
