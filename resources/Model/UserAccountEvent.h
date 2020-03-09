//
//  UserAccountEvent.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/16/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAccountEvent : NSObject
@property (nonatomic) NSInteger userAccountEventID;
@property (nonatomic) NSInteger userAccountID;
@property (retain, nonatomic) NSString * eventID;
@property (retain, nonatomic) NSString * modifiedDate;
@property (strong, nonatomic) NSString * location;
@property (strong, nonatomic) NSString * periodFrom;
@property (strong, nonatomic) NSString * periodTo;
@property (strong, nonatomic) NSString * remark;
@property (strong, nonatomic) NSString * eventModifiedDate;
@property (strong, nonatomic) NSString * username;
@property (strong, nonatomic) NSString * productSalesSetID;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete
@end
