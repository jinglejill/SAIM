//
//  PushSync.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 5/3/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "PushSync.h"
#import "SharedPushSync.h"


@implementation PushSync
-(PushSync *)initWithPushSyncID:(NSInteger)pushSyncID
{
    self = [super init];
    if(self)
    {
        self.pushSyncID = pushSyncID;
    }
    return self;
}

+(void)addObject:(PushSync *)pushSync
{
    NSMutableArray *pushSyncList = [SharedPushSync sharedPushSync].pushSyncList;
    [pushSyncList addObject:pushSync];
}
@end
