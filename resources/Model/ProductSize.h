//
//  ProductSize.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/1/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductSize : NSObject
@property (retain, nonatomic) NSString * code;
@property (retain, nonatomic) NSString * sizeLabel;
@property (retain, nonatomic) NSString * sizeOrder;
@property (retain, nonatomic) NSString * modifiedDate;
@property (nonatomic) NSInteger intSizeOrder;
@property (nonatomic) BOOL beingUsed;
@property (nonatomic) NSInteger productSizeID;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

+(ProductSize *)getProductSize:(NSString *)code;
@end
