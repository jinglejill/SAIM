//
//  ReceiptProductItem.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/1/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ReceiptProductItem.h"
#import "SharedReceiptItem.h"
#import "Product.h"

@implementation ReceiptProductItem

+(ReceiptProductItem *)getReceiptProductItem:(NSInteger)receiptProductItemID
{
    NSMutableArray *receiptProductItemList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",receiptProductItemID];
    NSArray *filterArray = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    if([filterArray count] == 0)
    {
        return  nil;
    }
    return filterArray[0];
}

+(ReceiptProductItem *)getReceiptProductItem:(NSString *)productID productType:(NSString *)productType
{
    NSMutableArray *receiptProductItemList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productID = %@ and _productType = %@",productID,productType];
    NSArray *filterArray = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    if([filterArray count] == 0)
    {
        return  nil;
    }
    return filterArray[0];
}

+ (NSMutableArray *) getReceiptProductItemWithReceiptID:(NSInteger)receiptID receiptProductItemList:(NSMutableArray *)receiptProductItemList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    
    return [filterArray mutableCopy];
}

+ (NSMutableArray *) getReceiptProductItemSortByProductNameColorSize:(NSMutableArray *)receiptProductItemList
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_size" ascending:YES];
    NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
    NSArray *sortedArray = [receiptProductItemList sortedArrayUsingDescriptors:sortDescriptors1];
    return [sortedArray mutableCopy];
}
+(void)addObject:(ReceiptProductItem*)receiptProductItem
{
    [[SharedReceiptItem sharedReceiptItem].receiptItemList addObject:receiptProductItem];
}

+ (NSMutableArray *) getReceiptProductItemListWithReceiptID:(NSInteger)receiptID
{
    NSMutableArray *receiptProductItemList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    
    return [filterArray mutableCopy];
}
@end
