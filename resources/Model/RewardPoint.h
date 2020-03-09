//
//  RewardPoint.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 11/8/2559 BE.
//  Copyright © 2559 Appxelent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RewardPoint : NSObject
@property (nonatomic) NSInteger rewardPointID;
@property (nonatomic) NSInteger customerID;
@property (nonatomic) NSInteger receiptID;
@property (nonatomic) NSInteger  point;
@property (nonatomic) NSInteger  status;
@property (retain, nonatomic) NSString * modifiedDate;
@property (nonatomic) NSInteger receiptStatus;

@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete


+ (RewardPoint *) getRewardPointReceiveWithReceiptID:(NSInteger)receiptID;
+ (NSInteger) getRewardPointPointWithCustomerID:(NSInteger)customerID;
+ (RewardPoint *) getRewardPointSpentWithReceiptID:(NSInteger)receiptID;
+ (NSMutableArray *) getRewardPointWithCustomerID:(NSInteger)customerID;
+ (NSMutableArray *) getRewardPointSortByModifiedDate:(NSMutableArray *)rewardPointList;
+ (NSMutableArray *) getRewardPointReceiveWithCustomerID:(NSInteger)customerID;
+ (NSMutableArray *) getRewardPointWithReceiptID:(NSInteger)receiptID;
+ (RewardPoint *) getRewardPointLastReceiptReceivePointWithCustomerID:(NSInteger)customerID;
@end
