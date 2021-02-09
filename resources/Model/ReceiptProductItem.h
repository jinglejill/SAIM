//
//  ReceiptProductItem.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/1/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiptProductItem : NSObject

@property (nonatomic) NSInteger receiptProductItemID;
@property (nonatomic) NSInteger receiptID;
@property (retain, nonatomic) NSString * productType;
@property (nonatomic) NSInteger preOrderEventID;
@property (retain, nonatomic) NSString * productID;
@property (retain, nonatomic) NSString * priceSales;
@property (retain, nonatomic) NSString * customMadeIn;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * row;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (nonatomic) NSInteger sizeOrder;
@property (retain, nonatomic) NSString * toe;
@property (retain, nonatomic) NSString * body;
@property (retain, nonatomic) NSString * accessory;
@property (retain, nonatomic) NSString * customMadeRemark;
@property (retain, nonatomic) NSString * eventID;
@property (retain, nonatomic) NSString * itemCost;
@property (retain, nonatomic) NSString * receiptDate;
@property (retain, nonatomic) NSString * location;
@property (retain, nonatomic) NSString * row2;
@property (nonatomic) NSInteger countInReceipt;
@property (nonatomic) float cash;
@property (nonatomic) float credit;
@property (nonatomic) float transfer;
@property (retain, nonatomic) NSDate * dtModifiedDate;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete


@property (nonatomic) NSInteger replaceProduct;
@property (nonatomic) NSInteger ship;
@property (nonatomic) float shippingFee;
@property (nonatomic) NSInteger discount;
@property (nonatomic) float discountValue;
@property (nonatomic) float discountPercent;
@property (retain, nonatomic) NSString * discountReason;
@property (nonatomic) NSInteger isPreOrder2;
@property (nonatomic) NSInteger preOrder2ProductNameID;
@property (retain, nonatomic) NSString * preOrder2Color;
@property (retain, nonatomic) NSString * preOrder2Size;
@property (nonatomic) NSInteger replaceReceiptProductItemID;
@property (nonatomic) NSInteger replaceReasonCode;
@property (retain, nonatomic) NSString * replaceReason;


+(ReceiptProductItem *)getReceiptProductItem:(NSInteger)receiptProductItemID;
+(ReceiptProductItem *)getReceiptProductItem:(NSString *)productID productType:(NSString *)productType;
+ (NSMutableArray *) getReceiptProductItemWithReceiptID:(NSInteger)receiptID receiptProductItemList:(NSMutableArray *)receiptProductItemList;//สำหรับแสดง ทุกใบเสร็จของ member คนนั้้น โดยแสดงทีละใบเสร็จ

+ (NSMutableArray *) getReceiptProductItemSortByProductNameColorSize:(NSMutableArray *)receiptProductItemList;
+(void)addObject:(ReceiptProductItem*)receiptProductItem;
+ (NSMutableArray *) getReceiptProductItemListWithReceiptID:(NSInteger)receiptID;
@end
