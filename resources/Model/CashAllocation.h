//
//  EventCashAllocation.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/18/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CashAllocation : NSObject
@property (nonatomic) NSInteger cashAllocationID;
@property (strong, nonatomic) NSString * eventID;
@property (strong, nonatomic) NSString * cashChanges;
@property (strong, nonatomic) NSString * cashTransfer;
@property (strong, nonatomic) NSString * inputDate;
@property (strong, nonatomic) NSString * modifiedDate;

@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

@end
