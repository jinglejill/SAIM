//
//  WordPressUser.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 18/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WordPressUser : NSObject
@property (nonatomic) NSInteger iD;
@property (retain, nonatomic) NSString * user_login;
@property (retain, nonatomic) NSString * user_nicename;
@property (retain, nonatomic) NSString * user_email;
@property (retain, nonatomic) NSDate * user_registered;
@property (retain, nonatomic) NSString * display_name;
@property (nonatomic) NSInteger totalPoints;
@property (retain, nonatomic) NSString * phone;
@property (nonatomic) NSInteger totalBaht;
@property (nonatomic) NSInteger pointPerBaht;
@property (nonatomic) NSInteger minimumPointSpend;
@end

NS_ASSUME_NONNULL_END
