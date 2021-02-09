//
//  SalesProductAndPrice.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/7/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SalesProductAndPrice : NSObject
@property (nonatomic) int productNameID;
@property (retain, nonatomic) NSString *productName;
@property (nonatomic) float priceSales;
@property (nonatomic) int billings;
@property (nonatomic) int receiptID;
@property (nonatomic) int receiptProductItemID;
@property (retain, nonatomic) NSString *receiptDate;
@property (nonatomic) BOOL hilight;
@property (retain, nonatomic) NSString *taxCustomerName;
@property (nonatomic) NSInteger isCredit;
@property (nonatomic) float receiptDiscount;
@property (nonatomic) float itemDiscount;

@property (nonatomic) float quantity;
@property (nonatomic) float amountPerUnit;

@property (nonatomic) NSInteger runningReceiptNo;
@property (retain, nonatomic) NSString *receiptNo;


+(void)clearBillingsWithProductNameID:(NSInteger)productNameID salesProductAndPrice:(NSMutableArray *)salesProductAndPriceList;
+(NSInteger)getCountBillingsWithProductNameID:(NSInteger)productNameID salesProductAndPrice:(NSMutableArray *)salesProductAndPriceList;
+(void)addBillings:(NSInteger)count productNameID:(NSInteger)productNameID salesProductAndPrice:(NSMutableArray *)salesProductAndPriceList;
+(void)removeBillings:(NSInteger)count productNameID:(NSInteger)productNameID salesProductAndPrice:(NSMutableArray *)salesProductAndPriceList;
+(NSMutableArray *)getSalesProductAndPriceSortByReceiptDate:(NSMutableArray *)salesProductAndPriceList;
+(NSMutableArray *)getSalesProductAndPriceSortByReceiptDateDesc:(NSMutableArray *)salesProductAndPriceList;
+(void)hilightEveryOtherReceipt:(NSMutableArray *)salesProductAndPriceList;
+(float)getTotalSalesSelected:(NSMutableArray *)salesProductAndPriceList;
+(float)getTotalPairsSelected:(NSMutableArray *)salesProductAndPriceList;
+(NSMutableArray *)getSalesProductAndPriceBillingsOnly:(NSMutableArray *)salesProductAndPriceList;
+(NSInteger)getCountSalesProductAndPriceBillingsOnly:(NSMutableArray *)salesProductAndPriceList;
+(SalesProductAndPrice *)getSalesProductAndPriceWithReceiptID:(NSInteger)receiptID salesProductAndPriceList:(NSMutableArray *)salesProductAndPriceBillingsOnlySumQuantityList;
@end
