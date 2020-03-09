//
//  TransferHistory.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/7/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransferHistory : NSObject
@property (nonatomic) NSInteger transferHistoryID;
@property (nonatomic) NSInteger eventID;
@property (retain, nonatomic) NSString * transferDate;
@property (retain, nonatomic) NSString * modifiedDate;


@property (nonatomic) NSInteger row;
@property (retain, nonatomic) NSString * eventName;
@property (retain, nonatomic) NSString * eventNameDestination;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete
+(TransferHistory *)getTransferHistory:(NSInteger)transferHistoryID transferHistoryList:(NSMutableArray *)transferHistoryList;

@end
