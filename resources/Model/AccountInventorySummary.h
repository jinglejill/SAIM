//
//  AccountInventorySummary.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/4/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountInventorySummary : NSObject
@property (nonatomic) int productNameID;
@property (retain, nonatomic) NSString *productName;
@property (nonatomic) float quantity;
@property (nonatomic) float salesQuantity;
@property (nonatomic) NSInteger billings;

@property (retain, nonatomic) NSString *productCategory2;
@property (nonatomic) NSInteger productCategory2Order;
@property (nonatomic) BOOL hilight;

    
+(NSMutableArray *)getAccountInventorySummaryFilterOutUsedUp:(NSMutableArray *)accountInventorySummaryList;
+(NSMutableArray *)getAccountInventorySummarySortByProductCategory2AndProductName:(NSMutableArray *)accountInventorySummaryList;
+(void)addBillingsWithProductNameID:(NSInteger)productNameID accountInventorySummary:(NSMutableArray *)accountInventorySummaryList;
+(void)removeBillingsWithProductNameID:(NSInteger)productNameID accountInventorySummary:(NSMutableArray *)accountInventorySummaryList;
+(NSMutableArray *)getAccountInventorySummaryBillingsOnly:(NSMutableArray *)accountInventorySummaryList;
+(void)hilightEveryOtherProductCategory2:(NSMutableArray *)accountInventorySummaryList;
+(AccountInventorySummary *)getAccountInventorySummaryWithProductNameID:(NSInteger)productNameID accountInventorySummary:(NSMutableArray *)accountInventorySummaryList;
@end
