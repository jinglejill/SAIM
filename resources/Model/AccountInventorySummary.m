//
//  AccountInventorySummary.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/4/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountInventorySummary.h"
#import "ProductName.h"
#import "ProductCategory2.h"


@implementation AccountInventorySummary

+(NSMutableArray *)getAccountInventorySummaryFilterOutUsedUp:(NSMutableArray *)accountInventorySummaryList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_quantity != 0 or _salesQuantity != 0"];
    NSArray *filterArray = [accountInventorySummaryList filteredArrayUsingPredicate:predicate1];
    return [filterArray mutableCopy];
}

+(NSMutableArray *)getAccountInventorySummarySortByProductCategory2AndProductName:(NSMutableArray *)accountInventorySummaryList
{
    for(AccountInventorySummary *item in accountInventorySummaryList)
    {
        ProductName *productName = [ProductName getProductName:item.productNameID];
        ProductCategory2 *productCategory2 = [ProductCategory2 getProductCategory2:productName.productCategory2];
        item.productCategory2 = productCategory2.name;
        item.productCategory2Order = productCategory2.orderNo;
    }
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productCategory2Order" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];        
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortArray = [accountInventorySummaryList sortedArrayUsingDescriptors:sortDescriptors];
    accountInventorySummaryList = [sortArray mutableCopy];
    return accountInventorySummaryList;
}

+(void)addBillingsWithProductNameID:(NSInteger)productNameID accountInventorySummary:(NSMutableArray *)accountInventorySummaryList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productNameID];
    NSArray *filterArray = [accountInventorySummaryList filteredArrayUsingPredicate:predicate1];
    
    AccountInventorySummary *accountInventorySummary = filterArray[0];
    accountInventorySummary.billings += 1;
}

+(void)removeBillingsWithProductNameID:(NSInteger)productNameID accountInventorySummary:(NSMutableArray *)accountInventorySummaryList;
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productNameID];
    NSArray *filterArray = [accountInventorySummaryList filteredArrayUsingPredicate:predicate1];
    
    AccountInventorySummary *accountInventorySummary = filterArray[0];
    accountInventorySummary.billings -= 1;
}

+(NSMutableArray *)getAccountInventorySummaryBillingsOnly:(NSMutableArray *)accountInventorySummaryList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_billings > 0"];
    NSArray *filterArray = [accountInventorySummaryList filteredArrayUsingPredicate:predicate1];
    
    return [filterArray mutableCopy];
}

+(void)hilightEveryOtherProductCategory2:(NSMutableArray *)accountInventorySummaryList
{
    NSString *previousProductCategory2 = @"00";
    BOOL hilight = YES;
    for(AccountInventorySummary *item in accountInventorySummaryList)
    {
        if(item.productCategory2 != previousProductCategory2)
        {
            hilight = !hilight;
            previousProductCategory2 = item.productCategory2;
        }
        item.hilight = hilight;
    }
}

+(AccountInventorySummary *)getAccountInventorySummaryWithProductNameID:(NSInteger)productNameID accountInventorySummary:(NSMutableArray *)accountInventorySummaryList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productNameID];
    NSArray *filterArray = [accountInventorySummaryList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}
@end
