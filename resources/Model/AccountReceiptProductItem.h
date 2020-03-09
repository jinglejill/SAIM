//
//  AccountReceiptProductItem.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/9/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountReceiptProductItem : NSObject


@property (nonatomic) NSInteger accountReceiptProductItemID;
@property (nonatomic) NSInteger accountReceiptID;
@property (nonatomic) NSInteger productNameID;
@property (nonatomic) float quantity;
@property (nonatomic) float amountPerUnit;
@property (retain, nonatomic) NSString *modifiedDate;

@property (nonatomic) NSInteger maxAccountReceiptProductItemID;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete


- (NSDictionary *)dictionary;
-(AccountReceiptProductItem *)initWithAccountReceiptProductItemID:(NSInteger)accountReceiptProductItemID accountReceiptID:(NSInteger)accountReceiptID productNameID:(NSInteger)productNameID quantity:(float)quantity amountPerUnit:(float)amountPerUnit;
+(NSMutableArray *)getAccountReceiptProductItem:(NSMutableArray *)accountReceiptProductItemList accountReceiptID:(NSInteger)accountReceiptID;
@end
