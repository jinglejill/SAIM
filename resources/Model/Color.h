//
//  Color.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Color : NSObject
@property (retain, nonatomic) NSString * code;
@property (retain, nonatomic) NSString * name;
@property (retain, nonatomic) NSString * modifiedDate;
@property (nonatomic) BOOL beingUsed;
@property (nonatomic) NSInteger colorID;

@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

+(Color *)getColor:(NSString *)code;
@end
