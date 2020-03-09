//
//  SharedImageRunningID.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/16/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedImageRunningID : NSObject
@property (retain, nonatomic) NSMutableArray * imageRunningIDList;
+ (SharedImageRunningID *)sharedImageRunningID;

@end
