//
//  PostCustomer.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "PostCustomer.h"
#import "SharedPostCustomer.h"
#import "CustomerReceipt.h"


@implementation PostCustomer
//+(PostCustomer*)getPostCustomerWithReceiptID:(NSInteger)receiptID
//{
//    NSMutableArray *postCustomerList = [SharedPostCustomer sharedPostCustomer].postCustomerList;
//    return [self getPostCustomerWithReceiptID:receiptID postCustomerList:postCustomerList];
//}
+(PostCustomer*)getPostCustomer:(NSInteger)postCustomerID
{
    NSMutableArray *postCustomerList = [SharedPostCustomer sharedPostCustomer].postCustomerList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_postCustomerID = %ld",postCustomerID];
    NSArray *filterArray = [postCustomerList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return  filterArray[0];
    }
    return nil;
}

+(PostCustomer*)getPostCustomerWithReceiptID:(NSInteger)receiptID postCustomerList:(NSMutableArray *)postCustomerList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [postCustomerList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return  filterArray[0];
    }
    return nil;
}

+(NSInteger)getCustomerID:(NSString *)telephone
{
    NSMutableArray *postCustomerList = [SharedPostCustomer sharedPostCustomer].postCustomerList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_telephone = %@",telephone];
    NSArray *filterArray = [postCustomerList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        PostCustomer *postCustomer = filterArray[0];
        return postCustomer.customerID;
    }
    
    
    return 0;
}

+(PostCustomer*)getPostCustomerWithPhoneNo:(NSString *)telephone
{
    NSMutableArray *postCustomerList = [SharedPostCustomer sharedPostCustomer].postCustomerList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_telephone = %@",telephone];
    NSArray *filterArray = [postCustomerList filteredArrayUsingPredicate:predicate1];
    postCustomerList = [filterArray mutableCopy];
    postCustomerList = [self getPostCustomerSortByModifiedDate:postCustomerList];
    
    
    if([postCustomerList count] > 0)
    {
        PostCustomer *postCustomer = postCustomerList[0];
        return postCustomer;
    }
    
    
    return nil;
}

+(NSMutableArray*)getPostCustomerSortByModifiedDate:(NSMutableArray *)postCustomerList
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [postCustomerList sortedArrayUsingDescriptors:sortDescriptors];
    postCustomerList = [sortArray mutableCopy];
    
    return postCustomerList;
}
@end
