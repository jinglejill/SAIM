//
//  PostCode.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 10/6/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostCode : NSObject
@property (nonatomic) NSInteger postcodeID;
@property (strong, nonatomic) NSString * zone;
@property (strong, nonatomic) NSString * district;
@property (strong, nonatomic) NSString * postcode;
@property (strong, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete
@end
