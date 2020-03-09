//
//  SharedCostLabel.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/24/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedCostLabel.h"

@implementation SharedCostLabel
@synthesize costLabelList;

+(SharedCostLabel *)sharedCostLabel {
    static dispatch_once_t pred;
    static SharedCostLabel *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedCostLabel alloc] init];
        shared.costLabelList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
