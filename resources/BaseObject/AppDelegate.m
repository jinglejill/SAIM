//
//  AppDelegate.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/7/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeModel.h"
#import "Utility.h"
#import "SignInViewController.h"
#import <objc/runtime.h>
#import "FirstPageViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "PasscodeViewController.h"
#import "ReceiptSummaryViewController.h"
#import "EventViewController.h"
#import "PushSync.h"
#import "SharedPushSync.h"
#import "Login.h"


#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#import "UserAccount.h"
#import "ProductName.h"
#import "Color.h"
#import "Product.h"
#import "Event.h"
#import "UserAccountEvent.h"
#import "ProductCategory2.h"
#import "ProductCategory1.h"
#import "ProductSales.h"
#import "CashAllocation.h"
#import "CustomMade.h"
#import "Receipt.h"
#import "ReceiptProductItem.h"
#import "CompareInventoryHistory.h"
#import "CompareInventory.h"
#import "ProductSalesSet.h"
#import "CustomerReceipt.h"
#import "PostCustomer.h"
#import "ProductCost.h"
#import "EventCost.h"
#import "CostLabel.h"
#import "ProductSize.h"
#import "ImageRunningID.h"
#import "ProductDelete.h"
#import "Setting.h"
#import "Credentials.h"
#import "CredentialsDevice.h"



@interface AppDelegate (){
    HomeModel *_homeModel;
}
@end

extern BOOL globalRotateFromSeg;



@implementation AppDelegate
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (void)photoUploaded
{
    
}

void myExceptionHandler(NSException *exception)
{
    
    NSString *stackTrace = [[[exception callStackSymbols] valueForKey:@"description"] componentsJoinedByString:@"\\n"];
    stackTrace = [NSString stringWithFormat:@"%@,%@\\n%@\\n%@",[Utility modifiedUser],[Utility deviceToken],exception.reason,stackTrace];
    NSLog(@"Stack Trace callStackSymbols: %@", stackTrace);
    
    [[NSUserDefaults standardUserDefaults] setValue:stackTrace forKey:@"exception"];

}

    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIBarButtonItem *barButtonAppearance = [UIBarButtonItem appearance];
    [barButtonAppearance setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault]; // Change to your colour
//        [barButtonAppearance setBackButtonBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    
    
    [Utility setFinishLoadSharedData:NO];
    _homeModel = [[HomeModel alloc]init];
    _homeModel.delegate = self;
    
    
    globalRotateFromSeg = NO;
    
    // Override point for customization after application launch.
    NSString *strplistPath = [[NSBundle mainBundle] pathForResource:@"Property List" ofType:@"plist"];
    
    // read property list into memory as an NSData  object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:strplistPath];
    NSError *strerrorDesc = nil;
    NSPropertyListFormat plistFormat;
    
    // convert static property list into dictionary object
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&plistFormat error:&strerrorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %lu", strerrorDesc, (unsigned long)plistFormat);
    } else {
        // assign values
    
        [Utility setPingAddress:[temp objectForKey:@"PingAddress"]];
        [Utility setDomainName:[temp objectForKey:@"DomainName"]];
        [Utility setSubjectNoConnection:[temp objectForKey:@"SubjectNoConnection"]];
        [Utility setDetailNoConnection:[temp objectForKey:@"DetailNoConnection"]];
        [Utility setCipher:[temp objectForKey:@"Cipher"]];
    
    }
    
    
    //write exception of latest app crash to log file
    NSSetUncaughtExceptionHandler(&myExceptionHandler);
    NSString *stackTrace = [[NSUserDefaults standardUserDefaults] stringForKey:@"exception"];
    if(![stackTrace isEqualToString:@""])
    {
        [_homeModel insertItems:dbWriteLog withData:stackTrace];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"exception"];
    }
    
    
    //push notification
    {
        if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0"))
        {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
                if( !error )
                {
                    NSLog(@"request authorization succeeded!");
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                }
            }];
        }
        else
        {
            UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [application registerUserNotificationSettings:settings];
            [application registerForRemoteNotifications];
        }
    }
    
    
    //load shared at the begining of everyday
    NSDictionary *todayLoadShared = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"todayLoadShared"];
    NSString *strCurrentDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd"];
    NSString *alreadyLoaded = [todayLoadShared objectForKey:strCurrentDate];
    if(!alreadyLoaded)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObject:@"1" forKey:strCurrentDate] forKey:@"todayLoadShared"];        
    }
    
    return YES;
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //Called when a notification is delivered to a foreground app.
    
    NSLog(@"Userinfo %@",notification.request.content.userInfo);
    
    
    if(![Utility finishLoadSharedData])
    {
        return;
    }
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Received notification: %@", userInfo);
    
    
    NSDictionary *myAps;
    for(id key in userInfo)
    {
        myAps = [userInfo objectForKey:key];
    }
    

    NSNumber *badge = [myAps objectForKey:@"badge"];
    if([badge integerValue] == 0)
    {
        //check timesynced = null where devicetoken = [Utility deviceToken];
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel syncItems:dbPushSync withData:pushSync];
        NSLog(@"syncitems");
    }
}


-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    //Called to let your app know which action was selected by the user for a given notification.
    
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"link successful");
        }
        return YES;
    }
    return NO;
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"])
    {
        NSLog(@"decline action");
    }
    else if ([identifier isEqualToString:@"answerAction"])
    {
        NSLog(@"answer action");
    }
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [self stringFromDeviceToken:deviceToken];
//    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"token---%@", token);
    //    globalDeviceToken = token;
    
    
    
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //    NSLog([error localizedDescription]);
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    NSLog(@"didRegisterUserNotificationSettings");
}
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    if(![Utility finishLoadSharedData])
    {
        return;
    }
    
    
    NSLog(@"Received notification: %@", userInfo);
    NSDictionary *myAps;
    for(id key in userInfo)
    {
        myAps = [userInfo objectForKey:key];
    }
    
    
    NSNumber *badge = [myAps objectForKey:@"badge"];
    if([badge integerValue] == 0)
    {
        //check timesynced = null where devicetoken = [Utility deviceToken];
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel syncItems:dbPushSync withData:pushSync];
        NSLog(@"syncitems");
    }
}

- (NSString *)stringFromDeviceToken:(NSData *)deviceToken {
    NSUInteger length = deviceToken.length;
    if (length == 0) {
        return nil;
    }
    const unsigned char *buffer = deviceToken.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(length * 2)];
    for (int i = 0; i < length; ++i) {
        [hexString appendFormat:@"%02x", buffer[i]];
    }
    return [hexString copy];
}

- (void)itemsSynced:(NSArray *)items
{
    NSMutableArray *pushSyncList = [[NSMutableArray alloc]init];
    for(int j=0; j<[items count]; j++)
    {
        NSDictionary *payload = items[j];
        NSString *type = [payload objectForKey:@"type"];
        NSString *action = [payload objectForKey:@"action"];
        NSString *strPushSyncID = [payload objectForKey:@"pushSyncID"];
        NSArray *data = [payload objectForKey:@"data"];
        
        
        //เช็คว่าเคย sync pushsyncid นี้ไปแล้วยัง
        if([Utility alreadySynced:[strPushSyncID integerValue]])
        {
            continue;
        }
        else
        {
            //update shared ใช้ในกรณี เรียก homemodel > 1 อันต่อหนึ่ง click คำสั่ง ซึ่งทำให้เกิดการ เรียก function syncitems ตัวที่ 2 ก่อนเกิดการ update timesynced จึงทำให้เกิดการเบิ้ล sync
            PushSync *pushSync = [[PushSync alloc]initWithPushSyncID:[strPushSyncID integerValue]];
            [PushSync addObject:pushSync];
            [pushSyncList addObject:pushSync];
        }
        

        if([type isEqualToString:@"adminconflict"])
        {
            UINavigationController * navigationController = self.navController;
            UIViewController *viewController = navigationController.visibleViewController;
            
            //you have login in another device และ unwind to หน้า passcode
            if([self stayInAdminMenu] && ![viewController isKindOfClass:[PasscodeViewController class]])
            {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Conflict"
                                                                               message:@"Another device is using admin menu"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action)
                                                {
                                                    for (UIViewController *vc in navigationController.viewControllers) {
                                                        if ([vc isKindOfClass:[PasscodeViewController class]]) {
                                                            [navigationController popToViewController:vc animated:YES];
                                                        }
                                                    }
                                                }];
                
                [alert addAction:defaultAction];
                [viewController presentViewController:alert animated:YES completion:nil];
            }
        }
        else if([type isEqualToString:@"usernameconflict"])
        {
            
            UINavigationController * navigationController = self.navController;
            UIViewController *viewController = navigationController.visibleViewController;
            
            //you have login in another device และ unwind to หน้า sign in
            if([self stayInUserMenu] && ![viewController isKindOfClass:[SignInViewController class]])
            {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Conflict"
                                                                               message:@"Another device log in with this username"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action)
                                                {
                                                    for (UIViewController *vc in navigationController.viewControllers) {
                                                        if ([vc isKindOfClass:[SignInViewController class]]) {
                                                            [navigationController popToViewController:vc animated:YES];
                                                        }
                                                    }
                                                }];
                
                [alert addAction:defaultAction];
                [viewController presentViewController:alert animated:YES completion:nil];
            }
        }
        else if([type isEqualToString:@"alert"])
        {
            
            UINavigationController * navigationController = self.navController;
            UIViewController *viewController = navigationController.visibleViewController;
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getSqlFailTitle]
                                                                           message:[Utility getSqlFailMessage]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action)
                                            {
                                                SEL s = NSSelectorFromString(@"loadingOverlayView");
                                                [viewController performSelector:s];
                                                [_homeModel downloadItems:dbMaster];
                                            }];
            
            [alert addAction:defaultAction];
            [viewController presentViewController:alert animated:YES completion:nil];
        }
        else if([type isEqualToString:@"alertUploadPhotoFail"])
        {
            
            UINavigationController * navigationController = self.navController;
            UIViewController *viewController = navigationController.visibleViewController;
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Fail"
                                                                           message:@"Upload photo fail"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action)
                                            {
                                            }];
            
            [alert addAction:defaultAction];
            [viewController presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            if([data isKindOfClass:[NSArray class]])
            {
                [Utility itemsSynced:type action:action data:data];
            }
        }
    }
    
    
    //update pushsync ที่ sync แล้ว
    if([pushSyncList count]>0)
    {
        [_homeModel updateItems:dbPushSyncUpdateTimeSynced withData:pushSyncList];
    }
    
    
    
    
    //ให้ refresh ข้อมูลที่ Show ที่หน้านั้นหลังจาก sync ข้อมูลมาใหม่ ตอนนี้ทำเฉพาะหน้า ReceiptSummaryViewController ก่อน
    if([items count] > 0)
    {
        for(int j=0; j<[items count]; j++)
        {
            NSDictionary *payload = items[j];
            NSString *type = [payload objectForKey:@"type"];
            if([type isEqualToString:@"adminconflict"] || [type isEqualToString:@"usernameconflict"] || [type isEqualToString:@"alert"] || [type isEqualToString:@"alertPhotoUploadFail"])
            {
                continue;
            }
            else
            {
                UINavigationController * navigationController = self.navController;
                UIViewController *viewController = navigationController.visibleViewController;
                if([viewController isMemberOfClass:[ReceiptSummaryViewController class]])//check กรณีเดียวก่อนคือ ReceiptSummaryViewController
                {
                    NSLog(@"staying at ReceiptSummaryViewController");
                    NSArray *arrReferenceTable = @[@"tProduct",@"tCashAllocation",@"tCustomMade",@"tReceipt",@"tReceiptProductItem",@"tCustomerReceipt",@"tPostCustomer",@"tPreOrderEventIDHistory"];
                    if([arrReferenceTable containsObject:type])
                    {
                        {
                            SEL s = NSSelectorFromString(@"loadingOverlayView");
                            if([viewController respondsToSelector:s])
                            {
                                [viewController performSelector:s];
                            }
                        }
                        
                        {
                            SEL s = NSSelectorFromString(@"loadViewProcess");
                            if([viewController respondsToSelector:s])
                            {
                                [viewController performSelector:s];
                            }
                        }
                        {
                            SEL s = NSSelectorFromString(@"removeOverlayViews");
                            if([viewController respondsToSelector:s])
                            {
                                [viewController performSelector:s];
                            }
                        }
                        break;
                    }
                }
                else if([viewController isMemberOfClass:[EventViewController class]])
                {
                    NSArray *arrReferenceTable = @[@"tEvent"];
                    if([arrReferenceTable containsObject:type])
                    {
                        {
                            SEL s = NSSelectorFromString(@"loadingOverlayView");
                            if([viewController respondsToSelector:s])
                            {
                                [viewController performSelector:s];
                            }
                        }
                        
                        {
                            SEL s = NSSelectorFromString(@"loadViewProcess");
                            if([viewController respondsToSelector:s])
                            {
                                [viewController performSelector:s];
                            }
                        }
                        {
                            SEL s = NSSelectorFromString(@"removeOverlayViews");
                            if([viewController respondsToSelector:s])
                            {
                                [viewController performSelector:s];
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
}

- (BOOL)stayInUserMenu
{
    UINavigationController * navigationController = self.navController;
    for (UIViewController *vc in navigationController.viewControllers) {
        if ([vc isKindOfClass:[PasscodeViewController class]]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)stayInAdminMenu
{
    UINavigationController * navigationController = self.navController;
    for (UIViewController *vc in navigationController.viewControllers) {
        if ([vc isKindOfClass:[PasscodeViewController class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)itemsUpdated
{
    
}

- (void)itemsInserted
{
    
}

- (void)itemsDeleted
{
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if(![Utility finishLoadSharedData])
    {
        return;
    }
    
    
    //load shared at the begining of everyday
    NSDictionary *todayLoadShared = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"todayLoadShared"];
    NSString *strCurrentDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd"];
    NSString *alreadyLoaded = [todayLoadShared objectForKey:strCurrentDate];
    NSString *alreadyLoadedtest = [todayLoadShared objectForKey:@"2017-04-10"];
    if(!alreadyLoaded)
    {
        //download dbMaster
        UINavigationController * navigationController = self.navController;
        UIViewController *viewController = navigationController.visibleViewController;
        SEL s = NSSelectorFromString(@"loadingOverlayView");
        [viewController performSelector:s];
        
        [_homeModel downloadItems:dbMaster];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObject:@"1" forKey:strCurrentDate] forKey:@"todayLoadShared"];
        
    }
    else
    {
        //check timesynced = null where devicetoken = [Utility deviceToken];
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel syncItems:dbPushSync withData:pushSync];
        NSLog(@"syncitems");
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)itemsDownloaded:(NSArray *)items
{
    UINavigationController * navigationController = self.navController;
    UIViewController *viewController = navigationController.visibleViewController;
    {
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
    }
    
    
    [Utility itemsDownloaded:items];
    {
        SEL s = NSSelectorFromString(@"removeOverlayViews");
        [viewController performSelector:s];
    }
    {
        SEL s = NSSelectorFromString(@"loadViewProcess");
        [viewController performSelector:s];
    }
}

- (void)itemsFail
{
    UINavigationController * navigationController = self.navController;
    UIViewController *viewController = navigationController.visibleViewController;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        SEL s = NSSelectorFromString(@"loadingOverlayView");
                                        [viewController performSelector:s];
                                        [_homeModel downloadItems:dbMaster];
                                    }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [viewController presentViewController:alert animated:YES completion:nil];
    });
}

- (void) connectionFail
{
    UINavigationController * navigationController = self.navController;
    UIViewController *viewController = navigationController.visibleViewController;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility subjectNoConnection]
                                                                   message:[Utility detailNoConnection]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //                                                              exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [viewController presentViewController:alert animated:YES completion:nil];
    } );
}
@end
