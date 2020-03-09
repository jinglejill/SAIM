//
//  ProductSalesSet.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/23/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductSalesSet : NSObject
@property (retain, nonatomic) NSString * productSalesSetID;
@property (retain, nonatomic) NSString * productSalesSetName;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

@end
