//
//  ReplaceReason.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 29/1/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReplaceReason : NSObject
@property (nonatomic) NSInteger code;
@property (nonatomic) NSString *reason;

+(NSArray *)getReplaceReasonList;
@end

NS_ASSUME_NONNULL_END
