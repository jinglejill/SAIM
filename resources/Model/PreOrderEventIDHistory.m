//
//  PreOrderEventIDHistory.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 8/2/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "PreOrderEventIDHistory.h"
#import "Utility.h"
#import "SharedPreOrderEventIDHistory.h"


@implementation PreOrderEventIDHistory

-(PreOrderEventIDHistory *)initWithReceiptProductItemID:(NSInteger)receiptProductItemID preOrderEventID:(NSInteger)preOrderEventID
{
    self = [super init];
    if(self)
    {
        self.preOrderEventIDHistoryID = [Utility getNextID:tblPreOrderEventIDHistory];
        self.receiptProductItemID = receiptProductItemID;
        self.preOrderEventID = preOrderEventID;
        self.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.modifiedUser = [Utility modifiedUser];
    }
    return self;
}

+(void)addObject:(PreOrderEventIDHistory*)preOrderEventIDHistory
{
    [[SharedPreOrderEventIDHistory sharedPreOrderEventIDHistory].preOrderEventIDHistoryList addObject:preOrderEventIDHistory];
}

+(NSMutableArray *)getHistoryWithReceiptProductItemID:(NSInteger)receiptProductItemID
{
    NSMutableArray *preOrderEventIDHistoryList = [SharedPreOrderEventIDHistory sharedPreOrderEventIDHistory].preOrderEventIDHistoryList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",receiptProductItemID];
    NSArray *filterArray = [preOrderEventIDHistoryList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_preOrderEventIDHistoryID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    
    return [sortArray mutableCopy];
}
@end
