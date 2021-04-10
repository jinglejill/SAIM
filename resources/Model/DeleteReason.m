//
//  DeleteReason.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/2/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import "DeleteReason.h"

@implementation DeleteReason
+(NSArray *)getDeleteReasonList
{
    NSMutableArray *deleteReasonList = [[NSMutableArray alloc]init];
    {
        DeleteReason *deleteReason = [[DeleteReason alloc]init];
        deleteReason.code = 0;
        deleteReason.reason = @"";
        [deleteReasonList addObject:deleteReason];
    }
    {
        DeleteReason *deleteReason = [[DeleteReason alloc]init];
        deleteReason.code = 1;
        deleteReason.reason = @"ไม่ถูกใจ";
        [deleteReasonList addObject:deleteReason];
    }
    {
        DeleteReason *deleteReason = [[DeleteReason alloc]init];
        deleteReason.code = 2;
        deleteReason.reason = @"ไซส์ไม่พอดี";
        [deleteReasonList addObject:deleteReason];
    }
    {
        DeleteReason *deleteReason = [[DeleteReason alloc]init];
        deleteReason.code = 3;
        deleteReason.reason = @"ไม่ทันใช้";
        [deleteReasonList addObject:deleteReason];
    }
    {
        DeleteReason *deleteReason = [[DeleteReason alloc]init];
        deleteReason.code = 4;
        deleteReason.reason = @"มีตำหนิ";
        [deleteReasonList addObject:deleteReason];
    }
    {
        DeleteReason *deleteReason = [[DeleteReason alloc]init];
        deleteReason.code = 5;
        deleteReason.reason = @"ของหมด";
        [deleteReasonList addObject:deleteReason];
    }
    {
        DeleteReason *deleteReason = [[DeleteReason alloc]init];
        deleteReason.code = 100;
        deleteReason.reason = @"Others";
        [deleteReasonList addObject:deleteReason];
    }
    
    return [deleteReasonList copy];
}
@end
