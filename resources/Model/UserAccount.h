//
//  UserAccount.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/10/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAccount : NSObject

@property (nonatomic) NSInteger userAccountID;
@property (retain, nonatomic) NSString * username;
@property (retain, nonatomic) NSString * password;
@property (retain, nonatomic) NSString * deviceToken;
@property (retain, nonatomic) NSString * pushOnSale;
@property (retain, nonatomic) NSString * countNotSeen;
@property (retain, nonatomic) NSString * menuExtra;
@property (retain, nonatomic) NSString * modifiedDate;

@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

+(UserAccount *)getUserAccount:(NSInteger)userAccountID;
+(UserAccount *)getUserAccountByUsername:(NSString *)username;
+(BOOL) checkUsernameExist:(NSString *)username;
- (id)copyWithZone:(NSZone *)zone;
@end
