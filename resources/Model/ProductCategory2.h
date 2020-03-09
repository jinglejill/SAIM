//
//  ProductCategory2.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/1/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductCategory2 : NSObject<NSCopying>
@property (retain, nonatomic) NSString * code;
@property (retain, nonatomic) NSString * name;
@property (nonatomic) NSInteger orderNo;
@property (retain, nonatomic) NSString * modifiedDate;
@property (nonatomic) NSInteger productCategory2ID;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

+(NSArray *)getProductCategory2List;
+ (NSMutableArray *)getProductCategory2SortByOrderNo:(NSMutableArray *)productCategory2List;
+ (ProductCategory2 *)getProductCategory2:(NSString *)code;
@end
