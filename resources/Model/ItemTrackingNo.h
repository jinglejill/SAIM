//
//  ItemTrackingNo.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 17/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ItemTrackingNo : NSObject
@property (nonatomic) NSInteger itemTrackingNoID;
@property (nonatomic) NSInteger receiptProductItemID;
@property (retain, nonatomic) NSString * trackingNo;
@property (nonatomic) NSInteger postCustomerID;
@property (retain, nonatomic) NSString * modifiedDate;
@end

NS_ASSUME_NONNULL_END
