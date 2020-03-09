//
//  RewardPoint.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 11/8/2559 BE.
//  Copyright © 2559 Appxelent. All rights reserved.
//

#import "RewardPoint.h"
#import "SharedRewardPoint.h"
#import "Receipt.h"


@implementation RewardPoint

+ (RewardPoint *) getRewardPointReceiveWithReceiptID:(NSInteger)receiptID
{
    NSMutableArray *rewardPointList = [SharedRewardPoint sharedRewardPoint].rewardPointList;
    
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld and status = 1",receiptID];
    NSArray *filterArray = [rewardPointList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}

+ (RewardPoint *) getRewardPointSpentWithReceiptID:(NSInteger)receiptID
{
    NSMutableArray *rewardPointList = [SharedRewardPoint sharedRewardPoint].rewardPointList;
    
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld and _status = -1",receiptID];
    NSArray *filterArray = [rewardPointList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}

+ (NSInteger) getRewardPointPointWithCustomerID:(NSInteger)customerID
{
    NSArray *filterArray = [self getRewardPointWithCustomerID:customerID];

    
    NSInteger sumPoint = 0;
    for(RewardPoint *item in filterArray)
    {
//        if(item.status == 1)
        {
            sumPoint += item.point*item.status;
        }
//        else if(item.status == 0)
//        {
//            sumPoint -= item.point;
//        }
    }
    
    return sumPoint;
}

+ (NSMutableArray *) getRewardPointWithCustomerID:(NSInteger)customerID
{
    NSMutableArray *rewardPointList = [SharedRewardPoint sharedRewardPoint].rewardPointList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_customerID = %ld",customerID];
    NSArray *filterArray = [rewardPointList filteredArrayUsingPredicate:predicate1];
    
    
    return [filterArray mutableCopy];
}

+ (NSMutableArray *) getRewardPointSortByModifiedDate:(NSMutableArray *)rewardPointList
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:YES];
    NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortedArray = [rewardPointList sortedArrayUsingDescriptors:sortDescriptors1];
    
    return [sortedArray mutableCopy];
}

+ (NSMutableArray *) getRewardPointReceiveWithCustomerID:(NSInteger)customerID
{
    NSMutableArray *rewardPointList = [SharedRewardPoint sharedRewardPoint].rewardPointList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_customerID = %ld and _status = 1",customerID];
    NSArray *filterArray = [rewardPointList filteredArrayUsingPredicate:predicate1];
    
    
    return [filterArray mutableCopy];
}

+ (NSMutableArray *) getRewardPointWithReceiptID:(NSInteger)receiptID
{
    NSMutableArray *rewardPointList = [SharedRewardPoint sharedRewardPoint].rewardPointList;
    
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [rewardPointList filteredArrayUsingPredicate:predicate1];
    
    return [filterArray mutableCopy];
}

+ (RewardPoint *) getRewardPointLastReceiptReceivePointWithCustomerID:(NSInteger)customerID
{
    NSMutableArray *rewardPointList = [SharedRewardPoint sharedRewardPoint].rewardPointList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_customerID = %ld",customerID];
    NSArray *filterArray = [rewardPointList filteredArrayUsingPredicate:predicate1];
    
    NSMutableArray *sortArray = [self getRewardPointSortByModifiedDate:[filterArray mutableCopy]];
    RewardPoint *rewardPoint = sortArray[[sortArray count]-1];
    
    RewardPoint *rewardPointReceive = [self getRewardPointReceiveWithReceiptID:rewardPoint.receiptID];
    return rewardPointReceive;
}
@end
