//
//  AccountReceipt.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/8/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountReceipt : NSObject


@property (nonatomic) NSInteger accountReceiptID;
@property (nonatomic) NSInteger runningAccountReceiptHistory;
@property (nonatomic) NSInteger runningReceiptNo;
@property (retain, nonatomic) NSString *accountReceiptHistoryDate;


@property (retain, nonatomic) NSString *receiptNo;
@property (retain, nonatomic) NSString *receiptDate;
@property (nonatomic) NSInteger receiptID;
@property (nonatomic) float receiptDiscount;

@property (retain, nonatomic) NSString *taxCustomerName;
@property (retain, nonatomic) NSString *taxCustomerAddress;
@property (retain, nonatomic) NSString *taxNo;

@property (nonatomic) NSInteger maxRunningReceiptNo;
@property (nonatomic) NSInteger maxRunningAccountReceiptHistory;
@property (nonatomic) NSInteger maxAccountReceiptID;

@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete


- (NSDictionary *)dictionary;
-(AccountReceipt *)initWithAccountReceiptID:(NSInteger)accountReceiptID runningAccountReceiptHistory:(NSInteger)runningAccountReceiptHistory runningReceiptNo:(NSInteger)runningReceiptNo accountReceiptHistoryDate:(NSString*)accountReceiptHistoryDate receiptNo:(NSString*)receiptNo receiptDate:(NSString*)receiptDate receiptID:(NSInteger)receiptID receiptDiscount:(float)receiptDiscount;

+(NSMutableArray *)getAccountReceiptSortByAccountReceiptID:(NSMutableArray *)accountReceiptList;
@end
