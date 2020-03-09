//
//  SharedSetting.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/30/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedSetting.h"

@implementation SharedSetting
@synthesize settingList;

+(SharedSetting *)sharedSetting {
    static dispatch_once_t pred;
    static SharedSetting *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedSetting alloc] init];
        shared.settingList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
