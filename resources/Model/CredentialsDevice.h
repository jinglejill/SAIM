//
//  CredentialsDevice.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 8/3/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialsDevice : NSObject
@property (retain, nonatomic) NSString * credentialsDeviceID;
@property (retain, nonatomic) NSString * credentialsID;
@property (retain, nonatomic) NSString * deviceToken;
@property (retain, nonatomic) NSString * countSetup;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

@end
