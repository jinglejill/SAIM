//
//  CustomMade.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/31/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomMade : NSObject
@property (nonatomic) NSInteger customMadeID;
@property (retain, nonatomic) NSString * productCategory2;
@property (retain, nonatomic) NSString * productCategory1;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * size;
@property (retain, nonatomic) NSString * toe;
@property (retain, nonatomic) NSString * body;
@property (retain, nonatomic) NSString * accessory;
@property (retain, nonatomic) NSString * remark;
@property (retain, nonatomic) NSString * productIDPost;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete


@property (nonatomic) NSInteger replaceProduct;
@property (nonatomic) NSInteger ship;
@property (nonatomic) NSInteger discount;
@property (nonatomic) float discountValue;
@property (nonatomic) float discountPercent;
@property (retain, nonatomic) NSString * discountReason;
@property (nonatomic) NSInteger postCustomerID;


+(CustomMade*)getCustomMade:(NSInteger)custommMadeID;
@end
