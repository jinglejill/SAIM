//
//  ProductSales.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/1/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductSales.h"
#import "SharedProductSales.h"


@implementation ProductSales

+ (ProductSales *)getProductSalesFromProductNameID:(NSInteger)productNameID color:(NSString *)color size:(NSString *)size productSalesSetID:(NSString *)productSalesSetID
{
    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@ and _productNameID = %ld and color = %@ and _size = %@",productSalesSetID,productNameID,color,size];
    NSArray *filterArray = [productSalesList filteredArrayUsingPredicate:predicate1];
//    productSalesList = [filterArray mutableCopy];
    
//    for(ProductSales *item in productSalesList)
//    {
//        if((item.productNameID == productNameID) && [item.color isEqualToString:color] && [item.size isEqualToString:size])
//        {
//            return item;
//        }
//    }
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}

+(void)addProductSalesList:(NSMutableArray *)productSalesList
{
    NSMutableArray *dataList = [SharedProductSales sharedProductSales].productSalesList;
    [dataList addObjectsFromArray:productSalesList];
}
@end
