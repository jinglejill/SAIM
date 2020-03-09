//
//  SharedCostLabel.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/24/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedCostLabel : NSObject
@property (retain, nonatomic) NSMutableArray * costLabelList;

+ (SharedCostLabel *)sharedCostLabel;

@end
