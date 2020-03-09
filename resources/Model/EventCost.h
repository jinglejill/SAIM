//
//  EventCost.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/24/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventCost : NSObject
@property (nonatomic) NSInteger eventCostID;
@property (retain, nonatomic) NSString * eventID;
@property (retain, nonatomic) NSString * costLabelID;
@property (retain, nonatomic) NSString * cost;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * costLabel;
@property (nonatomic) float floatCost;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

@end
