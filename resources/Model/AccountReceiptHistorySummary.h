//
//  AccountReceiptHistorySummary.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 3/6/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountReceiptHistorySummary : NSObject
@property (retain, nonatomic) NSString *productName;
@property (nonatomic) float quantity;
@property (nonatomic) float sales;
@end
