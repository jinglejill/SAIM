//
//  ProductTransfer.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/8/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductTransfer : NSObject
@property (retain, nonatomic) NSString * productID;
@property (retain, nonatomic) NSString * productCode;
@property (retain, nonatomic) NSString * productCategory2;
@property (retain, nonatomic) NSString * productCategory1;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (retain, nonatomic) NSString * manufacturingDate;
@property (retain, nonatomic) NSString * remark;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * productIDGroup;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete



@property (nonatomic) NSInteger transferHistoryID;
@end
