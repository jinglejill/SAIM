//
//  ProductCategory2.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/1/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductCategory2.h"
#import "SharedProductCategory2.h"

@implementation ProductCategory2
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
+(NSArray *)getProductCategory2List
{
    NSMutableArray *productCategory2List = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [productCategory2List sortedArrayUsingDescriptors:sortDescriptors];
    return  sortArray;
}

+ (NSMutableArray *)getProductCategory2SortByOrderNo:(NSMutableArray *)productCategory2List
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_orderNo" ascending:YES];
    NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortedArray = [productCategory2List sortedArrayUsingDescriptors:sortDescriptors1];
    return [sortedArray mutableCopy];
}

+ (ProductCategory2 *)getProductCategory2:(NSString *)code
{
    NSMutableArray *productCategory2List = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_code = %@",code];
    NSArray *filterArray = [productCategory2List filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}
@end
