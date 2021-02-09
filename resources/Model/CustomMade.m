//
//  CustomMade.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/31/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomMade.h"
#import "SharedCustomMade.h"

@implementation CustomMade
+(CustomMade*)getCustomMade:(NSInteger)custommMadeID
{
    NSMutableArray *customMadeList =[SharedCustomMade sharedCustomMade].customMadeList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_customMadeID = %ld",custommMadeID];
    NSArray *filterArray = [customMadeList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return  nil;
}

+(CustomMade*)getCustomMadeFromProductIDPost:(NSString *)productIDPost
{
    NSMutableArray *customMadeList =[SharedCustomMade sharedCustomMade].customMadeList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productIDPost = %@",productIDPost];
    NSArray *filterArray = [customMadeList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return  nil;
}
    @end
