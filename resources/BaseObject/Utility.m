//
//  Utility.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/14/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "Utility.h"
#import "Message.h"
#import "Setting.h"
//#import "RNEncryptor.h"
//#import "RNDecryptor.h"
#import "Event.h"
#import <objc/runtime.h>
#import "ProductWithQuantity.h"
#import "ProductName.h"
#import "Color.h"
#import "ProductSource.h"
#import "ProductSales.h"
#import "CustomMade.h"
#import "ProductSalesSet.h"
#import "ProductSize.h"
#import "CustomerReceipt.h"
#import "PostCustomer.h"
#import "ReceiptProductItem.h"
#import "ImageRunningID.h"
#import "ProductCategory2.h"
#import "ProductCategory1.h"
#import "UserAccountEvent.h"
#import "SharedPushSync.h"
#import "Login.h"
#import "HomeModel.h"
#import "CompareInventoryHistory.h"
#import "CompareInventory.h"
#import "EventCost.h"
#import "ProductDelete.h"
#import "CashAllocation.h"
#import "RewardPoint.h"
#import "RewardProgram.h"
#import "PreOrderEventIDHistory.h"


#import "SharedEventSales.h"
#import "SharedUserAccount.h"
#import "SharedProductName.h"
#import "SharedColor.h"
#import "SharedProduct.h"
#import "SharedEvent.h"
#import "SharedUserAccountEvent.h"
#import "SharedProductCategory2.h"
#import "SharedProductCategory1.h"
#import "SharedProductSales.h"
#import "SharedCashAllocation.h"
#import "SharedCustomMade.h"
#import "SharedReceipt.h"
#import "SharedReceiptItem.h"
#import "SharedCompareInventoryHistory.h"
#import "SharedCompareInventory.h"
#import "SharedProductSalesSet.h"
#import "SharedCustomerReceipt.h"
#import "SharedPostCustomer.h"
#import "SharedProductCost.h"
#import "SharedEventCost.h"
#import "SharedCostLabel.h"
#import "SharedProductSize.h"
#import "SharedImageRunningID.h"
#import "SharedProductDelete.h"
#import "SharedSetting.h"
#import "SharedPostCode.h"
#import "SharedRewardPoint.h"
#import "SharedRewardProgram.h"
#import "SharedPreOrderEventIDHistory.h"

#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

extern NSArray *globalMessage;
extern NSString *globalPingAddress;
extern NSString *globalDomainName;
extern NSString *globalSubjectNoConnection;
extern NSString *globalDetailNoConnection;
extern NSNumberFormatter *formatterBaht;
extern BOOL globalFinishLoadSharedData;
extern NSString *globalCipher;
extern NSString *globalModifiedUser;


@implementation Utility
+ (NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])] ];
    }
    
    return randomString;
}

+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSString *) msg:(enum enumMessage)eMessage
{
    for(InAppMessage *item in globalMessage)
    {
        if([item.enumNo integerValue] == eMessage)
        {
            return item.message;
        }
    }

    return @"-";
}

+ (NSString *) setting:(enum enumSetting)eSetting
{
    NSMutableArray *settingList = [SharedSetting sharedSetting].settingList;
    for(Setting *item in settingList)
    {
        if(item.settingID == eSetting)
        {
            return item.value;
        }
    }
    return @"-";
}

+ (void) setPingAddress:(NSString *)pingAddress
{
    globalPingAddress = pingAddress;
}

+ (NSString *) pingAddress
{
    return globalPingAddress;
}

+ (void) setDomainName:(NSString *)domainName
{
    globalDomainName = domainName;
}

+ (NSString *) domainName
{
    return globalDomainName;
}

+ (void) setSubjectNoConnection:(NSString *)subjectNoConnection
{
    globalSubjectNoConnection = subjectNoConnection;
}

+ (NSString *) subjectNoConnection
{
    return globalSubjectNoConnection;
}

+ (void) setDetailNoConnection:(NSString *)detailNoConnection
{
    globalDetailNoConnection = detailNoConnection;
}

+ (NSString *) detailNoConnection
{
    return globalDetailNoConnection;
}

+ (NSString *) deviceToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN];
}

+ (NSInteger) deviceID
{
    NSString *strDeviceID = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"];
    return [strDeviceID integerValue];
}

+ (NSString *) dbName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
}

+ (BOOL) finishLoadSharedData
{
    return globalFinishLoadSharedData;
}

+ (void) setFinishLoadSharedData:(BOOL)finish
{
    globalFinishLoadSharedData = finish;
}

+ (NSString *) url:(enum enumUrl)eUrl
{    
    NSString *url = [[NSString alloc]init];
    switch (eUrl)
    {
        case urlUserAccountInsert:
            url = @"/SAIM/SAIMUserAccountInsert.php";
            break;
        case urlUserAccountUpdate:
            url = @"/SAIM/SAIMUserAccountUpdate.php";
            break;
        case urlUserAccountDelete:
            url = @"/SAIM/SAIMUserAccountDelete.php";
            break;
        case urlMessageGet:
            url = @"/SAIM/SAIMMessageGet.php?%@";
            break;
        case urlSendEmail:
            url = @"/SAIM/sendEmail.php";
            break;
        case urlEventInsert:
            url = @"/SAIM/SAIMEventInsert.php";
            break;
        case urlEventUpdate:
            url = @"/SAIM/SAIMEventUpdate.php";
            break;
        case urlEventDelete:
            url = @"/SAIM/SAIMEventDelete.php";
            break;
        case urlProductInsert:
            url = @"/SAIM/SAIMProductInsert.php";
            break;
        case urlProductUpdate:
            url = @"/SAIM/SAIMProductUpdate.php";
            break;
        case urlProductDelete:
            url = @"/SAIM/SAIMProductDelete.php";
            break;
        case urlCashAllocationInsert:
            url = @"/SAIM/SAIMCashAllocationInsert.php";
            break;
        case urlCashAllocationUpdate:
            url = @"/SAIM/SAIMCashAllocationUpdate2.php";
            break;
        case urlPostCustomerInsert:
            url = @"/SAIM/SAIMPostCustomerInsert.php";
            break;
        case urlPostCustomerUpdate:
            url = @"/SAIM/SAIMPostCustomerUpdate.php";
            break;
        case urlPostCustomerDelete:
            url = @"/SAIM/SAIMPostCustomerDelete.php";
            break;
        case urlCustomMadeInsert:
            url = @"/SAIM/SAIMCustomMadeInsert.php";
            break;
        case urlCustomMadeDelete:
            url = @"/SAIM/SAIMCustomMadeDelete.php";
            break;
        case urlProductEventIDUpdate:
            url = @"/SAIM/SAIMProductEventIDUpdate.php";
            break;
        case urlProductStatusUpdateByProductID:
            url = @"/SAIM/SAIMProductStatusUpdateByProductID.php";
            break;
        case urlProductEventIDUpdateByProductID:
            url = @"/SAIM/SAIMProductEventIDUpdateByProductID.php";
            break;
        case urlUserAccountEventDeleteThenMultipleInsert:
            url = @"/SAIM/SAIMUserAccountEventDeleteThenMultipleInsert.php";
            break;
        case urlUserAccountEventDelete:
            url = @"/SAIM/SAIMUserAccountEventDelete.php";
            break;
        case urlReceiptAndProductBuyInsert:
            url = @"/SAIM/SAIMReceiptAndProductBuyInsert9.php";
            break;
        case urlReceiptAndReceiptProductItemDelete:
            url = @"/SAIM/SAIMReceiptAndReceiptProductItemDelete4.php";
            break;
        case urlMasterGet:
            url = @"/SAIM/SAIMMasterGet.php?%@";
            break;
        case urlMasterNewGet:
            url = @"/SAIM/SAIMMasterGet.php?%@";
            break;
        case urlReceiptProductItemAndProductUpdate:
            url = @"/SAIM/SAIMReceiptProductItemAndProductUpdate3.php";
            break;
        case urlCompareInventoryInsert:
            url = @"/SAIM/SAIMCompareInventoryInsert.php";
            break;
        case urlCompareInventoryUpdate:
            url = @"/SAIM/SAIMCompareInventoryUpdate.php";
            break;
        case urlCompareInventoryNotMatchInsert:
            url = @"/SAIM/SAIMCompareInventoryNotMatchInsert.php";
            break;
        case urlProductSalesSetInsert:
            url = @"/SAIM/SAIMProductSalesSetInsert.php";
            break;
        case urlProductSalesSetDelete:
            url = @"/SAIM/SAIMProductSalesSetDelete.php";
            break;
        case urlProductSalesSetUpdate:
            url = @"/SAIM/SAIMProductSalesSetUpdate.php";
            break;
        case urlProductSalesUpdate:
            url = @"/SAIM/SAIMProductSalesUpdate.php";
            break;
        case urlProductSalesMultipleUpdate:
            url = @"/SAIM/SAIMProductSalesMultipleUpdate.php";
            break;
        case urlReceiptProductItemPreOrder:
            url = @"/SAIM/SAIMReceiptProductItemPreOrder.php";
            break;
        case urlReceiptProductItemPreOrderCM:
            url = @"/SAIM/SAIMReceiptProductItemPreOrderCM.php";
            break;
        case urlCustomerReceiptUpdatePostCustomerID:
            url = @"/SAIM/SAIMCustomerReceiptUpdatePostCustomerID.php";
            break;
        case urlCustomerReceiptUpdateTrackingNo:
            url = @"/SAIM/SAIMCustomerReceiptUpdateTrackingNo.php";
            break;
        case urlReceiptProductItemUnpost:
            url = @"/SAIM/SAIMReceiptProductItemUnpost.php";
            break;
        case urlReceiptProductItemUnpostCM:
            url = @"/SAIM/SAIMReceiptProductItemUnpostCM.php";
            break;
        case urlProductCostUpdate:
            url = @"/SAIM/SAIMProductCostUpdate.php";
            break;
        case urlEventCostInsert:
            url = @"/SAIM/SAIMEventCostInsert.php";
            break;
        case urlEventCostDelete:
            url = @"/SAIM/SAIMEventCostDelete.php";
            break;
        case urlProductCategory2Delete:
            url = @"/SAIM/SAIMProductCategory2Delete.php";
            break;
        case urlProductCategory2Update:
            url = @"/SAIM/SAIMProductCategory2Update.php";
            break;
        case urlProductCategory2Insert:
            url = @"/SAIM/SAIMProductCategory2Insert.php";
            break;
        case urlProductCategory1Update:
            url = @"/SAIM/SAIMProductCategory1Update.php";
            break;
        case urlProductCategory1Insert:
            url = @"/SAIM/SAIMProductCategory1Insert.php";
            break;
        case urlProductCategory1Delete:
            url = @"/SAIM/SAIMProductCategory1Delete.php";
            break;
        case urlColorDelete:
            url = @"/SAIM/SAIMColorDelete.php";
            break;
        case urlColorUpdate:
            url = @"/SAIM/SAIMColorUpdate.php";
            break;
        case urlColorInsert:
            url = @"/SAIM/SAIMColorInsert.php";
            break;
        case urlProductSizeDelete:
            url = @"/SAIM/SAIMProductSizeDelete.php";
            break;
        case urlProductSizeUpdate:
            url = @"/SAIM/SAIMProductSizeUpdate.php";
            break;
        case urlProductSizeInsert:
            url = @"/SAIM/SAIMProductSizeInsert.php";
            break;
        case urlProductDeleteFromEvent:
            url = @"/SAIM/SAIMProductDeleteFromEvent.php";
            break;
        case urlProductNameDelete:
            url = @"/SAIM/SAIMProductNameDelete.php";
            break;
        case urlProductNameInsert:
            url = @"/SAIM/SAIMProductNameInsert.php";
            break;
        case urlProductNameUpdate:
            url = @"/SAIM/SAIMProductNameUpdate.php";
            break;
        case urlProductSalesInsert:
            url = @"/SAIM/SAIMProductSalesInsert.php";
            break;
        case urlProductSalesDelete:
            url = @"/SAIM/SAIMProductSalesDelete.php";
            break;
        case urlUploadPhoto:
            url = @"/SAIM/uploadPhoto.php";
            break;
        case urlDownloadPhoto:
            url = @"/SAIM/downloadImage.php";
            break;
        case urlProductSalesUpdateDetail:
            url = @"/SAIM/SAIMProductSalesUpdateDetail.php";
            break;
        case urlProductSalesUpdateCost:
            url = @"/SAIM/SAIMProductSalesUpdateCost.php";
            break;
        case urlProductSalesUpdateCostMultiple:
            url = @"/SAIM/SAIMProductSalesUpdateCostMultiple.php";
            break;
        case urlImageRunningIDInsert:
            url = @"/SAIM/SAIMImageRunningIDInsert.php?1";
            break;
        case urlGenerateSalesAllEvent:
            url = @"/SAIM/generateSalesAllEvents.php";
            break;
        case urlDownloadFile:
            url = @"/SAIM/downloadFile.php";
            break;
        case urlProductSalesDeleteProductNameID:
            url = @"/SAIM/SAIMProductSalesDeleteProductNameID.php";
            break;
        case urlUserAccountDeviceTokenUpdate:
            url = @"/SAIM/SAIMUserAccountDeviceTokenUpdate.php";
            break;
        case urlSettingDeviceTokenUpdate:
            url = @"/SAIM/SAIMSettingDeviceTokenUpdate.php";
            break;
        case urlSettingUpdate:
            url = @"/SAIM/SAIMSettingUpdate.php";
            break;
        case urlLoginInsert:
            url = @"/SAIM/SAIMLoginInsert.php";
            break;
//        case urlPushSyncUpdate:
//            url = @"/SAIM/SAIMPushSyncUpdate.php";
//            break;
        case urlPushSyncSync:
            url = @"/SAIM/SAIMPushSyncSync.php";
            break;
        case urlPushSyncUpdateByDeviceToken:
            url = @"/SAIM/SAIMPushSyncUpdateByDeviceToken.php";
            break;
        case urlReceiptUpdate:
            url = @"/SAIM/SAIMReceiptUpdate.php";
            break;
        case urlCustomMadeUpdate:
            url = @"/SAIM/SAIMCustomMadeUpdate.php";
            break;
        case urlReceiptProductItemUpdateCMIn:
            url = @"/SAIM/SAIMReceiptProductItemUpdateCMIn.php";
            break;
        case urlSalesDetailGet:
            url = @"/SAIM/SAIMSalesDetailGet.php?%@";
            break;
        case urlItemRunningIDInsert:
            url = @"/SAIM/SAIMItemRunningIDInsert.php";
            break;
        case urlUserAccountUpdateCountNotSeen:
            url = @"/SAIM/SAIMUserAccountUpdateCountNotSeen.php";
            break;
        case urlCredentialsValidate:
            url = @"/SAIM/SAIMCredentialsValidate.php";
            break;
        case urlProductStatusGet:
            url = @"/SAIM/SAIMProductStatusGet.php";
            break;
        case urlSalesSummaryGet:
            url = @"/SAIM/SAIMSalesSummaryGet.php?%@";
            break;
        case urlSalesSummaryByEventByPeriodGet:
            url = @"/SAIM/SAIMSalesSummaryByEventByPeriodGet.php?%@";
            break;
        case urlSalesSummaryByPeriodGet:
            url = @"/SAIM/SAIMSalesSummaryByPeriodGet.php?%@";
            break;
        case urlDeviceInsert:
            url = @"/SAIM/SAIMDeviceInsert.php";
            break;
        case urlAccountInventoryInsert:
            url = @"/SAIM/SAIMAccountInventoryInsert.php";
            break;
        case urlAccountInventorySummary:
            url = @"/SAIM/SAIMAccountInventorySummaryGet.php?%@";
            break;
        case urlPostCustomerByReceiptID:
            url = @"/SAIM/SAIMPostCustomerByReceiptIDGet.php?%@";
            break;
        case urlAccountReceiptInsert:
            url = @"/SAIM/SAIMAccountReceiptInsert.php";
            break;
        case urlAccountInventoryAdded:
            url = @"/SAIM/SAIMAccountInventoryAddedGet.php?%@";
            break;
        case urlAccountInventoryDelete:
            url = @"/SAIM/SAIMAccountInventoryDelete.php";
            break;
        case urlAccountReceiptHistoryGet:
            url = @"/SAIM/SAIMAccountReceiptHistoryGet.php?%@";
            break;
        case urlAccountReceiptHistoryDelete:
            url = @"/SAIM/SAIMAccountReceiptHistoryDelete.php";
            break;
        case urlAccountReceiptHistoryDetailGet:
            url = @"/SAIM/SAIMAccountReceiptHistoryDetailGet.php?%@";
            break;
        case urlAccountReceiptHistorySummaryGet:
            url = @"/SAIM/SAIMAccountReceiptHistorySummaryGet.php?%@";
            break;
        case urlAccountReceiptHistorySummaryByDateGet:
            url = @"/SAIM/SAIMAccountReceiptHistorySummaryByDateGet.php?%@";
            break;
        case urlSalesByChannelGet:
            url = @"/SAIM/SAIMSalesByChannelGet.php?%@";
            break;
        case urlProductionOrderInsert:
            url = @"/SAIM/SAIMProductionOrderInsert3.php";
            break;
        case urlProductionOrderAdded:
            url = @"/SAIM/SAIMProductionOrderAddedGet.php?%@";
            break;
        case urlProductionOrderDelete:
            url = @"/SAIM/SAIMProductionOrderDelete.php";
            break;
        case urlProductAndProductionOrderInsert:
            url = @"/SAIM/SAIMProductAndProductionOrderInsert.php";
            break;
        case urlMemberAndPointGet:
            url = @"/SAIM/SAIMMemberAndPointGet.php?%@";
            break;
        case urlPushSyncUpdateTimeSynced:
            url = @"/SAIM/SAIMPushSyncUpdateTimeSynced.php";
            break;
        case urlTransferHistoryGet:
            url = @"/SAIM/SAIMTransferHistoryGet.php?%@";
            break;
        case urlProductTransferGet:
            url = @"/SAIM/SAIMProductTransferGet.php?%@";
            break;
        case urlAccountReceiptByPeriod:
            url = @"/SAIM/SAIMAccountReceiptByPeriodGet.php?%@";
            break;
        case urlReceiptByMember:
            url = @"/SAIM/SAIMReceiptByMemberGet.php?%@";
            break;
        case urlRewardProgramGet:
            url = @"/SAIM/SAIMRewardProgramGet.php?%@";
            break;
        case urlRewardProgramInsert:
            url = @"/SAIM/SAIMRewardProgramInsert.php";
            break;
        case urlRewardProgramUpdate:
            url = @"/SAIM/SAIMRewardProgramUpdate.php";
            break;
        case urlRewardProgramDelete:
            url = @"/SAIM/SAIMRewardProgramDelete.php";
            break;
        case urlReceiptProductItemPreOrderEventID:
            url = @"/SAIM/SAIMReceiptProductItemPreOrderEventID.php";
            break;
        case urlWriteLog:
            url = @"/SAIM/SAIMWriteLog.php";
            break;
        case urlAccountReceiptGet:
            url = @"/SAIM/SAIMAccountReceiptGet.php";
            break;
        case urlEmailQRCode:
            url = @"/SAIM/SAIMEmailQRCode.php";
            break;        
        case urlPostDetailSearchGet:
            url = @"/SAIM/SAIMPostDetailSearchGetList3.php";
            break;
        case urlPostDetailToPostGet:
            url = @"/SAIM/SAIMPostDetailToPostGetList4.php";
            break;
        case urlMainInventoryGet:
            url = @"/SAIM/SAIMMainInventoryGet.php";
            break;
        case urlMainInventorySalePriceGet:
            url = @"/SAIM/SAIMMainInventorySalePriceGet.php";
            break;
        case urlMainInventoryItemGet:
            url = @"/SAIM/SAIMMainInventoryItemGet.php";
            break;
        case urlScanUnpostCM:
            url = @"/SAIM/SAIMScanUnpostCM.php";
            break;
        case urlScanUnpost:
            url = @"/SAIM/SAIMScanUnpost2.php";
            break;
        case urlScanPost:
            url = @"/SAIM/SAIMScanPost2.php";
            break;
        case urlPostCustomerGetList:
            url = @"/SAIM/SAIMPostCustomerGetList.php";
            break;
        case urlCustomMadeIn:
            url = @"/SAIM/SAIMCustomMadeInGetList2.php";
            break;
        case urlCustomMadeOut:
            url = @"/SAIM/SAIMCustomMadeOutGetList2.php";
            break;
        case urlSalesForDateGet:
            url = @"/SAIM/SAIMSalesForDateGet4.php";
            break;
        case urlProductDeleteGetList:
            url = @"/SAIM/SAIMProductDeleteGetList.php";
            break;
        case urlProductSalesGetList:
            url = @"/SAIM/SAIMProductSalesGetList.php";
            break;
        case urlPostCustomerSearchGetList:
            url = @"/SAIM/SAIMPostCustomerSearchGetList2.php";
            break;
        case urlEventSalesSummaryGetList:
            url = @"/SAIM/SAIMEventSalesSummaryGetList.php";
            break;
        case urlSearchSalesGetList:
            url = @"/SAIM/SAIMSearchSalesGetList.php";
            break;
        case urlSearchSalesTelephoneGetList:
            url = @"/SAIM/SAIMSearchSalesTelephoneGetList.php";
            break;
        case urlScanDelete:
            url = @"/SAIM/SAIMScanDelete2.php";
            break;
        case urlScanEvent:
            url = @"/SAIM/SAIMScanEvent.php";
            break;
        case urlExpenseDailyGetList:
            url= @"/SAIM/SAIMExpenseDailyGetList.php";
            break;
        case urlExpenseDailyInsert:
            url= @"/SAIM/SAIMExpenseDailyInsert.php";
            break;
        case urlExpenseDailyDelete:
            url= @"/SAIM/SAIMExpenseDailyDelete.php";
            break;
        case urlPostCustomerAddInsert:
            url= @"/SAIM/SAIMPostCustomerAddInsert.php";
            break;
        case urlItemTrackingNoUpdate:
            url= @"/SAIM/SAIMItemTrackingNoUpdate.php";
            break;
        case urlItemTrackingNoPostCustomerAddInsert:
            url= @"/SAIM/SAIMItemTrackingNoPostCustomerAddInsert.php";
            break;
        case urlReportTopSpenderGetList:
            url= @"/SAIM/SAIMReportTopSpenderGetList.php?%@";
            break;
        case urlReportTopSpenderDetailGetList:
            url= @"/SAIM/SAIMReportTopSpenderDetailGetList.php?%@";
            break;
        case urlItemTrackingNoTrackingNoUpdate:
            url= @"/SAIM/SAIMItemTrackingNoTrackingNoUpdate.php";
            break;        
        case urlSearchSalesTelephoneDetailGetList:
            url= @"/SAIM/SAIMSearchSalesTelephoneDetailGetList.php";
            break;
        case urlReceiptReferenceOrderNoUpdate:
            url = @"/SAIM/SAIMReceiptReferenceOrderNoUpdate.php";
            break;
        case urlWordPressRegisterInsert:
            url = @"/SAIM/SAIMWordPressRegisterInsert.php";
            break;
        case urlMainInventoryItemDelete:
            url = @"/SAIM/SAIMMainInventoryItemDelete.php";
            break;
        case urlProductMoveToMainUpdate:
            url = @"/SAIM/SAIMProductMoveToMainUpdate.php";
            break;
        case urlProductMoveToMainItemUpdate:
            url = @"/SAIM/SAIMProductMoveToMainItemUpdate.php";
            break;
        case urlProductMoveToEventUpdate:
            url = @"/SAIM/SAIMProductMoveToEventUpdate.php";
            break;
        case urlProductScanGet:
            url = @"/SAIM/SAIMProductScanGet.php?%@";
            break;
        case urlPreOrderProductGetList:
            url = @"/SAIM/SAIMPreOrderProductGetList.php?%@";
            break;
        case urlProductExcludeGet:
            url = @"/SAIM/SAIMProductExcludeGet.php?%@";
            break;
        case urlMainInventorySummaryGetList:
            url = @"/SAIM/SAIMMainInventorySummaryGetList.php?%@";
            break;
        case urlEventInventoryGetList:
            url = @"/SAIM/SAIMEventInventoryGetList.php?%@";
            break;
        case urlLazadaPendingOrdersGetList:
            url = @"/SAIM/SAIMLazadaPendingOrdersGetList.php?%@";
            break;
        case urlLazadaFetchOrdersGetList:
            url = @"/SAIM/SAIMLazadaFetchOrdersGetList.php?%@";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@%@", [self domainName],url];
}

+ (NSString *) formatDate:(NSString *)strDate fromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];//local time +7
    df.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//year christ
    df.dateStyle = NSDateFormatterMediumStyle;
    df.dateFormat = fromFormat;
    NSDate *date  = [df dateFromString:strDate];
    
    // Convert to new Date Format
    [df setDateFormat:toFormat];///////uncomment dont forget

    //must set timezone to normal
    NSString *newStrDate = [df stringFromDate:date];
    return newStrDate;
}

+ (NSString *) formatDateForDB:(NSString *)strDate
{
    return [self formatDate:strDate fromFormat:[Utility setting:vFormatDateDisplay] toFormat:[Utility setting:vFormatDateDB]];
}

+ (NSString *) formatDateForDisplay:(NSString *)strDate
{
    return [self formatDate:strDate fromFormat:[Utility setting:vFormatDateDB] toFormat:[Utility setting:vFormatDateDisplay]];
}

+ (nullable NSDate *) stringToDate:(NSString *)strDate fromFormat:(NSString *)fromFormat
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];//local time +7
    df.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//year christ
    df.dateStyle = NSDateFormatterMediumStyle;
    df.dateFormat = fromFormat;
    
    NSDate *date = [df dateFromString:strDate];
    return date;
}

+ (NSString *) dateToString:(NSDate *)date toFormat:(NSString *)toFormat
{
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateTimeInLocalTimezone = [date dateByAddingTimeInterval:timeZoneSeconds];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];//local time +7
    df.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//year christ
    df.dateStyle = NSDateFormatterMediumStyle;
    df.dateFormat = toFormat;
    
    
    NSString *strDate = [df stringFromDate:date];
//    NSString *strDate = [df stringFromDate:dateTimeInLocalTimezone];
    return strDate;
}

+ (NSDate *) setDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    return date;
}

//+(NSData *)encrypt:(NSString *)data
//{
//    NSData *nsData = [data dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error;
//    NSData *encryptedData = [RNEncryptor encryptData:nsData
//                                        withSettings:kRNCryptorAES256Settings
//                                            password:[self cipher]
//                                               error:&error];
//    return encryptedData;
//}
//
//+(NSString *)decrypt:(NSData *)encryptedData
//{
//    NSError *error;
//    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
//                                        withPassword:[self cipher]
//                                               error:&error];
//    NSString* strOriginal = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
//
//    return strOriginal;
//}

+(void)setCipher:(NSString *)cipher
{
    globalCipher = cipher;
}
+(NSString *)cipher
{
    return globalCipher;
}
+(NSString *)modifiedUser
{
    return globalModifiedUser;
}

+(void)setModifiedUser:(NSString *)modifiedUser
{
    globalModifiedUser = modifiedUser;
}

+(NSString *)getProductIDGroupWithProductCode:(NSString *)productCode
{
    NSRange needleRange;
    NSString *needle;
    needleRange = NSMakeRange(0,10);
    needle = [productCode substringWithRange:needleRange];
    return needle;
}

+(Product *)getProductWithProductCode:(NSString *)productCode
{
    NSRange needleRange;
    NSString *needle;
    Product *product = [[Product alloc]init];    
    
    needleRange = NSMakeRange(0,2);
    needle = [productCode substringWithRange:needleRange];
    product.productCategory2 = needle;
    
    needleRange = NSMakeRange(2,2);
    needle = [productCode substringWithRange:needleRange];
    product.productCategory1 = needle;
    
    needleRange = NSMakeRange(4,2);
    needle = [productCode substringWithRange:needleRange];
    product.productName = needle;
    
    needleRange = NSMakeRange(6,2);
    needle = [productCode substringWithRange:needleRange];
    product.color = needle;
    
    needleRange = NSMakeRange(8,2);
    needle = [productCode substringWithRange:needleRange];
    product.size = needle;
    
    NSString *year = [[NSString alloc]init];
    NSString *month = [[NSString alloc]init];
    NSString *day = [[NSString alloc]init];
    needleRange = NSMakeRange(10,4);
    needle = [productCode substringWithRange:needleRange];
    year = needle;
    
    needleRange = NSMakeRange(14,2);
    needle = [productCode substringWithRange:needleRange];
    month = needle;
    
    needleRange = NSMakeRange(16,2);
    needle = [productCode substringWithRange:needleRange];
    day = needle;
    product.manufacturingDate = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    
    product.status = @"";
    product.eventID = -1;
    
    needleRange = NSMakeRange(18,6);
    needle = [productCode substringWithRange:needleRange];
    product.productID = needle;
    
    product.remark = @"";
    return product;
}

+ (NSInteger) numberOfDaysFromDate:(NSDate *)dateFrom dateTo:(NSDate *)dateTo
{
    NSTimeInterval secondsBetween = [dateTo timeIntervalSinceDate:dateFrom];
    int numberOfDays = secondsBetween / 86400 + 1;
    return numberOfDays;
}

+ (NSInteger) numberOfDaysInEvent:(NSInteger)eventID
{
    Event *event = [Utility getEvent:eventID];
    NSDate *datePeriodTo = [Utility stringToDate:event.periodTo fromFormat:[Utility setting:vFormatDateDB]];
    NSDate *datePeriodFrom = [Utility stringToDate:event.periodFrom fromFormat:[Utility setting:vFormatDateDB]];
    NSInteger numberOfDays = [Utility numberOfDaysFromDate:datePeriodFrom dateTo:datePeriodTo];
    return numberOfDays;
}

+ (NSDate *) dateFromDateTime:(NSDate *)dateTime
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                           components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay
                                           fromDate:dateTime];
    NSDate *date = [[NSCalendar currentCalendar]
                       dateFromComponents:components];
    
    return date;
}

+ (NSInteger) dayFromDateTime:(NSDate *)dateTime
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay
                                    fromDate:dateTime];
    
    NSInteger day = [components day];
    return day;
}

+ (NSDate *) GMTDate:(NSDate *)dateTime
{
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateTimeInLocalTimezone = [dateTime dateByAddingTimeInterval:timeZoneSeconds];
    
    return dateTimeInLocalTimezone;
}

+ (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

+ (NSString *)concatParameter:(NSDictionary *)condition
{
    NSString *value;
    NSString *urlParameter = @"";
    for(id key in condition){
        value = [condition objectForKey:key];
        urlParameter = [NSString stringWithFormat:@"%@&%@=%@",urlParameter,key,value];
    }
    
    NSRange needleRange = NSMakeRange(1,[urlParameter length]-1);
    urlParameter = [urlParameter substringWithRange:needleRange];
    
    return urlParameter;
}

+ (NSString *) getNoteDataString: (NSObject *)object
{
    NSMutableDictionary *dicCondition = [[NSMutableDictionary alloc]init];

    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList([object class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [object valueForKey:key];
        
        NSString *escapeString = value;
        if(![value isKindOfClass:NSClassFromString(@"__NSCFNumber")] && ![value isKindOfClass:NSClassFromString(@"__NSCFBoolean")] && ![value isKindOfClass:NSClassFromString(@"__NSTaggedDate")]  && ![value isKindOfClass:NSClassFromString(@"__NSDate")]){//__NSCFConstantString //__NSCFNumber  //__NSCFString //
            NSString *trimString;
            if(![value isEqual:[NSNull null]] && [value length]>0)
            {
                trimString = [Utility trimString:escapeString];
            }
            else
            {
                trimString = @"";
            }
            
            escapeString = [self percentEscapeString:trimString];//สำหรับส่ง ให้ php script
        }
        
        [dicCondition setValue:escapeString forKey:key];
    }
    free(properties);
    
    return [self concatParameter:dicCondition];
}
+ (NSString *) getNoteDataString: (NSObject *)object withRunningNo:(long)runningNo
{
    NSMutableDictionary *dicCondition = [[NSMutableDictionary alloc]init];
    
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList([object class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [object valueForKey:key];
        
        NSString *escapeString = value;
        if(![value isKindOfClass:NSClassFromString(@"__NSCFNumber")] && ![value isKindOfClass:NSClassFromString(@"__NSCFBoolean")] && ![value isKindOfClass:NSClassFromString(@"__NSTaggedDate")] && ![value isKindOfClass:NSClassFromString(@"__NSDate")]){//__NSCFConstantString //__NSCFNumber  //__NSCFString //
            NSString *trimString = [Utility trimString:escapeString];
            escapeString = [self percentEscapeString:trimString];//สำหรับส่ง ให้ php script
        }
        key = [NSString stringWithFormat:@"%@%02ld",key,runningNo];
        [dicCondition setValue:escapeString forKey:key];
    }
    free(properties);
    
    return [self concatParameter:dicCondition];
}
+ (NSString *) getNoteDataString: (NSObject *)object withRunningNo3Digit:(long)runningNo
{
    NSMutableDictionary *dicCondition = [[NSMutableDictionary alloc]init];
    
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList([object class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [object valueForKey:key];
        
        NSString *escapeString = value;
        if(![value isKindOfClass:NSClassFromString(@"__NSCFNumber")] && ![value isKindOfClass:NSClassFromString(@"__NSCFBoolean")] && ![value isKindOfClass:NSClassFromString(@"__NSTaggedDate")] && ![value isKindOfClass:NSClassFromString(@"__NSDate")]){//__NSCFConstantString //__NSCFNumber  //__NSCFString //
            NSString *trimString = [Utility trimString:escapeString];
            escapeString = [self percentEscapeString:trimString];//สำหรับส่ง ให้ php script
        }
        key = [NSString stringWithFormat:@"%@%03ld",key,runningNo];
        [dicCondition setValue:escapeString forKey:key];
    }
    free(properties);
    
    return [self concatParameter:dicCondition];
}

+ (NSObject *) trimAndFixEscapeString: (NSObject *)object
{
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList([object class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        NSString *key = [NSString stringWithUTF8String:name];

        id value = [object valueForKey:key];
        
        NSString *escapeString = value;
        if(![value isKindOfClass:NSClassFromString(@"__NSCFNumber")]){
            NSString *trimString = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            escapeString = [self percentEscapeString:trimString];
        }
        [object setValue:escapeString forKey:key];
    }
    free(properties);
    
    return object;
}

+ (NSString *) currentDateTimeStringForDB
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];// here set format which you want...
    NSString *convertedString = [dateFormatter stringFromDate:[NSDate date]];
    return convertedString;
}
+ (NSString *)formatBaht:(NSString *)number
{
    [formatterBaht setNumberStyle:NSNumberFormatterDecimalStyle];
    formatterBaht.minimumFractionDigits = 0;
    formatterBaht.maximumFractionDigits = 2;
    NSString *strFormattedBaht = [formatterBaht stringFromNumber:[NSNumber numberWithFloat:[number floatValue]]];
    return strFormattedBaht;
}
+ (NSString *)formatBaht:(NSString *)number withMinFraction:(NSInteger)min andMaxFraction:(NSInteger)max
{
    [formatterBaht setNumberStyle:NSNumberFormatterDecimalStyle];
    formatterBaht.minimumFractionDigits = min;
    formatterBaht.maximumFractionDigits = max;
    NSString *strFormattedBaht = [formatterBaht stringFromNumber:[NSNumber numberWithFloat:[number floatValue]]];
    return strFormattedBaht;
}

+ (CustomMade *)getCustomMade:(NSInteger)customMadeID
{
    NSMutableArray *customMadeList = [SharedCustomMade sharedCustomMade].customMadeList;
    for(CustomMade *item in customMadeList)
    {
        if(item.customMadeID == customMadeID)
        {
            return item;
        }
    }
    return nil;
}
+ (CustomMade *)getCustomMadeFromProductIDPost:(NSString *)productIDPost
{
    NSMutableArray *customMadeList = [SharedCustomMade sharedCustomMade].customMadeList;
    for(CustomMade *item in customMadeList)
    {
        if([item.productIDPost isEqualToString:productIDPost])
        {
            return item;
        }
    }
    return nil;
}

+ (Color *)getColor:(NSString *)colorCode
{
    NSMutableArray *colorList = [SharedColor sharedColor].colorList;
    for(Color *item in colorList)
    {
        if([item.code isEqualToString:colorCode])
        {
            return item;
        }
    }
    return nil;
}
+ (NSString *)getColorName:(NSString *)colorCode
{
    NSMutableArray *colorList = [SharedColor sharedColor].colorList;
    for(Color *item in colorList)
    {
        if([item.code isEqualToString:colorCode])
        {
            return item.name;
        }
    }
    return  @"-";
}
+ (NSString *)getUsername:(NSInteger)userAccountID
{
    NSMutableArray *userAccountList = [SharedUserAccount sharedUserAccount].userAccountList;
    for(UserAccount *item in userAccountList)
    {
        if(item.userAccountID == userAccountID)
        {
            return item.username;
        }
    }
    return  @"-";
}
+ (NSString *)getEventName:(NSInteger)eventID
{
    if(eventID == -1)
    {
        return @"-";
    }
    if(eventID == 0)
    {
        return @"Main";
    }
    NSMutableArray *eventList = [SharedEvent sharedEvent].eventList;
    for(Event *item in eventList)
    {
        if(item.eventID == eventID)
        {
            return item.location;
        }
    }
    return  @"-";
}
+ (Event *)getEvent:(NSInteger)eventID
{
    NSMutableArray *eventList = [SharedEvent sharedEvent].eventList;
    for(Event *item in eventList)
    {
        if(item.eventID == eventID)
        {
            return item;
        }
    }
    return nil;
}

+ (ProductSales *)getProductSales:(NSInteger)productNameID color:(NSString *)color size:(NSString *)size productSalesSetID:(NSString *)productSalesSetID
{
    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@",productSalesSetID];
    NSArray *filterArray = [productSalesList filteredArrayUsingPredicate:predicate1];
    productSalesList = [filterArray mutableCopy];
    
    for(ProductSales *item in productSalesList)
    {
        if((item.productNameID == productNameID) && [item.color isEqualToString:color] && [item.size isEqualToString:size])
        {
            return item;
        }
    }
    return nil;
}

+ (ProductSales *)getProductCost:productType productID:(NSString *)productID
{
    Product *product;
    CustomMade *customMade;
    ProductName *productName;
    NSString *colorCode;
    NSString *code;
    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
    if([productType isEqualToString:@"I"])
    {
        product = [Product getProduct:productID];
        productName = [ProductName getProductNameWithProductID:productID];
        colorCode = product.color;
        code = product.size;
    }
    else
    {
        customMade = [self getCustomMade:productID];
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
        productName = [ProductName getProductNameWithProductNameGroup:productNameGroup];
        colorCode = @"00";
        code = @"00";
    }
    
    
    
    for(ProductSales *item in productSalesList)
    {
        if((item.productNameID == productName.productNameID) && [item.color isEqualToString:colorCode] && [item.size isEqualToString:code])
        {
            return item;
        }
    }
    return nil;
}

+ (ProductSalesSet *)getProductSalesSet:(NSString *)productSalesSetID
{
    for(ProductSalesSet *item in [SharedProductSalesSet sharedProductSalesSet].productSalesSetList)
    {
        if([item.productSalesSetID isEqualToString:productSalesSetID])
        {
            return item;
        }
    }
    return nil;
}

+ (NSString *)getProductSalesSetName:(NSString *)productSalesSetID
{
    for(ProductSalesSet *item in [SharedProductSalesSet sharedProductSalesSet].productSalesSetList)
    {
        if([item.productSalesSetID isEqualToString:productSalesSetID])
        {
            return item.productSalesSetName;
        }
    }
    return nil;
}

+ (ProductSales *)getProductSalesFromProductID:(NSString *)productID productType:(enum enumProductType)productType event:(Event *)event
{
    ProductSales *productSales;
    if(productType == productInventory || productType == productPreOrder)
    {
        Product *product = [Product getProduct:productID];
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
        ProductName *productName = [ProductName getProductNameWithProductNameGroup:productNameGroup];
        productSales = [Utility getProductSales:productName.productNameID color:product.color size:product.size productSalesSetID:event.productSalesSetID];
    }
    else
    {
        CustomMade *customMade = [Utility getCustomMade:productID];
        NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
        for(ProductSales *item in productSalesList)
        {
            ProductName *productName = [ProductName getProductName:item.productNameID];
            item.productCategory2 = productName.productCategory2;
            item.productCategory1 = productName.productCategory1;
            item.productName = productName.code;
        }
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@ and _productCategory2 = %@ and _productCategory1 = %@ and _productName = %@",event.productSalesSetID,customMade.productCategory2,customMade.productCategory1,@"00"];
        NSArray *productSalesCustomMadeFilter = [productSalesList filteredArrayUsingPredicate:predicate1];
        productSales  = productSalesCustomMadeFilter[0];
    }
    return productSales;
}

+ (ProductSales *)getProductSales:(NSInteger)productSalesID
{
    for(ProductSales *item in [SharedProductSales sharedProductSales].productSalesList)
    {
        if(item.productSalesID == productSalesID)
        {
            return item;
        }
    }
    return nil;
}

+ (NSString *)trimString:(NSString *)text
{
    if([text length] != 0)
    {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return text;
}

+ (NSString *)getProductCode:(Product *)product
{
//    Product *product = [self getProduct:productID];
    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@", product.productCategory2,product.productCategory1,product.productName,product.color,product.size, [Utility formatDate:product.manufacturingDate fromFormat:@"yyyy-MM-dd" toFormat:@"yyyyMMdd"], product.productID];
}

+ (Receipt *)getReceipt:(NSInteger)receiptID
{
    NSMutableArray *receiptList = [SharedReceipt sharedReceipt].receiptList;
    for(Receipt *item in receiptList)
    {
        if(item.receiptID == receiptID)
        {
            return item;
        }
    }
    return nil;
}

+ (ReceiptProductItem *)getReceiptProductItem:(NSInteger)receiptProductItemID
{
    NSMutableArray *receiptItemList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
    for(ReceiptProductItem *item in receiptItemList)
    {
        if(item.receiptProductItemID == receiptProductItemID)
        {
            return item;
        }
    }
    return nil;
}

+ (NSArray *)getReceiptProductItemList:(NSInteger)receiptID
{
    NSMutableArray *receiptProductItemList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray  = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptProductItemID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortArray;
}

+ (ProductSize *)getSize:(NSString *)code
{
    NSMutableArray *productSizeList = [SharedProductSize sharedProductSize].productSizeList;
    for(ProductSize *item in productSizeList)
    {
        if([item.code isEqualToString:code])
        {
            return item;
        }
    }
    return nil;
}
+ (NSString *)getSizeLabel:(NSString *)code
{
    NSMutableArray *productSizeList = [SharedProductSize sharedProductSize].productSizeList;
    for(ProductSize *item in productSizeList)
    {
        if([item.code isEqualToString:code])
        {
            return item.sizeLabel;
        }
    }
    return @"-";
}


+ (NSInteger)getSizeOrder:(NSString *)code
{
    NSMutableArray *productSizeList = [SharedProductSize sharedProductSize].productSizeList;
    for(ProductSize *item in productSizeList)
    {
        if([item.code isEqualToString:code])
        {
            return [item.sizeOrder intValue];
        }
    }
    return 100;
}

+ (NSInteger) getPostCustomerID:(NSInteger)receiptID
{
    NSMutableArray *customerReceiptList = [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList;
    for(CustomerReceipt *item in customerReceiptList)
    {
        if(item.receiptID == receiptID)
        {
            return item.postCustomerID;
        }
    }
    return 0;
}

+ (PostCustomer *) getPostCustomer:(NSInteger)postCustomerID
{
    NSMutableArray *postCustomerList = [SharedPostCustomer sharedPostCustomer].postCustomerList;
    for(PostCustomer *item in postCustomerList)
    {
        if(item.postCustomerID == postCustomerID)
        {
            return item;
        }
    }
    return nil;
}

+ (NSInteger)getNextImageRunningID
{
    NSInteger intNextImageRunningID = 1;
    NSMutableArray *imageRunningIDList = [SharedImageRunningID sharedImageRunningID].imageRunningIDList;
    
    for(ImageRunningID *item in imageRunningIDList)
    {
        item.runningID = [NSString stringWithFormat:@"%d", [item.runningID intValue]+1];
        intNextImageRunningID = [item.runningID intValue];
    }
    
    return intNextImageRunningID;
}

+ (ProductCategory2 *)getProductCategory2:(NSString *)code
{
    NSMutableArray *productCategory2List = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
    for(ProductCategory2 *item in productCategory2List)
    {
        if([item.code isEqualToString:code])
        {
            return item;
        }
    }
    return nil;
}
+ (ProductCategory1 *)getProductCategory1:(NSString *)code productCategory2:(NSString *)productCategory2
{
    NSMutableArray *productCategory1List = [SharedProductCategory1 sharedProductCategory1].productCategory1List;
    for(ProductCategory1 *item in productCategory1List)
    {
        if([item.code isEqualToString:code] && [item.productCategory2 isEqualToString:productCategory2])
        {
            return item;
        }
    }
    return nil;
}

+ (NSString *)insertDash:(NSString *)text
{
    if([text length] == 10)
    {
        NSMutableString *mu = [NSMutableString stringWithString:text];
        [mu insertString:@"-" atIndex:3];
        [mu insertString:@"-" atIndex:7];
        return [NSString stringWithString:mu];
    }
    return text;
}
+ (NSString *)removeDashAndSpaceAndParenthesis:(NSString *)text
{
    text = [text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"(" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@")" withString:@""];
    return text;
}
+ (NSString *)removeComma:(NSString *)text
{
    text = [text stringByReplacingOccurrencesOfString:@"," withString:@""];
    return text;
}
+ (NSString *)removeApostrophe:(NSString *)text
{
    text = [text stringByReplacingOccurrencesOfString:@"'" withString:@""];
    return text;
}
+ (NSString *)removeKeyword:(NSArray *)arrKeyword text:(NSString *)text
{
    for(NSString *keyword in arrKeyword)
    {
        text = [text stringByReplacingOccurrencesOfString:keyword withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [text length])];
    }
    
    return text;
}

+ (NSInteger)getCustomMadeIDFromProductIDPost:(NSString *)productIDPost
{
    for(CustomMade *item in [SharedCustomMade sharedCustomMade].customMadeList)
    {
        if([item.productIDPost isEqualToString:productIDPost])
        {
            return item.customMadeID;
        }
    }
    return 0;
}
+ (NSString *)getProductIDGroupMdf:(Product *)product
{
    return [NSString stringWithFormat:@"%@%@%@%@%@%@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size, [Utility formatDate:product.manufacturingDate fromFormat:@"yyyy-MM-dd" toFormat:@"yyyyMMdd"]];
}
+ (NSString *)getProductIDGroup:(Product *)product
{
    return [NSString stringWithFormat:@"%@%@%@%@%@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size];
}
+ (NSInteger)getNoOfPairReceipt:(Receipt *)receipt
{
    NSMutableArray *receiptProductItemList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ldf",receipt.receiptID];
    NSArray *filterArray = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    return [filterArray count];
}

+ (NSString *)getCurrentDateString:(NSString *)format
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    NSString *dateString = [dateFormat stringFromDate:today];
    return dateString;
}
+ (NSString *)getDeviceTokenFromUsername:(NSString *)username
{
    NSMutableArray *userAccountList = [SharedUserAccount sharedUserAccount].userAccountList;
    for(UserAccount *item in userAccountList)
    {
        if([item.username isEqualToString:username])
        {
            return item.deviceToken;
        }
    }
    return @"-";
}
+ (BOOL)alreadySynced:(NSInteger)pushSyncID
{
    NSMutableArray *pushSyncList = [SharedPushSync sharedPushSync].pushSyncList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_pushSyncID = %ld",pushSyncID];
    NSArray *filterArray = [pushSyncList filteredArrayUsingPredicate:predicate1];
    return [filterArray count]>0;
}
+ (NSData *)dataFromHexString:(NSString *)string
{
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
        continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}
+ (NSString *)getNextProductID
{
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [productList sortedArrayUsingDescriptors:sortDescriptors];
    if([sortArray count] == 0)
    {
        return @"-00001";
    }
    else
    {
        Product *product = sortArray[0];
        if([product.productID integerValue]>0)
        {
            return @"-00001";
        }
        else
        {
            return [NSString stringWithFormat:@"%06ld",[product.productID integerValue]-1];
//            return [NSString stringWithFormat:@"%06ld",[product.productID integerValue]+1];
        }
    }
}
+ (NSInteger)getNextID:(enum enumTableName)tableName
{
    NSString *strNameID;
    NSMutableArray *dataList;
    switch (tableName) {
        case tblUserAccount:
        {
            dataList = [SharedUserAccount sharedUserAccount].userAccountList;
            strNameID = @"userAccountID";
        }
        break;
        case tblProductDelete:
        {
            dataList = [SharedProductDelete sharedProductDelete].productDeleteList;
            strNameID = @"productDeleteID";
        }
        break;
        case tblUserAccountEvent:
        {
            dataList = [SharedUserAccountEvent sharedUserAccountEvent].userAccountEventList;
            strNameID = @"userAccountEventID";
        }
        break;
        case tblReceipt:
        {
            dataList = [SharedReceipt sharedReceipt].receiptList;
            strNameID = @"receiptID";
        }
        break;
        case tblCustomerReceipt:
        {
            dataList = [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList;
            strNameID = @"customerReceiptID";
        }
        break;
        case tblPostCustomer:
        {
            dataList = [SharedPostCustomer sharedPostCustomer].postCustomerList;
            strNameID = @"postCustomerID";
        }
        break;
        case tblCustomMade:
        {
            dataList = [SharedCustomMade sharedCustomMade].customMadeList;
            strNameID = @"customMadeID";
        }
        break;
        case tblReceiptProductItem:
        {
            dataList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
            strNameID = @"receiptProductItemID";
        }
        break;
        case tblProductSize:
        {
            dataList = [SharedProductSize sharedProductSize].productSizeList;
            strNameID = @"productSizeID";
        }
            break;
        case tblColor:
        {
            dataList = [SharedColor sharedColor].colorList;
            strNameID = @"colorID";
        }
            break;
        case tblProductCategory2:
        {
            dataList = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
            strNameID = @"productCategory2ID";
        }
            break;
        case tblProductName:
        {
            dataList = [SharedProductName sharedProductName].productNameList;
            strNameID = @"productNameID";
        }
            break;
        case tblProductSales:
        {
            dataList = [SharedProductSales sharedProductSales].productSalesList;
            strNameID = @"productSalesID";
        }
            break;
        case tblEvent:
        {
            dataList = [SharedEvent sharedEvent].eventList;
            strNameID = @"eventID";
        }
            break;
        case tblEventCost:
        {
            dataList = [SharedEventCost sharedEventCost].eventCostList;
            strNameID = @"eventCostID";
        }
            break;
        case tblCompareInventory:
        {
            dataList = [SharedCompareInventory sharedCompareInventory].compareInventoryList;
            strNameID = @"compareInventoryID";
        }
            break;
        case tblCompareInventoryHistory:
        {
            dataList = [SharedCompareInventoryHistory sharedCompareInventoryHistory].compareInventoryHistoryList;
            strNameID = @"compareInventoryHistoryID";
        }
            break;
        case tblCashAllocation:
        {
            dataList = [SharedCashAllocation sharedCashAllocation].cashAllocationList;
            strNameID = @"cashAllocationID";
        }
            break;
        case tblRewardPoint:
        {
            dataList = [SharedRewardPoint sharedRewardPoint].rewardPointList;
            strNameID = @"rewardPointID";
        }
            break;
        case tblRewardProgram:
        {
            dataList = [SharedRewardProgram sharedRewardProgram].rewardProgramList;
            strNameID = @"rewardProgramID";
        }
            break;
        case tblPreOrderEventIDHistory:
        {
            dataList = [SharedPreOrderEventIDHistory sharedPreOrderEventIDHistory].preOrderEventIDHistoryList;
            strNameID = @"preOrderEventIDHistoryID";
        }
        default:
            break;
    }
    
    
    NSString *strSortID = [NSString stringWithFormat:@"_%@",strNameID];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:strSortID ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray *sortArray = [dataList sortedArrayUsingDescriptors:sortDescriptors];
    dataList = [sortArray mutableCopy];
    
    if([dataList count] == 0)
    {
        return -1;
    }
    else
    {
        id value = [dataList[0] valueForKey:strNameID];
        if([value integerValue]>0)
        {
            return -1;
        }
        else
        {
            return [value integerValue]-1;
        }
    }
}
+ (NSString *)makeFirstLetterLowerCase:(NSString *)text
    {
        NSRange needleRange;
        needleRange = NSMakeRange(0,1);
        NSString *firstLetter = [text substringWithRange:needleRange];
        needleRange = NSMakeRange(1,[text length]-1);
        NSString *theRestLetters = [text substringWithRange:needleRange];
        return [NSString stringWithFormat:@"%@%@",[firstLetter lowercaseString],theRestLetters];
    }

+ (NSString *)makeFirstLetterUpperCase:(NSString *)text
{
    NSRange needleRange;
    needleRange = NSMakeRange(0,1);
    NSString *firstLetter = [text substringWithRange:needleRange];
    needleRange = NSMakeRange(1,[text length]-1);
    NSString *theRestLetters = [text substringWithRange:needleRange];
    return [NSString stringWithFormat:@"%@%@",[firstLetter uppercaseString],theRestLetters];
}
+ (NSString *)makeFirstLetterUpperCaseOtherLower:(NSString *)text
{
    NSRange needleRange;
    needleRange = NSMakeRange(0,1);
    NSString *firstLetter = [text substringWithRange:needleRange];
    needleRange = NSMakeRange(1,[text length]-1);
    NSString *theRestLetters = [text substringWithRange:needleRange];
    return [NSString stringWithFormat:@"%@%@",[firstLetter uppercaseString],[theRestLetters lowercaseString]];
}
+ (NSString *)getStringNameID:(NSString *)className
{
    NSRange needleRange;
    needleRange = NSMakeRange(0,1);
    NSString *firstLetter = [className substringWithRange:needleRange];
    needleRange = NSMakeRange(1,[className length]-1);
    NSString *theRestLetter = [className substringWithRange:needleRange];
    return [NSString stringWithFormat:@"%@%@ID",[firstLetter lowercaseString],theRestLetter];
}
+ (NSString *)getMasterClassName:(NSInteger)i
{
    NSArray *arrMasterClass = @[@"UserAccount",@"ProductName",@"Color",@"Product",@"Event",@"UserAccountEvent",@"ProductCategory2",@"ProductCategory1",@"ProductSales",@"CashAllocation",@"CustomMade",@"Receipt",@"ReceiptProductItem",@"CompareInventoryHistory",@"CompareInventory",@"ProductSalesSet",@"CustomerReceipt",@"PostCustomer",@"ProductCost",@"EventCost",@"CostLabel",@"ProductSize",@"ImageRunningID",@"ProductDelete",@"Setting",@"PostCode",@"RewardPoint",@"RewardProgram",@"PreOrderEventIDHistory"];
    
    
    return arrMasterClass[i];
}
+ (NSString *)getMasterClassName:(NSInteger)i from:(NSArray *)arrClassName
{
    return arrClassName[i];
}
//+ (NSString *)getDecryptedHexString:(NSString *)hexString
//{
//    NSData *nsDataEncrypted = [self dataFromHexString:hexString];
//    NSString *decryptedString = [self decrypt:nsDataEncrypted];
//    return  decryptedString;
//}
+ (BOOL)isValidProduct:(Product*)product error:(NSString **)error
{
    //check productname,color,size,mfd,productid
    NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
    ProductName *productName = [ProductName getProductNameWithProductNameGroup:productNameGroup];
    if(!productName)
    {
        *error = @"Style code is invalid";
        return NO;
    }
    
    Color *color = [Utility getColor:product.color];
    if(!color)
    {
        *error = @"Color code is invalid";
        return NO;
    }
    
    ProductSize *productSize = [Utility getSize:product.size];
    if(!productSize)
    {
        *error = @"Size code is invalid";
        return NO;
    }
    
    if(![Utility stringToDate:product.manufacturingDate fromFormat:@"yyyy-MM-dd"])
    {
        *error = @"Manufacturing date code is invalid";
        return NO;
    }
    
    if(![Utility isNumeric:product.productID])
    {
        *error = @"Product ID is invalid";
        return NO;
    }
    
    return YES;    
}

+ (BOOL)isNumeric:(NSString *)text
{
    if([text isKindOfClass:[NSString class]])
    {
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([text rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            // newString consists only of the digits 0 through 9
            return YES;
        }
    }
    
    return NO;
}
+ (CustomerReceipt *)getCustomerReceiptFromPostCustomerID:(NSInteger)postCustomerID
{
    NSMutableArray *customerReceiptList = [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList;
    for(CustomerReceipt *item in customerReceiptList)
    {
        if(item.postCustomerID == postCustomerID)
        {
            return item;
        }
    }
    return nil;
}
+(NSString *)getSqlFailTitle
{
    return @"Error occur";
}
+(NSString *)getSqlFailMessage
{
    return @"Please check recent transactions again";
}

+(NSString *)getConnectionLostTitle
{
    return @"Connection lost";
}
+(NSString *)getConnectionLostMessage
{
    return @"The network connection was lost";
}
+(NSInteger)getNumberOfRowForExecuteSql
{
    return 30;
}
+(NSString *)getAppKey
{
    NSString *appKey;
    NSString *dbName = @"SAIM";
    NSString *strDBName = [NSString stringWithFormat:@"/%@/",dbName];
    if([@"/SAIM/" isEqualToString:strDBName])
    {
        appKey = @"wzksbywfw7kg52k";
    }
    else
    {
//        appKey = @"0zoszvv007lfx4x";
        appKey = @"j7s3q4s6ludo5dz";
    }
    
    return appKey;
}
+(NSString *)getAppSecret
{
    NSString *appSecret;
    NSString *dbName = @"SAIM";
    NSString *strDBName = [NSString stringWithFormat:@"/%@/",dbName];
    if([@"/SAIM/" isEqualToString:strDBName])
    {
        appSecret = @"rny8l0357sss0pn";
    }
    else
    {
        appSecret = @"cwq0v9grdruvfqx";
    }
    
    return appSecret;
}
+(BOOL)getMenuExtra
{
    NSMutableArray *userAccountList = [SharedUserAccount sharedUserAccount].userAccountList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_username = %@",[self modifiedUser]];
    NSArray *filterArray = [userAccountList filteredArrayUsingPredicate:predicate1];
    UserAccount *userAccount = filterArray[0];
    return [userAccount.menuExtra isEqualToString:@"1"];
}

+(NSAttributedString *)getCountWithRemarkText:(NSInteger)count remark:(NSString *)remark
{
    NSString *strScanCount = [NSString stringWithFormat:@"%lu",(unsigned long)count];
    UIColor *color1 = [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1];//tBlueColor;
    NSDictionary *dicAttr1 = [NSDictionary dictionaryWithObject:color1 forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:strScanCount attributes: dicAttr1];
    
    
    NSString *strText = [NSString stringWithFormat:@" (%@)",remark];
    UIColor *color2 = [UIColor redColor];
    NSDictionary *dicAttr2 = [NSDictionary dictionaryWithObject:color2 forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:strText attributes: dicAttr2];
    
    [attrString1 appendAttributedString:attrString2];
    
    return attrString1;
}

+(NSInteger)getScanTimeInterVal
{
    return 4;
}
+(NSInteger)getScanTimeInterValCaseBlur
{
    return 2;
}
+(Setting *)getSetting:(NSInteger)settingID
{
    NSMutableArray *settingList = [SharedSetting sharedSetting].settingList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_settingID = %ld",settingID];
    NSArray *filterArray = [settingList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    else
    {
        return nil;
    }
}
+ (BOOL)duplicate:(NSString *)className record:(NSObject *)object
{
    NSMutableArray *dataList;
    NSPredicate *predicate1;
    NSString *strFilterID = [NSString stringWithFormat:@"%@ID", [Utility makeFirstLetterLowerCase:className]];
    NSInteger filterValue = [[object valueForKey:strFilterID] integerValue];
    NSString *predicateColumn = [NSString stringWithFormat:@"_%@",strFilterID];
    NSString *modifiedUser = [object valueForKey:@"modifiedUser"];
    if([className isEqualToString:@"Product"])
    {
        dataList = [SharedProduct sharedProduct].productList;
        strFilterID = @"productID";
        NSString *strFilterValue = [object valueForKey:strFilterID];
        predicate1 = [NSPredicate predicateWithFormat:@"_productID = %@",strFilterValue];
    }
    else
    {
        if([className isEqualToString:@"ProductCategory2"])
        {
            dataList = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
        }
        if([className isEqualToString:@"Receipt"])
        {
            dataList = [SharedReceipt sharedReceipt].receiptList;
        }
        else if([className isEqualToString:@"ReceiptProductItem"])
        {
            dataList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
        }
        else if([className isEqualToString:@"UserAccount"])
        {
            dataList = [SharedUserAccount sharedUserAccount].userAccountList;
        }
        else if([className isEqualToString:@"ProductDelete"])
        {
            dataList = [SharedProductDelete sharedProductDelete].productDeleteList;
        }
        else if([className isEqualToString:@"UserAccountEvent"])
        {
            dataList = [SharedUserAccountEvent sharedUserAccountEvent].userAccountEventList;
        }
        else if([className isEqualToString:@"CustomerReceipt"])
        {
            dataList = [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList;
        }
        else if([className isEqualToString:@"PostCustomer"])
        {
            dataList = [SharedPostCustomer sharedPostCustomer].postCustomerList;
        }
        else if([className isEqualToString:@"CustomMade"])
        {
            dataList = [SharedCustomMade sharedCustomMade].customMadeList;
        }
        else if([className isEqualToString:@"ProductSize"])
        {
            dataList = [SharedProductSize sharedProductSize].productSizeList;
        }
        else if([className isEqualToString:@"Color"])
        {
            dataList = [SharedColor sharedColor].colorList;
        }
        else if([className isEqualToString:@"ProductName"])
        {
            dataList = [SharedProductName sharedProductName].productNameList;
        }
        else if([className isEqualToString:@"ProductSales"])
        {
            dataList = [SharedProductSales sharedProductSales].productSalesList;
        }
        else if([className isEqualToString:@"Event"])
        {
            dataList = [SharedEvent sharedEvent].eventList;
        }
        else if([className isEqualToString:@"EventCost"])
        {
            dataList = [SharedEventCost sharedEventCost].eventCostList;
        }
        else if([className isEqualToString:@"CompareInventory"])
        {
            dataList = [SharedCompareInventory sharedCompareInventory].compareInventoryList;
        }
        else if([className isEqualToString:@"CompareInventoryHistory"])
        {
            dataList = [SharedCompareInventoryHistory sharedCompareInventoryHistory].compareInventoryHistoryList;
        }
        else if([className isEqualToString:@"CashAllocation"])
        {
            dataList = [SharedCashAllocation sharedCashAllocation].cashAllocationList;
        }
        else if([className isEqualToString:@"RewardProgram"])
        {
            dataList = [SharedRewardProgram sharedRewardProgram].rewardProgramList;
        }
        else if([className isEqualToString:@"PushSync"])
        {
            dataList = [SharedPushSync sharedPushSync].pushSyncList;
        }
        predicate1 = [NSPredicate predicateWithFormat:@"%K = %ld and _modifiedUser = %@",predicateColumn,filterValue,modifiedUser];        
    }

    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate1];
    
    return [filterArray count]>0;
}

+ (NSString *)getPricePromotion:(Product *)product eventID:(NSInteger)eventID
{
    Event *event = [Utility getEvent:eventID];
    ProductName *productName = [ProductName getProductNameWithProduct:product];
    ProductSales *productSalesEvent = [Utility getProductSales:productName.productNameID color:product.color size:product.size  productSalesSetID:event.productSalesSetID];
    
    if(!productSalesEvent)
    {
        return @"0";
    }
    return productSalesEvent.pricePromotion;
}

+(void)setEventSales:(NSString *)data  eventID:(NSInteger)eventID
{
    NSString *strEventID = [NSString stringWithFormat:@"%ld",eventID];
    [[SharedEventSales sharedEventSales].dicEventSales setValue:data forKey:strEventID];
}

+(BOOL)hasEventSales:(NSInteger)eventID
{
    NSString *strEventID = [NSString stringWithFormat:@"%ld",eventID];
    NSObject *obj = [[SharedEventSales sharedEventSales].dicEventSales valueForKey:strEventID];
    if(!obj)
    {
        Event *event = [Utility getEvent:eventID];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        NSDate *currentDate = [Utility setDateWithYear:[components year] month:[components month] day:[components day]];
        NSDate *gmtDate = [Utility GMTDate:currentDate];
        NSDate *previousDate = [gmtDate dateByAddingTimeInterval:60*60*24*(-15)];
        NSDate *datePeriodFrom = [Utility stringToDate:event.periodFrom fromFormat:@"yyyy-MM-dd"];
        NSComparisonResult result = [previousDate compare:datePeriodFrom];
        if(result == NSOrderedAscending)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

+ (float)floatValue:(NSString *)text
{
    return [[self removeComma:text] floatValue];
}

+ (NSInteger)getLastDayOfMonth:(NSDate *)datetime;
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSRange daysRange =
    [currentCalendar
     rangeOfUnit:NSCalendarUnitDay
     inUnit:NSCalendarUnitMonth
     forDate:datetime];
    
    // daysRange.length will contain the number of the last day
    // of the month containing curDate
    
    return daysRange.length;
}

+ (void)itemsSynced:(NSString *)type action:(NSString *)action data:(NSArray *)data
{
    NSString *className;
    NSString *strNameID;
    NSMutableArray *dataList;
    if([type isEqualToString:@"tUserAccount"])
    {
        NSObject *classInstance = [[UserAccount alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedUserAccount sharedUserAccount].userAccountList;
        
    }
    else if([type isEqualToString:@"tProduct"])
    {
        NSObject *classInstance = [[Product alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedProduct sharedProduct].productList;
        
    }
    else if([type isEqualToString:@"tSetting"])
    {
        NSObject *classInstance = [[Setting alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedSetting sharedSetting].settingList;
        
    }
    else if([type isEqualToString:@"tProductDelete"])
    {
        NSObject *classInstance = [[ProductDelete alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedProductDelete sharedProductDelete].productDeleteList;
        
    }
    else if([type isEqualToString:@"tUserAccountEvent"])
    {
        NSObject *classInstance = [[UserAccountEvent alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedUserAccountEvent sharedUserAccountEvent].userAccountEventList;
        
    }
    else if([type isEqualToString:@"tReceipt"])
    {
        NSObject *classInstance = [[Receipt alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedReceipt sharedReceipt].receiptList;
        
    }
    else if([type isEqualToString:@"tReceiptProductItem"])
    {
        NSObject *classInstance = [[ReceiptProductItem alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
        
    }
    else if([type isEqualToString:@"tCustomerReceipt"])
    {
        NSObject *classInstance = [[CustomerReceipt alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList;
        
    }
    else if([type isEqualToString:@"tCustomMade"])
    {
        NSObject *classInstance = [[CustomMade alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedCustomMade sharedCustomMade].customMadeList;
        
    }
    else if([type isEqualToString:@"tPostCustomer"])
    {
        NSObject *classInstance = [[PostCustomer alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedPostCustomer sharedPostCustomer].postCustomerList;
        
    }
    else if([type isEqualToString:@"tProductSize"])
    {
        NSObject *classInstance = [[ProductSize alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = @"code";//[Utility getStringNameID:className];
        dataList = [SharedProductSize sharedProductSize].productSizeList;
    }
    else if([type isEqualToString:@"tColor"])
    {
        NSObject *classInstance = [[Color alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = @"code";//[Utility getStringNameID:className];
        dataList = [SharedColor sharedColor].colorList;
    }
    else if([type isEqualToString:@"tProductCategory2"])
    {
        NSObject *classInstance = [[ProductCategory2 alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = @"code";//[Utility getStringNameID:className];
        dataList = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
    }
    else if([type isEqualToString:@"tProductCategory1"])
    {
        NSObject *classInstance = [[ProductCategory1 alloc]init];
        className = NSStringFromClass([classInstance class]);
        //                strNameID = @"code";//[Utility getStringNameID:className];
        dataList = [SharedProductCategory1 sharedProductCategory1].productCategory1List;
    }
    else if([type isEqualToString:@"tProductName"])
    {
        NSObject *classInstance = [[ProductName alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedProductName sharedProductName].productNameList;
    }
    else if([type isEqualToString:@"tProductSales"])
    {
        NSObject *classInstance = [[ProductSales alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedProductSales sharedProductSales].productSalesList;
    }
    else if([type isEqualToString:@"tProductSalesSet"])
    {
        NSObject *classInstance = [[ProductSalesSet alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedProductSalesSet sharedProductSalesSet].productSalesSetList;
    }
    else if([type isEqualToString:@"tEvent"])
    {
        NSObject *classInstance = [[Event alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedEvent sharedEvent].eventList;
    }
    else if([type isEqualToString:@"tEventCost"])
    {
        NSObject *classInstance = [[EventCost alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedEventCost sharedEventCost].eventCostList;
    }
    else if([type isEqualToString:@"tCompareInventory"])
    {
        NSObject *classInstance = [[CompareInventory alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedCompareInventory sharedCompareInventory].compareInventoryList;
    }
    else if([type isEqualToString:@"tCompareInventoryHistory"])
    {
        NSObject *classInstance = [[CompareInventoryHistory alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedCompareInventoryHistory sharedCompareInventoryHistory].compareInventoryHistoryList;
    }
    else if([type isEqualToString:@"tCashAllocation"])
    {
        NSObject *classInstance = [[CashAllocation alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedCashAllocation sharedCashAllocation].cashAllocationList;
    }
    else if([type isEqualToString:@"tRewardPoint"])
    {
        NSObject *classInstance = [[RewardPoint alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedRewardPoint sharedRewardPoint].rewardPointList;
    }
    else if([type isEqualToString:@"tPreOrderEventIDHistory"])
    {
        NSObject *classInstance = [[PreOrderEventIDHistory alloc]init];
        className = NSStringFromClass([classInstance class]);
        strNameID = [Utility getStringNameID:className];
        dataList = [SharedPreOrderEventIDHistory sharedPreOrderEventIDHistory].preOrderEventIDHistoryList;
    }
    
    //insert,update,delete data
    for(int i=0; i<[data count]; i++)
    {
        NSDictionary *jsonElement = data[i];
        NSObject *object = [[NSClassFromString(className) alloc] init];
        
        unsigned int propertyCount = 0;
        objc_property_t * properties = class_copyPropertyList([object class], &propertyCount);
        
        for (unsigned int i = 0; i < propertyCount; ++i)
        {
            objc_property_t property = properties[i];
            const char * name = property_getName(property);
            NSString *key = [NSString stringWithUTF8String:name];
            
            
            NSString *dbColumnName = [Utility makeFirstLetterUpperCase:key];
            if(!jsonElement[dbColumnName])
            {
                continue;
            }
            
            [object setValue:jsonElement[dbColumnName] forKey:key];
        }
        
        
        if([action isEqualToString:@"u"])
        {
            for(NSObject *item in dataList)
            {
                BOOL match = NO;
                if([type isEqualToString:@"tProductCategory1"])
                {
                    match = [[item valueForKey:@"code"] isEqualToString:[object valueForKey:@"code"]] && [[item valueForKey:@"productCategory2"] isEqualToString:[object valueForKey:@"productCategory2"]];
                }
                else
                {
                    if([[item valueForKey:strNameID] isKindOfClass:NSString.class])
                    {
                        match = [[item valueForKey:strNameID] isEqualToString:[object valueForKey:strNameID]];
                    }
                    else
                    {
                        match = [[item valueForKey:strNameID] integerValue] == [[object valueForKey:strNameID] integerValue];
                    }
                }
                
                if(match)
                {
                    unsigned int propertyCount = 0;
                    objc_property_t * properties = class_copyPropertyList([item class], &propertyCount);
                    
                    for (unsigned int i = 0; i < propertyCount; ++i)
                    {
                        objc_property_t property = properties[i];
                        const char * name = property_getName(property);
                        NSString *key = [NSString stringWithUTF8String:name];
                        
                        
                        [item setValue:[object valueForKey:key] forKey:key];
                    }
                    break;
                }
            }
        }
        else if([action isEqualToString:@"i"])
        {
            if(![Utility duplicate:className record:object])
            {
                [dataList addObject:object];
            }
            
        }
        else if([action isEqualToString:@"d"])
        {
            for(NSObject *item in dataList)
            {
                //replaceSelf ถ้าเท่ากับ 1 ให้ เช็ค column modifiedUser == ตัวเอง ถึงจะมองว่า match (ที่ให้เช็คเท่ากับตัวเอง เนื่องจากแก้ปัญหา duplicate key ตอน insert พร้อมกัน 2 เครื่อง เราลบ record ที่เกิดจากการใส่ id ในแอพออก เพื่อจะ insert record เดิมใหม่ด้วย id ใหม่
                
                //xxxxxxเราดึงข้อมูลของตัวที่ insert ก่อนเข้ามา เพื่อมาลบตัว insert ทีหลังออก แล้ว insert ตัวหลังด้วย ID ใหม่แทน)
                //ถ้าเท่ากับ 0 ให้ remove item โดยการเช็ค ID ตามปกติ
                
                
                BOOL match = NO;
                if([type isEqualToString:@"tProductCategory1"])
                {
                    match = [[item valueForKey:@"code"] isEqualToString:[object valueForKey:@"code"]] && [[item valueForKey:@"productCategory2"] isEqualToString:[object valueForKey:@"productCategory2"]];
                }
                else
                {
                    if([[item valueForKey:strNameID] isKindOfClass:NSString.class])
                    {
                        match = [[item valueForKey:strNameID] isEqualToString:[object valueForKey:strNameID]];
                    }
                    else
                    {
                        match = [[item valueForKey:strNameID] integerValue] == [[object valueForKey:strNameID] integerValue];
                    }
                }
                
                if([[object valueForKey:@"replaceSelf"] integerValue]==1)
                {
                    match = match && [[item valueForKey:@"modifiedUser"] isEqualToString:[object valueForKey:@"modifiedUser"]];
                }
                
                if(match)
                {
                    [dataList removeObject:item];
                    break;
                }
            }
        }
    }
}

+ (void)itemsDownloaded:(NSArray *)items
{
    {
        NSInteger i = 0;
        [SharedUserAccount sharedUserAccount].userAccountList = items[i++];
        [SharedProductName sharedProductName].productNameList = items[i++];
        [SharedColor sharedColor].colorList = items[i++];
        [SharedProduct sharedProduct].productList = items[i++];
        [SharedEvent sharedEvent].eventList = items[i++];
        [SharedUserAccountEvent sharedUserAccountEvent].userAccountEventList = items[i++];
        [SharedProductCategory2 sharedProductCategory2].productCategory2List = items[i++];
        [SharedProductCategory1 sharedProductCategory1].productCategory1List = items[i++];
        [SharedProductSales sharedProductSales].productSalesList = items[i++];
        [SharedCashAllocation sharedCashAllocation].cashAllocationList = items[i++];
        [SharedCustomMade sharedCustomMade].customMadeList = items[i++];
        [SharedReceipt sharedReceipt].receiptList = items[i++];
        [SharedReceiptItem sharedReceiptItem].receiptItemList = items[i++];
        [SharedCompareInventoryHistory sharedCompareInventoryHistory].compareInventoryHistoryList = items[i++];
        [SharedCompareInventory sharedCompareInventory].compareInventoryList = items[i++];
        [SharedProductSalesSet sharedProductSalesSet].productSalesSetList = items[i++];
        [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList = items[i++];
        [SharedPostCustomer sharedPostCustomer].postCustomerList = items[i++];
        [SharedProductCost sharedProductCost].productCostList = items[i++];
        [SharedEventCost sharedEventCost].eventCostList = items[i++];
        [SharedCostLabel sharedCostLabel].costLabelList = items[i++];
        [SharedProductSize sharedProductSize].productSizeList = items[i++];
        [SharedImageRunningID sharedImageRunningID].imageRunningIDList = items[i++];
        [SharedProductDelete sharedProductDelete].productDeleteList = items[i++];
        [SharedSetting sharedSetting].settingList = items[i++];
        [SharedPostCode sharedPostCode].postcodeList = items[i++];
        [SharedRewardPoint sharedRewardPoint].rewardPointList = items[i++];
        [SharedRewardProgram sharedRewardProgram].rewardProgramList = items[i++];
        [SharedPreOrderEventIDHistory sharedPreOrderEventIDHistory].preOrderEventIDHistoryList = items[i++];
    }
}

+ (NSDate *)addDay:(NSDate *)dateFrom numberOfDay:(NSInteger)days
{
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = days;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *addedDate = [theCalendar dateByAddingComponents:dayComponent toDate:dateFrom options:0];
    return addedDate;
}

+ (NSString *)setPhoneNoFormat:(NSString *)text
{
    if([text length] == 0)
    {
        return @"-";
    }
    else if([text length] == 10)
    {
        NSMutableString *mu = [NSMutableString stringWithString:text];
        [mu insertString:@"-" atIndex:3];
        [mu insertString:@"-" atIndex:7];
        return [NSString stringWithString:mu];
    }
    return text;
}

+ (void)setUserDefaultPreOrderEventID:(NSString *) strSelectedEventID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username"];
    NSMutableDictionary *dicPreOrderEventIDByUser = [[defaults dictionaryForKey:@"PreOrderEventIDByUser"] mutableCopy];
    if(!dicPreOrderEventIDByUser)
    {
        dicPreOrderEventIDByUser = [[NSMutableDictionary alloc]init];
    }
    [dicPreOrderEventIDByUser setValue:strSelectedEventID forKey:username];
    [defaults setObject:dicPreOrderEventIDByUser forKey:@"PreOrderEventIDByUser"];
}

+ (NSString *)getUserDefaultPreOrderEventID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username"];
    NSMutableDictionary *dicPreOrderEventIDByUser = [[defaults dictionaryForKey:@"PreOrderEventIDByUser"] mutableCopy];
    if(!dicPreOrderEventIDByUser)
    {
        dicPreOrderEventIDByUser = [[NSMutableDictionary alloc]init];
    }
    NSString *strEventID = [dicPreOrderEventIDByUser objectForKey:username];
    if(!strEventID)
    {
        strEventID = @"0";
        [dicPreOrderEventIDByUser setValue:strEventID forKey:username];
        [defaults setObject:dicPreOrderEventIDByUser forKey:@"PreOrderEventIDByUser"];
    }
    

    return strEventID;

}

+(NSDate *)getEndOfMonth:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];//local time +7]
    NSDateComponents *comps = [NSDateComponents new];
    comps.month = 1;
    NSDate *plusOneMonthDate = [calendar dateByAddingComponents:comps toDate:date options:0];
    NSDate *date1OfMonthDate = [Utility getFirstDateOfMonth:plusOneMonthDate];
    
    
    NSDateComponents *comps2 = [NSDateComponents new];
    comps2.day = -1;
    NSDate *endOfMonth = [calendar dateByAddingComponents:comps2 toDate:date1OfMonthDate options:0];
    
    
    return endOfMonth;
}

+(NSDate *)getFirstDateOfMonth:(NSDate *)date
{
    NSString *date1OfMonth = [Utility dateToString:date toFormat:@"yyyyMM01"];
    NSDate *date1OfMonthDate = [Utility stringToDate:date1OfMonth fromFormat:@"yyyyMMdd"];
    return date1OfMonthDate;
}

+ (NSDate *) currentDateTime
{
    return [Utility GMTDate:[NSDate date]];
}

+(NSArray *)jsonToArray:(NSArray *)arrDataJson arrClassName:(NSArray *)arrClassName
{
    NSMutableArray *arrItem = [[NSMutableArray alloc] init];
    
    
    for(int i=0; i<[arrDataJson count]; i++)
    {
        //arrdatatemp <= arrdata
        NSMutableArray *arrDataTemp = [[NSMutableArray alloc]init];
        NSArray *arrData = arrDataJson[i];
        for(int j=0; j< arrData.count; j++)
        {
            NSDictionary *jsonElement = arrData[j];
            NSObject *object = [[NSClassFromString([Utility getMasterClassName:i from:arrClassName]) alloc] init];
            
            unsigned int propertyCount = 0;
            objc_property_t * properties = class_copyPropertyList([object class], &propertyCount);
            
            for (unsigned int i = 0; i < propertyCount; ++i)
            {
                objc_property_t property = properties[i];
                const char * name = property_getName(property);
                NSString *key = [NSString stringWithUTF8String:name];
                
                
                NSString *dbColumnName = [Utility makeFirstLetterUpperCase:key];
                if(!jsonElement[dbColumnName])
                {
                    continue;
                }
                
                
                if([Utility isDateColumn:dbColumnName])
                {
                    NSDate *date = [Utility stringToDate:jsonElement[dbColumnName] fromFormat:@"yyyy-MM-dd HH:mm:ss"];
                    if(!date)
                    {
                        date = [Utility stringToDate:jsonElement[dbColumnName] fromFormat:@"yyyy-MM-dd"];
                    }
                    [object setValue:date forKey:key];
                }
                else
                {
                    [object setValue:jsonElement[dbColumnName] forKey:key];
                }
            }
            
            [arrDataTemp addObject:object];
        }
        [arrItem addObject:arrDataTemp];
    }
    
    return arrItem;
}

+ (BOOL)isDateColumn:(NSString *)columnName
{
    if([columnName length] < 4)
    {
        return NO;
    }
    NSRange needleRange = NSMakeRange([columnName length]-4,4);
    return [[columnName substringWithRange:needleRange] isEqualToString:@"Date"];
}
+(void)addToSharedDataList:(NSArray *)items
{
    for(int j=0; j<[items count]; j++)
    {
        NSMutableArray *dataGetList = items[j];
        for(int k=0; k<[dataGetList count]; k++)
        {
            NSObject *object = dataGetList[k];
            NSString *className = NSStringFromClass([object class]);
            NSString *strNameID = [Utility getPrimaryKeyFromClassName:className];
            
            
            Class class = NSClassFromString([NSString stringWithFormat:@"Shared%@",className]);
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"shared%@",className]);
            SEL selectorList = NSSelectorFromString([NSString stringWithFormat:@"%@List",[Utility makeFirstLetterLowerCase:className]]);
            NSMutableArray *dataList = [[class performSelector:selector] performSelector:selectorList];
            
            
            if(![Utility duplicate:object])
            {
                [dataList addObject:object];
            }
        }
    }
}


+ (NSString *)getPrimaryKeyFromClassName:(NSString *)className
{
    NSRange needleRange;
    needleRange = NSMakeRange(0,1);
    NSString *firstLetter = [className substringWithRange:needleRange];
    needleRange = NSMakeRange(1,[className length]-1);
    NSString *theRestLetter = [className substringWithRange:needleRange];
    return [NSString stringWithFormat:@"%@%@ID",[firstLetter lowercaseString],theRestLetter];
}

+ (BOOL)duplicate:(NSObject *)object
{
    Class classDB = [object class];
    NSString *className = NSStringFromClass(classDB);
    Class class = NSClassFromString([NSString stringWithFormat:@"Shared%@",className]);
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"shared%@",className]);
    SEL selectorList = NSSelectorFromString([NSString stringWithFormat:@"%@List",[Utility makeFirstLetterLowerCase:className]]);
    NSMutableArray *dataList = [[class performSelector:selector] performSelector:selectorList];
    
    
    NSString *propertyName = [NSString stringWithFormat:@"%@ID",[Utility makeFirstLetterLowerCase:className]];
    NSString *propertyNamePredicate = [NSString stringWithFormat:@"_%@",propertyName];
    NSInteger value = [[object valueForKey:propertyName] integerValue];
    NSString *modifiedUser = [object valueForKey:@"modifiedUser"];
    
    
    if([className isEqualToString:@"Menu"])
    {
        NSInteger branchID = [[object valueForKey:@"branchID"] integerValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %ld and _modifiedUser = %@ and _branchID = %ld",propertyNamePredicate,value,modifiedUser,branchID];
        NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
        
        
        return [filterArray count]>0;
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %ld and _modifiedUser = %@",propertyNamePredicate,value,modifiedUser];
        NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
        
        
        return [filterArray count]>0;
    }
    
}

+(BOOL)isStringEmpty:(NSString *)text
{
    if(!text || [[Utility trimString:text] isEqualToString:@""])
    {
        return YES;
    }
    return NO;
}

@end

