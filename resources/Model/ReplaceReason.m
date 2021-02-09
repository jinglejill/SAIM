//
//  ReplaceReason.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 29/1/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import "ReplaceReason.h"

@implementation ReplaceReason
+(NSArray *)getReplaceReasonList
{
    NSMutableArray *replaceReasonList = [[NSMutableArray alloc]init];
    {
        ReplaceReason *replaceReason = [[ReplaceReason alloc]init];
        replaceReason.code = 0;
        replaceReason.reason = @"";
        [replaceReasonList addObject:replaceReason];
    }
    {
        ReplaceReason *replaceReason = [[ReplaceReason alloc]init];
        replaceReason.code = 1;
        replaceReason.reason = @"Too big";
        [replaceReasonList addObject:replaceReason];
    }
    {
        ReplaceReason *replaceReason = [[ReplaceReason alloc]init];
        replaceReason.code = 2;
        replaceReason.reason = @"Too small";
        [replaceReasonList addObject:replaceReason];
    }
    {
        ReplaceReason *replaceReason = [[ReplaceReason alloc]init];
        replaceReason.code = 3;
        replaceReason.reason = @"Defect";
        [replaceReasonList addObject:replaceReason];
    }
    {
        ReplaceReason *replaceReason = [[ReplaceReason alloc]init];
        replaceReason.code = 4;
        replaceReason.reason = @"Change color";
        [replaceReasonList addObject:replaceReason];
    }
    {
        ReplaceReason *replaceReason = [[ReplaceReason alloc]init];
        replaceReason.code = 5;
        replaceReason.reason = @"Change mind";
        [replaceReasonList addObject:replaceReason];
    }
    {
        ReplaceReason *replaceReason = [[ReplaceReason alloc]init];
        replaceReason.code = 6;
        replaceReason.reason = @"Out of stock";
        [replaceReasonList addObject:replaceReason];
    }
    {
        ReplaceReason *replaceReason = [[ReplaceReason alloc]init];
        replaceReason.code = 100;
        replaceReason.reason = @"Others";
        [replaceReasonList addObject:replaceReason];
    }
    
    
    return [replaceReasonList copy];
}
@end
