//
//  ProductCategory1.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/1/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductCategory1 : NSObject
@property (retain, nonatomic) NSString * code;
@property (retain, nonatomic) NSString * name;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * productCategory2;
@property (nonatomic) NSInteger productCategory1ID;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

+ (NSArray *)getProductCategory1List:(NSString *)productCategory2Code;
@end
