//
//  Event.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/25/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property (nonatomic) NSInteger eventID;
@property (strong, nonatomic) NSString * location;
@property (strong, nonatomic) NSString * periodFrom;
@property (strong, nonatomic) NSString * periodTo;
@property (strong, nonatomic) NSString * remark;
@property (strong, nonatomic) NSString * modifiedDate;
@property (strong, nonatomic) NSString * productSalesSetID;
@property (strong, nonatomic) NSDate * dtPeriodFrom;
@property (strong, nonatomic) NSDate * dtPeriodTo;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete


+(Event *)getSelectedEvent;
+(Event *)getEvent:(NSInteger)eventID;
+(Event *)getMainEvent;
+(Event *)getEventFromEventList:(NSMutableArray *)eventList eventID:(NSInteger )eventID;
+(NSMutableArray *)getEventListNowAndFutureAsc;
+(NSArray *) SplitEventNowAndFutureAndPast:(NSArray *)eventList;
@end
