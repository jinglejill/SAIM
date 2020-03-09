//
//  EventCost.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/24/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "EventCost.h"

@implementation EventCost
- (id)copyWithZone:(NSZone *)zone
{
    // Copying code here.
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        ((EventCost *)copy).eventCostID = self.eventCostID;
        [copy setEventID:[self.eventID copyWithZone:zone]];
        [copy setCostLabelID:[self.costLabelID copyWithZone:zone]];
        [copy setCost:[self.cost copyWithZone:zone]];
        [copy setModifiedDate:[self.modifiedDate copyWithZone:zone]];
        [copy setCostLabel:[self.costLabel copyWithZone:zone]];
        [copy setFloatCost:self.floatCost];
    }
    
    return copy;
}
@end


