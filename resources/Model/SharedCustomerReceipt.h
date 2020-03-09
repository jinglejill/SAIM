//
//  SharedCustomerReceipt.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/11/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedCustomerReceipt : NSObject
@property (retain, nonatomic) NSMutableArray * customerReceiptList;

+ (SharedCustomerReceipt *)sharedCustomerReceipt;

@end
