//
//  NSString+HexColor.h
//  MapboxTransform
//
//  Created by Wenzhi WU on 9/3/2020.
//  Copyright © 2020 Wenzhi WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HexColor)

- (UIColor *)hexColor;

@end

NS_ASSUME_NONNULL_END
