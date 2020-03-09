//
//  ProductDelete.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/25/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductDelete : NSObject
@property (nonatomic) NSInteger productDeleteID;
@property (retain, nonatomic) NSString * productID;
@property (retain, nonatomic) NSString * productCategory2;
@property (retain, nonatomic) NSString * productCategory1;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (retain, nonatomic) NSString * manufacturingDate;
@property (retain, nonatomic) NSString * status;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * row;
@property (nonatomic) NSInteger sizeOrder;
@property (retain, nonatomic) NSString * productNameText;
@property (retain, nonatomic) NSString * colorText;
@property (retain, nonatomic) NSString * sizeText;
@property (retain, nonatomic) NSString * modifiedDateText;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

@end
