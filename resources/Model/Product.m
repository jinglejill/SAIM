//
//  Product.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/4/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "Product.h"
#import "SharedProduct.h"
#import "Utility.h"

@implementation Product
- (id)init
{
    self.productID = @"";
    self.productCode = @"";
    self.productCategory2 = @"";
    self.productCategory1 = @"";
    self.productName = @"";
    self.color = @"";
    self.size = @"";
    self.manufacturingDate = @"";
    self.status = @"";
    self.remark = @"";
    self.eventID = 0;
    self.modifiedDate = @"";
    self.modifiedUser = [Utility modifiedUser];
    
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    // Copying code here.
    Product *copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setProductID:[self.productID copyWithZone:zone]];
        [copy setProductCode:[self.productCode copyWithZone:zone]];
        [copy setProductCategory2:[self.productCategory2 copyWithZone:zone]];
        [copy setProductCategory1:[self.productCategory1 copyWithZone:zone]];
        [copy setProductName:[self.productName copyWithZone:zone]];
        [copy setColor:[self.color copyWithZone:zone]];
        [copy setSize:[self.size copyWithZone:zone]];
        [copy setManufacturingDate:[self.manufacturingDate copyWithZone:zone]];
        [copy setStatus:[self.status copyWithZone:zone]];
        [copy setRemark:[self.remark copyWithZone:zone]];
        ((Product *)copy).eventID = self.eventID;
        [copy setModifiedDate:[self.modifiedDate copyWithZone:zone]];
    }
    
    return copy;
}

+ (NSMutableArray *)getProductListInMainInventory:(Product *)product
{
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _eventID = 0 and _status = 'I'",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,product.manufacturingDate];
    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
    return [filterArray mutableCopy];
}

+ (Product *)getProduct:(NSString *)productID
{
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productID = %@",productID];
    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    
    return nil;
}
@end

