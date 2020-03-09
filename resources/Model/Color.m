//
//  Color.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "Color.h"
#import "SharedColor.h"


@implementation Color
- (id)copyWithZone:(NSZone *)zone
{
    // Copying code here.
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setCode:[self.code copyWithZone:zone]];
        [copy setName:[self.name copyWithZone:zone]];
        [copy setModifiedDate:[self.modifiedDate copyWithZone:zone]];
    }
    
    return copy;
}

+(Color *)getColor:(NSString *)code
{
    NSMutableArray *colorList = [SharedColor sharedColor].colorList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_code = %@",code];
    NSArray *filterArray = [colorList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}
@end
