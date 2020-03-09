//
//  SharedEvent.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/18/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedEvent : NSObject
@property (retain, nonatomic) NSMutableArray * eventList;
+ (SharedEvent *)sharedEvent;
@end
