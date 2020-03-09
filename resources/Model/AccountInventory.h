//
//  AccountInventory.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/2/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountInventory : NSObject
@property (nonatomic) NSInteger accountInventoryID;
@property (nonatomic) NSInteger productNameID;
@property (nonatomic) float quantity;
@property (nonatomic) NSInteger status;
@property (retain, nonatomic) NSString * inOutDate;
@property (nonatomic) NSInteger runningAccountReceiptHistory;
@property (retain, nonatomic) NSString * modifiedDate;
@property (nonatomic) NSInteger maxAccountInventoryID;
@property (retain, nonatomic) NSString * productName;
@property (nonatomic) NSInteger used;

@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

- (NSDictionary *)dictionary;
- (AccountInventory *)initWithAccountInventoryID:(NSInteger)accountInventoryID productNameID:(NSInteger)productNameID quantity:(float)quantity status:(NSInteger)status inOutDate:(NSString *)inOutDate runningAccountReceiptHistory:(NSInteger)runningAccountReceiptHistory modifiedDate:(NSString *)modifiedDate;
+ (NSMutableArray *)getAccountInventorySortedByUsed:(NSMutableArray *)accountInventoryList;
@end


