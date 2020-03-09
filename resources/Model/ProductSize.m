//
//  ProductSize.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/1/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductSize.h"
#import "SharedProductSize.h"


@implementation ProductSize
- (id)copyWithZone:(NSZone *)zone
{
    // Copying code here.
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setCode:[self.code copyWithZone:zone]];
        [copy setSizeLabel:[self.sizeLabel copyWithZone:zone]];
        [copy setSizeOrder:[self.sizeOrder copyWithZone:zone]];
        [copy setModifiedDate:[self.modifiedDate copyWithZone:zone]];
    }
    
    return copy;
}

+(ProductSize *)getProductSize:(NSString *)code
{
    NSMutableArray *productSizeList = [SharedProductSize sharedProductSize].productSizeList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_code = %@",code];
    NSArray *filterArray = [productSizeList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}
@end
