//
//  DeleteReason.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/2/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeleteReason : NSObject
@property (nonatomic) NSInteger code;
@property (nonatomic) NSString *reason;
@property (nonatomic) NSInteger receiptID;
@property (nonatomic) NSInteger receiptProductItemID;

+(NSArray *)getDeleteReasonList;
@end

NS_ASSUME_NONNULL_END
