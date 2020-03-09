//
//  Setting.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/20/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject
@property (nonatomic) NSInteger settingID;
@property (strong, nonatomic) NSString * enumKey;
@property (strong, nonatomic) NSString * value;
@property (strong, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete
@end
