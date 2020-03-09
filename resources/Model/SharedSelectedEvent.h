//
//  SharedSelectedEvent.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/11/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface SharedSelectedEvent : NSObject
@property (retain, nonatomic) Event *event;

+ (SharedSelectedEvent *)sharedSelectedEvent;

@end
