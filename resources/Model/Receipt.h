//
//  Receipt.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/1/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Receipt : NSObject
@property (nonatomic) NSInteger receiptID;
@property (retain, nonatomic) NSString * eventID;
@property (nonatomic) NSInteger channel;
@property (retain, nonatomic) NSString * payPrice;
@property (retain, nonatomic) NSString * paymentMethod;
@property (retain, nonatomic) NSString * creditAmount;
@property (retain, nonatomic) NSString * cashAmount;
@property (retain, nonatomic) NSString * transferAmount;
@property (retain, nonatomic) NSString * cashReceive;
@property (retain, nonatomic) NSString * remark;
@property (retain, nonatomic) NSString * shippingFee;
@property (retain, nonatomic) NSString * discount;
@property (retain, nonatomic) NSString * discountValue;
@property (retain, nonatomic) NSString * discountPercent;
@property (retain, nonatomic) NSString * discountReason;
@property (retain, nonatomic) NSString * receiptDate;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSDate* dtReceiptDate;
@property (nonatomic) int postCustomerZone;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

@property (retain, nonatomic) NSString * receiptNoID;
@property (retain, nonatomic) NSString * total;
@property (retain, nonatomic) NSString * salesUser;
@property (retain, nonatomic) NSString * referenceOrderNo;

+ (Receipt *)getReceipt:(NSInteger)receiptID;
+ (NSMutableArray *)getReceiptSortByReceiptDate:(NSMutableArray *)receiptList;
@end
