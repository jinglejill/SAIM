//
//  LazadaOrder.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 18/5/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LazadaOrder : NSObject
@property (nonatomic) NSInteger pendingOrderCount;
@property (nonatomic) NSInteger pendingReturnToShipCount;
@end

NS_ASSUME_NONNULL_END
