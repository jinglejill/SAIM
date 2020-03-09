//
//  RewardProgram.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 1/2/2560 BE.
//  Copyright © 2560 Appxelent. All rights reserved.
//

#import "RewardProgram.h"
#import "SharedRewardProgram.h"
#import "Utility.h"


@implementation RewardProgram

- (id)initWithRewardProgramID:(NSInteger)rewardProgramID type:(NSInteger)type dateStart:(NSString *)dateStart dateEnd:(NSString *)dateEnd salesSpent:(NSInteger)salesSpent receivePoint:(NSInteger)receivePoint pointSpent:(NSInteger)pointSpent discountType:(NSInteger)discountType discountAmount:(float)discountAmount modifiedDate:(NSString *)modifiedDate
{
    self = [super init];
    if(self)
    {
        self.rewardProgramID = rewardProgramID;
        self.type = type;
        self.dateStart = dateStart;
        self.dateEnd = dateEnd;
        self.salesSpent = salesSpent;
        self.receivePoint = receivePoint;
        self.pointSpent = pointSpent;
        self.discountType = discountType;
        self.discountAmount = discountAmount;
        self.modifiedDate = modifiedDate;
        self.modifiedUser = [Utility modifiedUser];
    }
    return self;
}

+(RewardProgram *)getRewardProgramCurrentCollect
{
    NSMutableArray *rewardProgramList = [SharedRewardProgram sharedRewardProgram].rewardProgramList;
    NSString *strCurrentDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd 00:00:00"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_type = 1 and _dateStart <= %@ and _dateEnd >= %@",strCurrentDate,strCurrentDate];
    NSArray *filterArray = [rewardProgramList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:NO];
        NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortedArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors1];
        
        return sortedArray[0];
    }
    return nil;
}

+(RewardProgram *)getRewardProgramCurrentUse
{
    NSMutableArray *rewardProgramList = [SharedRewardProgram sharedRewardProgram].rewardProgramList;
    NSString *strCurrentDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd 00:00:00"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_type = -1 and _dateStart <= %@ and _dateEnd >= %@",strCurrentDate,strCurrentDate];
    NSArray *filterArray = [rewardProgramList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:NO];
        NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortedArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors1];
        
        return sortedArray[0];
    }
    return nil;
}

+(RewardProgram *)getRewardProgram:(NSInteger)rewardProgramID
{
    NSMutableArray *rewardProgramList = [SharedRewardProgram sharedRewardProgram].rewardProgramList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_rewardProgramID = %ld",rewardProgramID];
    NSArray *filterArray = [rewardProgramList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}

+(void)addRewardProgram:(RewardProgram *)rewardProgram
{
    [[SharedRewardProgram sharedRewardProgram].rewardProgramList addObject:rewardProgram];
}

+(void)addRewardProgramList:(NSMutableArray *)rewardProgramList
{
    [[SharedRewardProgram sharedRewardProgram].rewardProgramList addObjectsFromArray:rewardProgramList];
}

+(void)deleteRewardProgram:(RewardProgram *)rewardProgram
{
    [[SharedRewardProgram sharedRewardProgram].rewardProgramList removeObject:rewardProgram];
}

+(NSMutableArray *)getRewardProgramCollectListDateStart:(NSString *)strDateFrom dateEnd:(NSString *)strDateTo
{
    NSString *dateFrom = [NSString stringWithFormat:@"%@ 00:00:00",strDateFrom];
    NSString *dateTo = [NSString stringWithFormat:@"%@ 00:00:00",strDateTo];
    NSMutableArray *rewardProgramList = [SharedRewardProgram sharedRewardProgram].rewardProgramList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"type = 1 and ((_dateStart <= %@ AND _dateEnd >= %@) or (_dateStart >= %@ AND _dateEnd <= %@) or (_dateStart <= %@ AND _dateEnd >= %@) or (_dateStart <= %@ AND _dateEnd >= %@))",dateFrom,dateTo,dateFrom,dateTo,dateFrom,dateFrom,dateTo,dateTo];
    NSArray *filterArray = [rewardProgramList filteredArrayUsingPredicate:predicate1];
    return [filterArray mutableCopy];
}

+(NSMutableArray *)getRewardProgramUseListDateStart:(NSString *)strDateFrom dateEnd:(NSString *)strDateTo
{
    NSString *dateFrom = [NSString stringWithFormat:@"%@ 00:00:00",strDateFrom];
    NSString *dateTo = [NSString stringWithFormat:@"%@ 00:00:00",strDateTo];
    NSMutableArray *rewardProgramList = [SharedRewardProgram sharedRewardProgram].rewardProgramList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"type = -1 and ((_dateStart <= %@ AND _dateEnd >= %@) or (_dateStart >= %@ AND _dateEnd <= %@) or (_dateStart <= %@ AND _dateEnd >= %@) or (_dateStart <= %@ AND _dateEnd >= %@))",dateFrom,dateTo,dateFrom,dateTo,dateFrom,dateFrom,dateTo,dateTo];
    NSArray *filterArray = [rewardProgramList filteredArrayUsingPredicate:predicate1];
    return [filterArray mutableCopy];
}

+(NSMutableArray *)getRewardProgramListSortByDateStartDateEnd:(NSMutableArray *)rewardProgramList
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_dateStart" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_dateEnd" ascending:YES];
    NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortedArray = [rewardProgramList sortedArrayUsingDescriptors:sortDescriptors1];
    
    return [sortedArray mutableCopy];
}
@end
