//
//  UserAccount.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/10/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "UserAccount.h"
#import "SharedUserAccount.h"

@implementation UserAccount

- (id)copyWithZone:(NSZone *)zone
{
    // Copying code here.
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        ((UserAccount *)copy).userAccountID = self.userAccountID;
        [copy setUsername:[self.username copyWithZone:zone]];
        [copy setPassword:[self.password copyWithZone:zone]];
        [copy setDeviceToken:[self.deviceToken copyWithZone:zone]];
        [copy setPushOnSale:[self.pushOnSale copyWithZone:zone]];
        [copy setCountNotSeen:[self.countNotSeen copyWithZone:zone]];
        [copy setMenuExtra:[self.menuExtra copyWithZone:zone]];
        [copy setModifiedDate:[self.modifiedDate copyWithZone:zone]];
    }
    
    return copy;
}
+(UserAccount *)getUserAccount:(NSInteger)userAccountID
{
    NSMutableArray *userAccountList = [SharedUserAccount sharedUserAccount].userAccountList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_userAccountID = %ld",userAccountID];
    NSArray *filterArray = [userAccountList filteredArrayUsingPredicate:predicate1];
    if([filterArray count] > 0)
    {
        return  filterArray[0];
    }
    return nil;
}
+(UserAccount *)getUserAccountByUsername:(NSString *)username
{
    NSMutableArray *userAccountList = [SharedUserAccount sharedUserAccount].userAccountList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_username = %@",username];
    NSArray *filterArray = [userAccountList filteredArrayUsingPredicate:predicate1];
    if([filterArray count] > 0)
    {
        return  filterArray[0];
    }
    return nil;
}
+(BOOL) checkUsernameExist:(NSString *)username
{
    UserAccount *userAccount = [UserAccount getUserAccountByUsername:username];
    if(!userAccount)
    {
        return NO;
    }
    return YES;
}

@end
