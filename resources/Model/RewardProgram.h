//
//  RewardProgram.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 1/2/2560 BE.
//  Copyright © 2560 Appxelent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RewardProgram : NSObject
@property (nonatomic) NSInteger rewardProgramID;
@property (nonatomic) NSInteger type;//0=collect,1=use
@property (retain, nonatomic) NSString * dateStart;
@property (retain, nonatomic) NSString * dateEnd;
@property (nonatomic) NSInteger salesSpent;
@property (nonatomic) NSInteger receivePoint;
@property (nonatomic) NSInteger pointSpent;
@property (nonatomic) NSInteger discountType;
@property (nonatomic) float discountAmount;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

- (id)initWithRewardProgramID:(NSInteger)rewardProgramID type:(NSInteger)type dateStart:(NSString *)dateStart dateEnd:(NSString *)dateEnd salesSpent:(NSInteger)salesSpent receivePoint:(NSInteger)receivePoint pointSpent:(NSInteger)pointSpent discountType:(NSInteger)discountType discountAmount:(float)discountAmount modifiedDate:(NSString *)modifiedDate;
+(RewardProgram *)getRewardProgramCurrentCollect;
+(RewardProgram *)getRewardProgramCurrentUse;
+(RewardProgram *)getRewardProgram:(NSInteger)rewardProgramID;
+(void)addRewardProgram:(RewardProgram *)rewardProgram;
+(void)addRewardProgramList:(NSMutableArray *)rewardProgramList;
+(void)deleteRewardProgram:(RewardProgram *)rewardProgram;
+(NSMutableArray *)getRewardProgramCollectListDateStart:(NSString *)strDateStart dateEnd:(NSString *)strDateEnd;
+(NSMutableArray *)getRewardProgramUseListDateStart:(NSString *)strDateFrom dateEnd:(NSString *)strDateTo;
+(NSMutableArray *)getRewardProgramListSortByDateStartDateEnd:(NSMutableArray *)rewardProgramList;
@end
