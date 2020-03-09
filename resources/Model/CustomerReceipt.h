//
//  CustomerReceipt.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/8/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomerReceipt : NSObject

@property (nonatomic) NSInteger customerReceiptID;
@property (nonatomic) NSInteger receiptID;
@property (retain, nonatomic) NSString * trackingNo;
@property (nonatomic) NSInteger postCustomerID;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

+(CustomerReceipt *)getCustomerReceiptWithReceiptID:(NSInteger)receiptID;
@end

