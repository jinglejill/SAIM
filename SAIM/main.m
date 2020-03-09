//
//  main.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/7/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

NSArray *globalMessage;
NSString *globalPingAddress;
NSString *globalDomainName;
NSString *globalSubjectNoConnection;
NSString *globalDetailNoConnection;
BOOL globalRotateFromSeg;
BOOL globalFinishLoadSharedData;
NSString *globalCipher;
NSString *globalModifiedUser;
NSNumberFormatter *formatterBaht;
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
