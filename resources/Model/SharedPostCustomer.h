//
//  SharedPostCustomer.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedPostCustomer : NSObject
@property (retain, nonatomic) NSMutableArray * postCustomerList;

+ (SharedPostCustomer *)sharedPostCustomer;

@end
