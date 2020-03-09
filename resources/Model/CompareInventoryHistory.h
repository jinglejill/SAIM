//
//  CompareInventoryHistory.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompareInventoryHistory : NSObject
@property (nonatomic) NSInteger compareInventoryHistoryID;
@property (retain, nonatomic) NSString * eventID;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * row;
@property (retain, nonatomic) NSString * eventName;
@property (retain, nonatomic) NSString * modifiedDateText;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

@end
