//
//  MemberAndPoint.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/19/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "MemberAndPoint.h"

@implementation MemberAndPoint


+ (NSMutableArray *)getMemberAndPointSortByPointRemaining:(NSMutableArray *)memberAndPointList
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_pointRemaining" ascending:NO];
    NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortedArray = [memberAndPointList sortedArrayUsingDescriptors:sortDescriptors1];
    return [sortedArray mutableCopy];
}
@end
