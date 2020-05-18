//
//  Utility.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/14/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeModel.h"
#import "Product.h"
#import "UserAccount.h"
#import "Event.h"
#import "ProductSales.h"
#import "ProductName.h"
#import "CustomMade.h"
#import "ProductSalesSet.h"
#import "Receipt.h"
#import "ProductCost.h"
#import "PostCustomer.h"
#import "ReceiptProductItem.h"
#import "ProductCategory2.h"
#import "ProductCategory1.h"
#import "CustomerReceipt.h"
#import "ProductSize.h"
#import "Color.h"
#import "Setting.h"
#import "ChristmasConstants.h"

enum enumMessage
{
    skipMessage1,
    incorrectPasscode,
    skipMessage2,
    emailSubjectAdd,
    emailBodyAdd,
    emailSubjectReset,
    emailBodyReset,
    emailInvalid,
    emailExisted,
    wrongEmail,
    wrongPassword,
    newPasswordNotMatch,
    changePasswordSuccess,
    emailSubjectChangePassword,
    emailBodyChangePassword,
    newPasswordEmpty,
    passwordEmpty,
    passwordChanged,
    emailSubjectForgotPassword,
    emailBodyForgotPassword,
    forgotPasswordReset,
    forgotPasswordMailSent,
    locationEmpty,
    periodFromEmpty,
    periodToEmpty,
    deleteSubject,
    confirmDeleteUserAccount,
    confirmDeleteEvent,
    periodToLessThanPeriodFrom,
    noEventChosenSubject,
    noEventChosenDetail,
    codeMismatch,
    passwordIncorrect,
    emailIncorrect
    
};
enum enumSetting
{
    vZero,
    vOne,
    vFormatDateDB,
    vFormatDateDisplay,
    vFormatDateTimeDB,
    vBrand,
    vPasscode,
    vAllowUserCount,
    vAdminDeviceToken,
    vAdminEmail,
    vExpiredDate,
    vShippingFee
};
enum enumDB
{
    dbUserAccount,
    dbMessage,
    dbSetting,
    dbEvent,
    dbProduct,
    dbProductScan,
    dbProductMoveToEvent,
    dbProductMoveToMainItem,
    dbProductMoveToMain,
    dbCashAllocationByEventIDAndInputDate,
    dbProductCategory2,
    dbProductCategory1,
    dbProductEventID,
    dbProductStatusByProductID,
    dbProductEventIDByProductID,
    dbUserAccountEventDeleteThenMultipleInsert,
    dbUserAccountEvent,
    dbUserAccountEventByUserAccountID,
    dbReceiptAndProductBuyInsert,
    dbReceiptByEventIDAndDate,
    dbReceiptAndReceiptProductItemDelete,
    dbProductDetail,
    dbProductName,
    dbColor,
    dbMaster,
    dbMasterWithProgressBar,
    dbReceiptProductItemAndProductUpdate,
    dbCompareInventory,
    dbCompareInventoryNotMatchInsert,
    dbProductSalesSet,
    dbProductSales,
    dbProductSalesMultipleUpdate,
    dbReceiptProductItemPreOrder,
    dbReceiptProductItemPreOrderCM,
    dbCustomerReceipt,
    dbPostCustomer,
    dbCustomerReceiptUpdatePostCustomerID,
    dbCustomerReceiptUpdateTrackingNo,
    dbReceiptProductItemUnpost,
    dbReceiptProductItemUnpostCM,
    dbProductCost,
    dbProductSalesUpdateCostMultiple,
    dbEventCost,
    dbProductSize,
    dbProductDeleteFromEvent,
    dbProductSalesUpdateDetail,
    dbProductSalesUpdateCost,
    dbImageRunningID,
    dbProductSalesDeleteProductNameID,
    dbUserAccountDeviceToken,
    dbSettingDeviceToken,
    dbLogin,
    dbPushSync,
    dbPushSyncUpdateByDeviceToken,
    dbReceipt,
    dbCustomMade,
    dbReceiptProductItemUpdateCMIn,
    dbSalesDetail,
    dbItemRunningID,
    dbUserAccountUpdateCountNotSeen,
    dbCredentials,
    dbProductStatus,
    dbSalesSummaryByPeriod,
    dbSalesSummaryByEventByPeriod,
    dbDevice,
    dbAccountInventory,
    dbAccountInventorySummary,
    dbPostCustomerByReceiptID,
    dbAccountReceipt,
    dbAccountReceiptInsert,
    dbAccountInventoryAdded,
    dbAccountReceiptHistory,
    dbAccountReceiptHistoryDetail,
    dbAccountReceiptHistorySummary,
    dbAccountReceiptHistorySummaryByDate,
    dbSalesByChannel,
    dbProductionOrder,
    dbProductionOrderAdded,
    dbProductAndProductionOrder,
    dbMemberAndPoint,
    dbPushSyncUpdateTimeSynced,
    dbTransferHistory,
    dbProductTransfer,
    dbAccountReceiptByPeriod,
    dbReceiptByMember,
    dbRewardProgram,
    dbReceiptProductItemPreOrderEventID,
    dbWriteLog,
    dbEmailQRCode,
    dbPostDetail,
    dbPostDetailSearch,
    dbPostDetailToPost,
    dbMainInventory,
    dbMainInventorySalePrice,
    dbMainInventoryItem,
    dbScanUnpostCM,
    dbScanUnpost,
    dbScanPost,
    dbSalesForDate,
    dbProductDelete,
    dbCustomMadeIn,
    dbCustomMadeOut,
    dbPostCustomerSearch,
    dbEventSalesSummary,
    dbSearchSales,
    dbSearchSalesTelephone,
    dbScanDelete,
    dbScanEvent,
    dbExpenseDaily,
    dbPostCustomerAdd,
    dbItemTrackingNo,
    dbItemTrackingNoPostCustomerAdd,
    dbItemTrackingNoPostCustomerDelete,
    dbReportTopSpender,
    dbReportTopSpenderDetail,
    dbItemTrackingNoTrackingNoUpdate,
    dbReceiptSearch,
    dbSearchSalesTelephoneDetail,
    dbReceiptReferenceOrderNo,
    dbWordPressRegister,
    dbPreOrderProduct,
    dbProductExclude,
    dbMainInventorySummary,
    dbEventInventory,
    dbLazadaPendingOrders,
    dbLazadaFetchOrders
};
enum enumUrl
{
//    urlUserAccountGet,
    urlUserAccountInsert,
    urlUserAccountUpdate,
    urlUserAccountDelete,
    urlMessageGet,
    urlSendEmail,
    urlEventInsert,
    urlEventUpdate,
    urlEventDelete,
    urlProductInsert,
    urlProductUpdate,
    urlProductDelete,
    urlCashAllocationInsert,
    urlCashAllocationUpdate,
    urlPostCustomerInsert,
    urlPostCustomerUpdate,
    urlPostCustomerDelete,
    urlCustomMadeInsert,
    urlCustomMadeDelete,
    urlProductEventIDUpdate,
    urlProductStatusUpdateByProductID,
    urlProductEventIDUpdateByProductID,
    urlUserAccountEventDeleteThenMultipleInsert,
    urlUserAccountEventDelete,
    urlReceiptAndProductBuyInsert,
    urlReceiptAndReceiptProductItemDelete,
    urlMasterGet,
    urlMasterNewGet,
    urlMasterProductOnlyGet,
    urlReceiptProductItemAndProductUpdate,
    urlCompareInventoryInsert,
    urlCompareInventoryUpdate,
    urlCompareInventoryNotMatchInsert,
    urlProductSalesSetInsert,
    urlProductSalesSetDelete,
    urlProductSalesSetUpdate,
    urlProductSalesUpdate,
    urlProductSalesMultipleUpdate,
    urlReceiptProductItemPreOrder,
    urlReceiptProductItemPreOrderCM,
    urlCustomerReceiptUpdatePostCustomerID,
    urlCustomerReceiptUpdateTrackingNo,
    urlReceiptProductItemUnpost,
    urlReceiptProductItemUnpostCM,
    urlProductCostUpdate,
    urlEventCostInsert,
    urlEventCostDelete,
    urlProductCategory2Delete,
    urlProductCategory1Delete,
    urlProductCategory2Update,
    urlProductCategory2Insert,
    urlProductCategory1Update,
    urlProductCategory1Insert,
    urlColorDelete,
    urlColorUpdate,
    urlColorInsert,
    urlProductSizeDelete,
    urlProductSizeUpdate,
    urlProductSizeInsert,
    urlProductDeleteFromEvent,
    urlProductNameDelete,
    urlProductNameInsert,
    urlProductNameUpdate,
    urlProductSalesInsert,
    urlProductSalesDelete,
    urlUploadPhoto,
    urlDownloadPhoto,
    urlProductSalesUpdateDetail,
    urlProductSalesUpdateCost,
    urlProductSalesUpdateCostMultiple,
    urlImageRunningIDInsert,
    urlGenerateSales,
    urlGenerateSalesAllEvent,
    urlDownloadFile,
    urlProductSalesDeleteProductNameID,
    urlUserAccountDeviceTokenUpdate,
    urlSettingDeviceTokenUpdate,
    urlSettingUpdate,
    urlLoginInsert,
//    urlPushSyncUpdate,
    urlPushSyncSync,
    urlPushSyncUpdateByDeviceToken,
    urlReceiptUpdate,
    urlCustomMadeUpdate,
    urlReceiptProductItemUpdateCMIn,
    urlSalesDetailGet,
    urlItemRunningIDInsert,
    urlUserAccountUpdateCountNotSeen,
    urlCredentialsValidate,
    urlProductStatusGet,
    urlSalesSummaryGet,
    urlSalesSummaryByEventByPeriodGet,
    urlSalesSummaryByPeriodGet,
    urlDeviceInsert,
    urlAccountInventoryInsert,
    urlAccountInventorySummary,
    urlPostCustomerByReceiptID,
    urlAccountReceiptGet,
    urlAccountReceiptInsert,
    urlAccountInventoryAdded,
    urlAccountInventoryDelete,
    urlAccountReceiptHistoryGet,
    urlAccountReceiptHistoryDelete,
    urlAccountReceiptHistoryDetailGet,
    urlAccountReceiptHistorySummaryGet,
    urlAccountReceiptHistorySummaryByDateGet,
    urlSalesByChannelGet,
    urlProductionOrderInsert,
    urlProductionOrderAdded,
    urlProductionOrderDelete,
    urlProductAndProductionOrderInsert,
    urlMemberAndPointGet,
    urlPushSyncUpdateTimeSynced,
    urlTransferHistoryGet,
    urlProductTransferGet,
    urlAccountReceiptByPeriod,
    urlReceiptByMember,
    urlRewardProgramGet,
    urlRewardProgramInsert,
    urlRewardProgramUpdate,
    urlRewardProgramDelete,
    urlReceiptProductItemPreOrderEventID,
    urlWriteLog,
    urlEmailQRCode,
    urlPostDetailSearchGet,
    urlPostDetailToPostGet,
    urlMainInventoryGet,
    urlMainInventorySalePriceGet,
    urlMainInventoryItemGet,
    urlScanUnpostCM,
    urlScanUnpost,
    urlScanPost,
    urlPostCustomerGetList,
    urlCustomMadeIn,
    urlCustomMadeOut,
    urlSalesForDateGet,
    urlProductDeleteGetList,
    urlProductSalesGetList,
    urlPostCustomerSearchGetList,
    urlEventSalesSummaryGetList,
    urlSearchSalesGetList,
    urlSearchSalesTelephoneGetList,
    urlScanDelete,
    urlScanEvent,
    urlExpenseDailyGetList,
    urlExpenseDailyInsert,
    urlExpenseDailyDelete,
    urlPostCustomerAddInsert,
    urlItemTrackingNoUpdate,
    urlItemTrackingNoPostCustomerAddInsert,
    urlReportTopSpenderGetList,
    urlReportTopSpenderDetailGetList,
    urlItemTrackingNoTrackingNoUpdate,
    urlSearchSalesTelephoneDetailGetList,
    urlReceiptReferenceOrderNoUpdate,
    urlWordPressRegisterInsert,
    urlMainInventoryItemDelete,
    urlProductMoveToMainUpdate,
    urlProductMoveToMainItemUpdate,
    urlProductMoveToEventUpdate,
    urlProductScanGet,
    urlPreOrderProductGetList,
    urlProductExcludeGet,
    urlMainInventorySummaryGetList,
    urlEventInventoryGetList,
    urlLazadaPendingOrdersGetList,
    urlLazadaFetchOrdersGetList
    
};
enum enumTableName
{
    tblCashAllocation,
    tblColor,
    tblCompareInventory,
    tblCompareInventoryHistory,
    tblCostLabel,
    tblCustomerReceipt,
    tblCustomMade,
    tblEvent,
    tblEventCost,
    tblEventSalesSummary,
    tblEventSalesSummaryByDate,
    tblImageRunningID,
    tblLogin,
    tblMessage,
    tblPost,
    tblPostCustomer,
    tblPostDetail,
    tblProduct,
    tblProductCategory1,
    tblProductCategory2,
    tblProductCost,
    tblProductDelete,
    tblProductDetail,
    tblProductItem,
    tblProductName,
    tblProductSales,
    tblProductSalesSet,
    tblProductSize,
    tblProductSource,
    tblProductWithQuantity,
    tblPushSync,
    tblReceipt,
    tblReceiptProductItem,
    tblSalesByColorData,
    tblSalesByItemData,
    tblSalesByPriceData,
    tblSalesBySizeData,
    tblSalesSummary,
    tblSetting,
    tblUserAccount,
    tblUserAccountEvent,
    tblRewardPoint,
    tblRewardProgram,
    tblPreOrderEventIDHistory
};
enum enumReceiptInsert
{
    receiptInsertType,
    receiptInsertData,
    receiptInsertPriceSales,
//    receiptInsertPost,
    receiptInsertReceiptProductItemID
};
enum enumProductType
{
    productInventory,
    productCustomMade,
    productPreOrder,
    productPreOrder2
};
enum enumReceipt
{
    receiptSales,
    receiptCustomer,
    receiptPostCustomer,
    receiptProductInventory,
    receiptProductCustomMade
};
enum enumProductBuy
{
    productType,
    productBuyDetail,
    productBuyImageFileName,
    price,
    productBuyPricePromotion,
    eProductIDGroup
};
enum enumProductLabel
{
    enumProductLabelProductName,
    enumProductLabelColor,
    enumProductLabelSize,
    enumProductLabelPrice,
    enumProductLabelStringQRCode
};
@interface Utility : NSObject

+ (NSString *) randomStringWithLength: (int) len;
+ (BOOL) validateEmailWithString:(NSString*)email;
+ (NSString *) msg:(enum enumMessage)eMessage;
+ (NSString *) setting:(enum enumSetting)eSetting;
+ (NSString *) url:(enum enumUrl)eUrl;
+ (void) setPingAddress:(NSString *)pingAddress;
+ (NSString *) pingAddress;
+ (void) setDomainName:(NSString *)domainName;
+ (NSString *) domainName;
+ (void) setSubjectNoConnection:(NSString *)subjectNoConnection;
+ (NSString *) subjectNoConnection;
+ (void) setDetailNoConnection:(NSString *)detailNoConnection;
+ (NSString *) detailNoConnection;
+ (void)setCipher:(NSString *)cipher;
+ (NSString *) cipher;
+ (NSString *) deviceToken;
+ (NSInteger) deviceID;
+ (NSString *) dbName;
+ (NSString *) formatDate:(NSString *)strDate fromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat;
+ (NSString *) formatDateForDB:(NSString *)strDate;
+ (NSString *) formatDateForDisplay:(NSString *)strDate;
+ (NSDate *) stringToDate:(NSString *)strDate fromFormat:(NSString *)fromFormat;
+ (NSString *) dateToString:(NSDate *)date toFormat:(NSString *)toFormat;
+ (NSDate *) setDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
//+ (NSData *) encrypt:(NSString *)data;
//+ (NSString *) decrypt:(NSData *)encryptedData;
+(NSString *)getProductIDGroupWithProductCode:(NSString *)productCode;
+ (Product *) getProductWithProductCode:(NSString *)productCode;
+ (NSInteger) numberOfDaysFromDate:(NSDate *)dateFrom dateTo:(NSDate *)dateTo;
+ (NSInteger) numberOfDaysInEvent:(NSInteger)eventID;
+ (NSDate *) dateFromDateTime:(NSDate *)dateTime;
+ (NSInteger) dayFromDateTime:(NSDate *)dateTime;
+ (NSDate *) GMTDate:(NSDate *)dateTime;
+ (NSString *)percentEscapeString:(NSString *)string;
+ (NSString *)concatParameter:(NSDictionary *)condition;
+ (NSString *) getNoteDataString: (NSObject *)object;
+ (NSString *) getNoteDataString: (NSObject *)object withRunningNo:(long)runningNo;
+ (NSString *) getNoteDataString: (NSObject *)object withRunningNo3Digit:(long)runningNo;
+ (NSObject *) trimAndFixEscapeString: (NSObject *)object;
+ (NSString *) currentDateTimeStringForDB;
+ (NSString *)formatBaht:(NSString *)number;
+ (NSString *)formatBaht:(NSString *)number withMinFraction:(NSInteger)min andMaxFraction:(NSInteger)max;
+ (NSString *)getProductName:(NSString *)productNameGroupInput;
+ (CustomMade *)getCustomMade:(NSInteger)customMadeID;
+ (CustomMade *)getCustomMadeFromProductIDPost:(NSString *)productIDPost;
+ (NSString *)getUsername:(NSInteger)userAccountID;
+ (Color *)getColor:(NSString *)colorCode;
+ (NSString *)getColorName:(NSString *)colorCode;
+ (NSString *)getEventName:(NSInteger)eventID;
+ (Event *)getEvent:(NSInteger)eventID;
+ (ProductSales *)getProductSales:(NSInteger)productNameID color:(NSString *)color size:(NSString *)size productSalesSetID:(NSString *)productSalesSetID;
+ (ProductSales *)getProductCost:productType productID:(NSString *)productID;
+ (ProductSalesSet *)getProductSalesSet:(NSString *)productSalesSetID;
+ (NSString *)getProductSalesSetName:(NSString *)productSalesSetID;
+ (ProductSales *)getProductSalesFromProductID:(NSString *)productID productType:(enum enumProductType)productType event:(Event *)event;
+ (ProductSales *)getProductSales:(NSInteger)productSalesID;
+ (NSString *)trimString:(NSString *)text;
+ (NSString *)getProductCode:(Product *)product;
+ (Receipt *)getReceipt:(NSInteger)receiptID;
+ (ReceiptProductItem *)getReceiptProductItem:(NSInteger)receiptProductItemID;
+ (NSArray *)getReceiptProductItemList:(NSInteger)receiptID;
+ (ProductSize *)getSize:(NSString *)code;
+ (NSString *)getSizeLabel:(NSString *)code;
+ (NSInteger)getSizeOrder:(NSString *)code;
+ (NSInteger) getPostCustomerID:(NSInteger)receiptID;
+ (PostCustomer *) getPostCustomer:(NSInteger)postCustomerID;
+ (NSInteger)getNextImageRunningID;
+ (ProductCategory2 *)getProductCategory2:(NSString *)code;
+ (ProductCategory1 *)getProductCategory1:(NSString *)code productCategory2:(NSString *)productCategory2;
+ (NSString *)insertDash:(NSString *)text;
+ (NSString *)removeDashAndSpaceAndParenthesis:(NSString *)text;
+ (NSString *)removeComma:(NSString *)text;
+ (NSString *)removeApostrophe:(NSString *)text;
+ (NSString *)removeKeyword:(NSArray *)arrKeyword text:(NSString *)text;
+ (NSInteger)getCustomMadeIDFromProductIDPost:(NSString *)productIDPost;
+ (NSString *)modifiedUser;
+ (void)setModifiedUser:(NSString *)modifiedUser;
+ (NSString *)getProductIDGroup:(Product *)product;
+ (NSString *)getProductIDGroupMdf:(Product *)product;
+ (NSInteger)getNoOfPairReceipt:(Receipt *)receipt;
+ (NSString *)getCurrentDateString:(NSString *)format;
+ (NSString *)getDeviceTokenFromUsername:(NSString *)username;
+ (BOOL)alreadySynced:(NSInteger)pushSyncID;
+ (BOOL) finishLoadSharedData;
+ (void) setFinishLoadSharedData:(BOOL)finish;
+ (NSData *)dataFromHexString:(NSString *)string;
+ (NSString *)getNextProductID;
+ (NSInteger)getNextID:(enum enumTableName)tableName;
+ (NSString *)makeFirstLetterLowerCase:(NSString *)text;
+ (NSString *)makeFirstLetterUpperCase:(NSString *)text;
+ (NSString *)makeFirstLetterUpperCaseOtherLower:(NSString *)text;
+ (NSString *)getStringNameID:(NSString *)className;
+ (NSString *)getMasterClassName:(NSInteger)i;
+ (NSString *)getMasterClassName:(NSInteger)i from:(NSArray *)arrClassName;
//+ (NSString *)getDecryptedHexString:(NSString *)hexString;
+ (BOOL)isValidProduct:(Product*)product error:(NSString **)error;
+ (CustomerReceipt *)getCustomerReceiptFromPostCustomerID:(NSInteger)postCustomerID;
+ (NSString *)getSqlFailTitle;
+ (NSString *)getSqlFailMessage;
+ (NSString *)getConnectionLostTitle;
+ (NSString *)getConnectionLostMessage;
+ (NSInteger)getNumberOfRowForExecuteSql;
+ (NSString *)getAppKey;
+ (NSString *)getAppSecret;
+ (BOOL)getMenuExtra;
+ (NSAttributedString *)getCountWithRemarkText:(NSInteger)count remark:(NSString *)remark;
+ (NSInteger)getScanTimeInterVal;
+ (NSInteger)getScanTimeInterValCaseBlur;
+ (Setting *)getSetting:(NSInteger)settingID;
+ (BOOL)duplicate:(NSString *)className record:(NSObject *)object;
+ (NSString *)getPricePromotion:(Product *)product eventID:(NSInteger)eventID;
+ (void)setEventSales:(NSString *)data  eventID:(NSInteger)eventID;
+ (BOOL)hasEventSales:(NSInteger)eventID;
+ (float)floatValue:(NSString *)text;
+ (NSInteger)getLastDayOfMonth:(NSDate *)datetime;
+ (void)itemsSynced:(NSString *)type action:(NSString *)action data:(NSArray *)data;
+ (void)itemsDownloaded:(NSArray *)items;
+ (NSDate *)addDay:(NSDate *)dateFrom numberOfDay:(NSInteger)days;
+ (NSString *)setPhoneNoFormat:(NSString *)text;
+ (void)setUserDefaultPreOrderEventID:(NSString *) strSelectedEventID;
+ (NSString *)getUserDefaultPreOrderEventID;
+(NSDate *)getEndOfMonth:(NSDate *)date;
+(NSDate *)getFirstDateOfMonth:(NSDate *)date;
+ (NSDate *) currentDateTime;
+(NSArray *)jsonToArray:(NSArray *)arrDataJson arrClassName:(NSArray *)arrClassName;
+ (BOOL)isDateColumn:(NSString *)columnName;
+(void)addToSharedDataList:(NSArray *)items;
+ (NSString *)getPrimaryKeyFromClassName:(NSString *)className;
+ (BOOL)duplicate:(NSObject *)object;
+(BOOL)isStringEmpty:(NSString *)text;

@end

