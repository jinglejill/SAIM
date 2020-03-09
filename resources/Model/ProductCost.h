//
//  ProductCost.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/23/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductCost : NSObject
@property (retain, nonatomic) NSString * productCostID;
@property (nonatomic) NSInteger productNameID;
@property (retain, nonatomic) NSString * colorCode;
@property (retain, nonatomic) NSString * cost;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * row;
@property (retain, nonatomic) NSString * editType;//0=edit,1=unselect,2=select
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * price;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

@end
