//
//  SharedMainEvent.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 7/22/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"


@interface SharedMainEvent : NSObject
@property (retain, nonatomic) Event *event;

+ (SharedMainEvent *)sharedMainEvent;

@end
