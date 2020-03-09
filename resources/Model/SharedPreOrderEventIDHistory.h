//
//  SharedPreOrderEventIDHistory.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 8/3/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedPreOrderEventIDHistory : NSObject
@property (retain, nonatomic) NSMutableArray * preOrderEventIDHistoryList;
+ (SharedPreOrderEventIDHistory *)sharedPreOrderEventIDHistory;
@end
