//
//  SharedRewardPoint.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 11/8/2559 BE.
//  Copyright © 2559 Appxelent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedRewardPoint : NSObject
@property (retain, nonatomic) NSMutableArray * rewardPointList;
+ (SharedRewardPoint *)sharedRewardPoint;
@end
