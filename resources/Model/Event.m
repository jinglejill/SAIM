//
//  Event.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/25/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "Event.h"
#import "SharedSelectedEvent.h"
#import "SharedEvent.h"
#import "Utility.h"
#import "SharedMainEvent.h"


@implementation Event
+(Event *)getSelectedEvent
{
    Event *event = [SharedSelectedEvent sharedSelectedEvent].event;
    event = [Utility getEvent:event.eventID];
    return event;
}

+(Event *)getEvent:(NSInteger)eventID
{
    if(eventID == 0)
    {
        return [Event getMainEvent];
    }
    
    NSMutableArray *eventList = [SharedEvent sharedEvent].eventList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %ld",eventID];
    NSArray *filterArray = [eventList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}

+(Event *)getMainEvent
{
    Event *sharedMainEvent = [SharedMainEvent sharedMainEvent].event;
    if(!sharedMainEvent.eventID)
    {
        sharedMainEvent.eventID = 0;
        sharedMainEvent.location = @"Main stock";
        sharedMainEvent.periodFrom = @"2000-01-01";
        sharedMainEvent.periodTo = @"2100-12-31";
        sharedMainEvent.remark = @"";
        sharedMainEvent.modifiedDate = @"2000-01-01 00:00:00";
        sharedMainEvent.modifiedUser = [Utility modifiedUser];
        sharedMainEvent.productSalesSetID = @"0";
    }
    return sharedMainEvent;
}

+(Event *)getEventFromEventList:(NSMutableArray *)eventList eventID:(NSInteger )eventID
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %ld",eventID];
    NSArray *filterArray = [eventList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    else if([eventList count] > 0)
    {
        return eventList[0];
    }
    return nil;
}

+(NSMutableArray *)getEventListNowAndFutureAsc
{
    NSMutableArray *eventList = [SharedEvent sharedEvent].eventList;
    NSArray *arrOfEventList = [self SplitEventNowAndFutureAndPast:eventList];
    return arrOfEventList[0];
}

+ (NSArray *) SplitEventNowAndFutureAndPast:(NSArray *)eventList
{
    for(Event *item in eventList)
    {
        item.dtPeriodFrom = [Utility stringToDate:item.periodFrom fromFormat:[Utility setting:vFormatDateDB]];
        item.dtPeriodTo = [Utility stringToDate:item.periodTo fromFormat:[Utility setting:vFormatDateDB]];
    }
    
    
    NSMutableArray *arrOfEventList = [[NSMutableArray alloc]init];
    
    
    //eventListNowAndFutureASC
    NSDate *currentDate = [Utility dateFromDateTime:[NSDate date]];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(_dtPeriodFrom <= %@ AND _dtPeriodTo >= %@) OR (_dtPeriodFrom > %@)",currentDate,currentDate,currentDate];
    NSArray *filtered1  = [eventList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_dtPeriodFrom" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_dtPeriodTo" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_location" ascending:YES];
    NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
    NSArray *sortedArray1 = [filtered1 sortedArrayUsingDescriptors:sortDescriptors1];
    NSMutableArray *eventListNowAndFutureAsc = [sortedArray1 mutableCopy];
    [arrOfEventList addObject:eventListNowAndFutureAsc];
    
    
    //eventListPastDesc
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"_dtPeriodTo < %@",currentDate];
    NSArray *filtered2  = [eventList filteredArrayUsingPredicate:predicate2];
    
    NSSortDescriptor *sortDescriptor4 = [[NSSortDescriptor alloc] initWithKey:@"_dtPeriodTo" ascending:NO];
    NSSortDescriptor *sortDescriptor5 = [[NSSortDescriptor alloc] initWithKey:@"_dtPeriodFrom" ascending:NO];
    NSSortDescriptor *sortDescriptor6 = [[NSSortDescriptor alloc] initWithKey:@"_location" ascending:YES];
    NSArray *sortDescriptors2 = [NSArray arrayWithObjects:sortDescriptor4,sortDescriptor5,sortDescriptor6, nil];
    NSArray *sortedArray2 = [filtered2 sortedArrayUsingDescriptors:sortDescriptors2];
    NSMutableArray *eventListPastDesc = [sortedArray2 mutableCopy];
    
    [arrOfEventList addObject:eventListPastDesc];
    
    return arrOfEventList;
}
@end
