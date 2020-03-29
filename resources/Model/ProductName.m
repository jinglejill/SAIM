//
//  ProductName.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductName.h"
#import "SharedProductName.h"
#import "SharedCustomMade.h"
#import "CustomMade.h"


@implementation ProductName
- (id)copyWithZone:(NSZone *)zone
{
    // Copying code here.
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        ((ProductName *)copy).productNameID = self.productNameID;
        [copy setProductCategory2:[self.productCategory2 copyWithZone:zone]];
        [copy setProductCategory1:[self.productCategory1 copyWithZone:zone]];
        [copy setCode:[self.code copyWithZone:zone]];
        [copy setName:[self.name copyWithZone:zone]];
        [copy setDetail:[self.detail copyWithZone:zone]];
        [copy setModifiedDate:[self.modifiedDate copyWithZone:zone]];
    }
    
    return copy;
}

+ (ProductName *)getProductNameWithProduct:(Product *)product
{
    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _code = %@",product.productCategory2,product.productCategory1,product.productName];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    if([filterArray count] > 0)
    {
        return filterArray[0];;
    }
    return nil;
}

+ (ProductName *)getProductName:(NSInteger)productNameID
{
    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productNameID];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    if([filterArray count] > 0)
    {
        return filterArray[0];;
    }
    return nil;
}

+ (NSString *)getProductCode:(NSInteger)productNameID
{
    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productNameID];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        ProductName *productName = filterArray[0];
        return [NSString stringWithFormat:@"%@%@%@",productName.productCategory2,productName.productCategory1,productName.code];
    }
    return @"-";
}

+ (NSString *)getNameWithProductID:(NSString *)productID
{
    Product *product = [Product getProduct:productID];
    NSString *selectedProductNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
    
    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
    for(ProductName *item in productNameList)
    {
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",item.productCategory2,item.productCategory1,item.code];
        if([productNameGroup isEqualToString:selectedProductNameGroup])
        {
            return item.name;
        }
    }
    return  @"-";
}

+ (NSString *)getName:(NSInteger)productNameID
{
    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
    for(ProductName *item in productNameList)
    {
        if(item.productNameID == productNameID)
        {
            return item.name;
        }
    }
    return  @"-";
}

+ (ProductName *)getProductNameWithProductID:(NSString *)productID
{
    Product *product = [Product getProduct:productID];
    NSString *selectedProductNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
    
    
    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
    for(ProductName *item in productNameList)
    {
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",item.productCategory2,item.productCategory1,item.code];
        if([productNameGroup isEqualToString:selectedProductNameGroup])
        {
            return item;
        }
    }
    return nil;
}

+ (ProductName *)getProductNameWithProductNameGroup:(NSString *)productNameGroup
{
    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
    for(ProductName *item in productNameList)
    {
        NSString *productNameGroupItem = [NSString stringWithFormat:@"%@%@%@",item.productCategory2,item.productCategory1,item.code];
        if([productNameGroupItem isEqualToString:productNameGroup])
        {
            return item;
        }
    }
    return nil;
}

+ (ProductName *)getProductNameWithProductIDGroup:(NSString *)productIDGroup
{
    NSRange needleRange = NSMakeRange(0,6);
    NSString *productNameGroup = [productIDGroup substringWithRange:needleRange];
    
    
    return [self getProductNameWithProductNameGroup:productNameGroup];
}

+ (NSInteger)getProductNameIDWithName:(NSString *)name
{
    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_name = %@",name];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        ProductName *item = filterArray[0];
        return item.productNameID;
    }
    return 0;
}

+ (NSString *)getNameWithCustomMadeID:(NSInteger)customMadeID
{
    NSMutableArray *customMadeList = [SharedCustomMade sharedCustomMade].customMadeList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_customMadeID = %ld",customMadeID];
    NSArray *filterArray = [customMadeList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        CustomMade *customMade = filterArray[0];
        NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _code = %@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
        NSArray *productNameFiltered = [productNameList filteredArrayUsingPredicate:predicate1];
        if([productNameFiltered count]>0)
        {
            ProductName *productName = productNameFiltered[0];
            return productName.name;
        }
    }
    return @"-";
}

+ (NSString *)getNameWithProductNameGroup:(NSString *)productNameGroup
{
    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
    for(ProductName *item in productNameList)
    {
        NSString *productNameGroupItem = [NSString stringWithFormat:@"%@%@%@",item.productCategory2,item.productCategory1,item.code];
        if([productNameGroupItem isEqualToString:productNameGroup])
        {
            return item.name;
        }
    }
    return  @"";
}

+ (NSString *)getProductNameGroupWithProductName:(ProductName *)productName
{
    return [NSString stringWithFormat:@"%@%@%@",productName.productCategory2,productName.productCategory1,productName.code];
}
@end
