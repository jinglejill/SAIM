//
//  SharedSetting.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/30/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedSetting : NSObject
@property (retain, nonatomic) NSMutableArray * settingList;
+ (SharedSetting *)sharedSetting;
@end
