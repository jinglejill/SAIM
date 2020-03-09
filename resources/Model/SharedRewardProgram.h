//
//  SharedRewardProgram.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 1/2/2560 BE.
//  Copyright © 2560 Appxelent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedRewardProgram : NSObject
@property (retain, nonatomic) NSMutableArray * rewardProgramList;
+ (SharedRewardProgram *)sharedRewardProgram;
@end
