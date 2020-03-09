//
//  ProductCategory1.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/1/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductCategory1.h"
#import "SharedProductCategory1.h"

@implementation ProductCategory1
- (id)copyWithZone:(NSZone *)zone
{
    // Copying code here.
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setCode:[self.code copyWithZone:zone]];
        [copy setName:[self.name copyWithZone:zone]];
        [copy setProductCategory2:[self.productCategory2 copyWithZone:zone]];
        [copy setModifiedDate:[self.modifiedDate copyWithZone:zone]];
    }
    
    return copy;
}
+ (NSArray *)getProductCategory1List:(NSString *)productCategory2Code
{
    NSMutableArray *productCategory1List = [SharedProductCategory1 sharedProductCategory1].productCategory1List;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2Code];
    NSArray *filterArray = [productCategory1List filteredArrayUsingPredicate:predicate1];
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    
    
    return sortArray;
}
@end
