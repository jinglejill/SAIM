//
//  AccountReceiptProductItem.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/9/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountReceiptProductItem.h"

@implementation AccountReceiptProductItem

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [self valueForKey:@"accountReceiptProductItemID"]?[self valueForKey:@"accountReceiptProductItemID"]:[NSNull null],@"accountReceiptProductItemID",
        [self valueForKey:@"accountReceiptID"]?[self valueForKey:@"accountReceiptID"]:[NSNull null],@"accountReceiptID",
        [self valueForKey:@"productNameID"]?[self valueForKey:@"productNameID"]:[NSNull null],@"productNameID",
        [self valueForKey:@"quantity"]?[self valueForKey:@"quantity"]:[NSNull null],@"quantity",
        [self valueForKey:@"amountPerUnit"]?[self valueForKey:@"amountPerUnit"]:[NSNull null],@"amountPerUnit",        
        nil];
}

-(AccountReceiptProductItem *)initWithAccountReceiptProductItemID:(NSInteger)accountReceiptProductItemID accountReceiptID:(NSInteger)accountReceiptID productNameID:(NSInteger)productNameID quantity:(float)quantity amountPerUnit:(float)amountPerUnit
{
    self = [super init];
    if(self)
    {
        self.accountReceiptProductItemID = accountReceiptProductItemID;
        self.accountReceiptID = accountReceiptID;
        self.productNameID = productNameID;
        self.quantity = quantity;
        self.amountPerUnit = amountPerUnit;
    }
    return self;
}

+(NSMutableArray *)getAccountReceiptProductItem:(NSMutableArray *)accountReceiptProductItemList accountReceiptID:(NSInteger)accountReceiptID
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_accountReceiptID = %ld",accountReceiptID];
    NSArray *filterArray = [accountReceiptProductItemList filteredArrayUsingPredicate:predicate1];
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_accountReceiptProductItemID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    if([sortArray count]>0)
    {
        return [sortArray mutableCopy];
    }
    return nil;
}
@end
