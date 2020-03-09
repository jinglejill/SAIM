//
//  ItemRunningID.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 7/8/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemRunningID : NSObject
@property (retain, nonatomic) NSString * runningID;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete
@end
