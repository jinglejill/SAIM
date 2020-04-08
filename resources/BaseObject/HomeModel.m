//
//  HomeModel.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//
#import <objc/runtime.h>
#import "HomeModel.h"
#import "UserAccount.h"
#import "Message.h"
#import "Utility.h"
#import "Setting.h"
#import "Event.h"
#import "Product.h"
#import "ProductWithQuantity.h"
#import "ProductDetail.h"
#import "SalesSummary.h"
#import "CashAllocation.h"
#import "ProductSource.h"
#import "ProductCategory2.h"
#import "ProductCategory1.h"
#import "ProductSales.h"
#import "CustomMade.h"
#import "UserAccountEvent.h"
#import "Receipt.h"
#import "ReceiptProductItem.h"
#import "ProductName.h"
#import "Color.h"
#import "SharedSelectedEvent.h"
#import "CompareInventoryHistory.h"
#import "CompareInventory.h"
#import "SalesByItemData.h"
#import "SalesBySizeData.h"
#import "SalesByColorData.h"
#import "SalesByPriceData.h"
#import "EventSalesSummary.h"
#import "EventSalesSummaryByDate.h"
#import "ProductSalesSet.h"
#import "CustomerReceipt.h"
#import "PostCustomer.h"
#import "ProductCost.h"
#import "EventCost.h"
#import "CostLabel.h"
#import "ProductSize.h"
#import "ImageRunningID.h"
#import "ProductDelete.h"
#import "PushSync.h"
#import "AccountInventory.h"
#import "AccountInventorySummary.h"
#import "AccountReceipt.h"
#import "AccountReceiptProductItem.h"
#import "AccountMapping.h"
#import "RewardPoint.h"
#import "ProductionOrder.h"
#import "RewardProgram.h"
#import "PreOrderEventIDHistory.h"
#import "EmailQRCode.h"
#import "PostDetail.h"
#import "ExpenseDaily.h"
#import "ItemTrackingNo.h"


#import "SharedProductSales.h"
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

@interface HomeModel()
{
    NSMutableData *_downloadedData;
    enum enumDB _currentDB;
    BOOL _downloadSuccess;
}
@end
@implementation HomeModel
@synthesize propCurrentDB;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(!error)
    {
        NSLog(@"Download is Successful");
        switch (propCurrentDB) {
            case dbMasterWithProgressBar:
            case dbMaster:
//            case dbMainInventorySalePrice:
                if(!_downloadSuccess)//กรณีไม่มี content length จึงไม่รู้ว่า datadownload/downloadsize = 1 -> _downloadSuccess จึงไม่ถูก set เป็น yes
                {
                    NSLog(@"content length = -1");
                    [self prepareData];
                }
                break;
            
                
            default:
                break;
        }
    }
    else
    {
        NSLog(@"Error %@",[error userInfo]);
        if (self.delegate)
        {
            [self.delegate connectionFail];
        }
    }
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)dataRaw;
{
    NSArray *arrClassName;
    
    
    switch (propCurrentDB)
    {
        case dbSalesDetail:
        case dbProductStatus:
        case dbSalesSummaryByPeriod:
        {
            arrClassName = @[@"Product",@"Receipt",@"ReceiptProductItem"];
        }
            break;
        case dbSalesSummaryByEventByPeriod:
        {
            arrClassName = @[@"Product",@"Receipt",@"ReceiptProductItem",@"CustomMade"];
        }
            break;
        case dbAccountInventorySummary:
        {
            arrClassName = @[@"AccountInventorySummary",@"SalesProductAndPrice"];
        }
            break;
        case dbPostCustomerByReceiptID:
        {
            arrClassName = @[@"PostCustomer",@"AccountReceipt",@"AccountReceiptProductItem",@"AccountMapping",@"AccountInventory"];
        }
            break;
        case dbAccountInventoryAdded:
        {
            arrClassName = @[@"AccountInventory"];
        }
            break;
        case dbAccountReceiptHistory:
        {
            arrClassName = @[@"AccountReceipt"];
        }
        break;
        case dbAccountReceiptHistoryDetail:
        {
            arrClassName = @[@"AccountReceipt",@"AccountReceiptProductItem"];
        }
        break;
        case dbAccountReceiptHistorySummary:
        {
            arrClassName = @[@"AccountReceiptHistorySummary"];
        }
            break;
        case dbAccountReceiptHistorySummaryByDate:
        {
            arrClassName = @[@"AccountReceiptHistorySummary"];
        }
            break;
        case dbSalesByChannel:
        {
            arrClassName = @[@"SalesByChannel"];
        }
            break;
        case dbProductionOrderAdded:
        {
            arrClassName = @[@"ProductionOrder"];
        }
            break;
        case dbTransferHistory:
        {
            arrClassName = @[@"TransferHistory"];
        }
            break;
        case dbPostCustomer:
        {
            arrClassName = @[@"PostCustomer"];
        }
            break;
        case dbMainInventory:
        {
            arrClassName = @[@"ProductName",@"Color",@"ProductCategory2",@"ProductCategory1",@"ProductSize",@"Product"];
        }
            break;
        case dbMainInventoryItem:
        {
            arrClassName = @[@"ProductItem"];
        }
            break;
        case dbCustomMadeIn:
        {
            arrClassName = @[@"PostDetail"];
        }
            break;
        case dbCustomMadeOut:
        {
            arrClassName = @[@"PostDetail"];
        }
            break;
        case dbSalesForDate:
        {
            arrClassName = @[@"Receipt",@"ReceiptProductItem",@"Product",@"CustomMade",@"ItemTrackingNo",@"PostCustomer",@"PreOrderEventIDHistory",@"ExpenseDaily",@"CashAllocation"];
        }
            break;
        case dbReportTopSpenderDetail:
        case dbReceiptSearch:
        case dbSearchSalesTelephoneDetail:
        {
            arrClassName = @[@"Receipt",@"ReceiptProductItem",@"Product",@"CustomMade",@"ItemTrackingNo",@"PostCustomer",@"Event"];
        }
            break;
        case dbProductDelete:
        {
            arrClassName = @[@"ProductDelete"];
        }
            break;
        case dbMainInventorySalePrice:
        {
            arrClassName = @[@"ProductName",@"Color",@"ProductCategory2",@"ProductCategory1",@"ProductSize",@"Product",@"ProductSales"];
        }
            break;
        case dbProductSales:
        {
            arrClassName = @[@"ProductSales"];
        }
            break;
        case dbPostCustomerSearch:
        {
            arrClassName = @[@"PostCustomer"];
        }
            break;
        case dbEventSalesSummary:
        {
            arrClassName = @[@"EventSalesSummaryByDate",@"EventCost",@"EventCost"];
        }
            break;
        case dbSearchSales:
        {
            arrClassName = @[@"PostCustomer"];
        }
            break;
        case dbSearchSalesTelephone:
        {
            arrClassName = @[@"ReceiptProductItem"];
        }
            break;
        case dbProductTransfer:
        {
            arrClassName = @[@"ProductTransfer"];
        }
            break;
        case dbMemberAndPoint:
        {
            arrClassName = @[@"MemberAndPoint",@"MemberAndPoint",@"MemberAndPoint"];
        }
            break;
        case dbAccountReceiptByPeriod:
        {
            arrClassName = @[@"AccountReceipt",@"AccountReceiptProductItem"];
        }
            break;
        case dbReceiptByMember:
        {
            arrClassName = @[@"Receipt",@"ReceiptProductItem"];
        }
            break;
        case dbRewardProgram:
        {
            arrClassName = @[@"RewardProgram",@"RewardProgram"];
        }
            break;
        case dbAccountReceipt:
        {
            arrClassName = @[@"AccountReceipt"];
        }
        break;
        case dbPostDetail:
        case dbPostDetailSearch:
        case dbPostDetailToPost:
        {
            arrClassName = @[@"PostDetail"];
        }
        break;
        case dbExpenseDaily:
        {
            arrClassName = @[@"ExpenseDaily",@"OftenUse"];
        }
            break;
        case dbReportTopSpender:
        {
            arrClassName = @[@"TopSpender"];
        }
            break;
        default:
            break;
    }
    
    switch (propCurrentDB) {
        case dbMaster:
        case dbMasterWithProgressBar:
//        case dbMainInventorySalePrice:
        {
            [_dataToDownload appendData:dataRaw];
            if(propCurrentDB == dbMasterWithProgressBar)
            {
                if(self.delegate)
                {
                    [self.delegate downloadProgress:[_dataToDownload length ]/_downloadSize];
                }
            }
            
            
            if([ _dataToDownload length ]/_downloadSize == 1.0f)
            {
                _downloadSuccess = YES;
                [self prepareData];
            }
        }
            break;
        case dbSalesDetail:
        case dbProductStatus:
        case dbSalesSummaryByPeriod:
        case dbRewardProgram:
        {
            [_dataToDownload appendData:dataRaw];
            if([ _dataToDownload length ]/_downloadSize == 1.0f)
            {
                NSMutableArray *arrItem = [[NSMutableArray alloc] init];
                
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:_dataToDownload options:NSJSONReadingAllowFragments error:nil];
                
                                
                for(int i=0; i<[jsonArray count]; i++)
                {
                    //arrdatatemp <= arrdata
                    NSMutableArray *arrDataTemp = [[NSMutableArray alloc]init];
                    NSArray *arrData = jsonArray[i];
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
                            
                            [object setValue:jsonElement[dbColumnName] forKey:key];
                        }
                        
                        //ถ้า id นี้ยังไม่มีก็ add ไม่งั้นไม่ต้อง โดยเช็ค id และ modifieduser
                        if(![Utility duplicate:arrClassName[i] record:object])
                        {
                            [arrDataTemp addObject:object];
                        }
                    }
                    [arrItem addObject:arrDataTemp];
                }
                
                // Ready to notify delegate that data is ready and pass back items
                if (self.delegate)
                {
                    [self.delegate itemsDownloaded:arrItem];
                }
            }            
        }
            break;
        //สำหรับ ไม่ใช้ Shared model
        case dbSalesSummaryByEventByPeriod:
        case dbAccountInventorySummary:
        case dbPostCustomerByReceiptID:
        case dbAccountInventoryAdded:
        case dbAccountReceiptHistory:
        case dbAccountReceiptHistoryDetail:
        case dbAccountReceiptHistorySummary:
        case dbAccountReceiptHistorySummaryByDate:
        case dbSalesByChannel:
        case dbProductionOrderAdded:
        case dbTransferHistory:
        case dbPostCustomer:
        case dbMainInventory:
        case dbMainInventoryItem:
        case dbCustomMadeIn:
        case dbCustomMadeOut:
        case dbSalesForDate:
        case dbProductDelete:
//        case dbMainInventorySalePrice:
        case dbProductSales:
        case dbPostCustomerSearch:
        case dbEventSalesSummary:
        case dbSearchSales:
        case dbSearchSalesTelephone:
        case dbProductTransfer:
        case dbMemberAndPoint:
        case dbAccountReceiptByPeriod:
        case dbReceiptByMember:
        case dbAccountReceipt:
        case dbPostDetail:
        case dbPostDetailSearch:
        case dbPostDetailToPost:
        case dbExpenseDaily:
        case dbReportTopSpender:
        case dbReportTopSpenderDetail:
        case dbReceiptSearch:
        case dbSearchSalesTelephoneDetail:
        {
            [_dataToDownload appendData:dataRaw];
            if([ _dataToDownload length ]/_downloadSize == 1.0f)
            {
                NSMutableArray *arrItem = [[NSMutableArray alloc] init];
                
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:_dataToDownload options:NSJSONReadingAllowFragments error:nil];
                
                
                for(int i=0; i<[jsonArray count]; i++)
                {
                    //arrdatatemp <= arrdata
                    NSMutableArray *arrDataTemp = [[NSMutableArray alloc]init];
                    NSArray *arrData = jsonArray[i];
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
                            
                            [object setValue:jsonElement[dbColumnName] forKey:key];
                        }
                        
                        [arrDataTemp addObject:object];
                    }
                    [arrItem addObject:arrDataTemp];
                }
                
                // Ready to notify delegate that data is ready and pass back items
                if (self.delegate)
                {
                    [self.delegate itemsDownloaded:arrItem];
                }
            }
        }
            break;
        default:
            break;
    }
}
-(void)prepareData
{
    NSMutableArray *arrItem = [[NSMutableArray alloc] init];
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:_dataToDownload options:NSJSONReadingAllowFragments error:nil];
    
    //check loaded data ให้ไม่ต้องใส่ data แล้ว ไปบอก delegate ว่าให้ show alert error occur, please try again
    if([jsonArray count] == 0)
    {
        if (self.delegate)
        {
            [self.delegate itemsDownloaded:arrItem];
        }
        return ;
    }
    
    for(int i=0; i<[jsonArray count]; i++)
    {
        //arrdatatemp <= arrdata
        NSMutableArray *arrDataTemp = [[NSMutableArray alloc]init];
        NSArray *arrData = jsonArray[i];
        for(int j=0; j< arrData.count; j++)
        {
            NSDictionary *jsonElement = arrData[j];
            NSObject *object = [[NSClassFromString([Utility getMasterClassName:i]) alloc] init];;
//            NSObject *object;
//            if()
//            {
//                object = [[NSClassFromString([Utility getMasterClassName:i]) alloc] init];
//            }
//            else
//            {
//                object = [[NSClassFromString([Utility getMasterClassName:i]) alloc] init];
//            }
            
            
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
            
            [arrDataTemp addObject:object];
        }
        [arrItem addObject:arrDataTemp];
    }
    
    
    // Ready to notify delegate that data is ready and pass back items
    if (self.delegate)
    {
        [self.delegate itemsDownloaded:arrItem];
    }
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    
    switch (propCurrentDB) {
        case dbMasterWithProgressBar:
        {
            if(self.delegate)
            {
                [self.delegate downloadProgress:0.0f];
            }
        }
            break;
        default:
            break;
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSLog(@"expected content length httpResponse: %ld", (long)[httpResponse expectedContentLength]);
    
    NSLog(@"expected content length response: %lld",[response expectedContentLength]);
    _downloadSize=[response expectedContentLength];
    _dataToDownload=[[NSMutableData alloc]init];
}

- (void)downloadItems:(enum enumDB)currentDB
{
    propCurrentDB = currentDB;
    NSString *url;
    switch (currentDB)
    {
        case dbMaster:
        {
            url = [NSString stringWithFormat:[Utility url:urlMasterGet],[Utility randomStringWithLength:6]];
        }
            break;
        case dbMasterWithProgressBar:
        {
            url = [NSString stringWithFormat:[Utility url:urlMasterNewGet],[Utility randomStringWithLength:6]];
        }
            break;        
        case dbTransferHistory:
        {
            url = [NSString stringWithFormat:[Utility url:urlTransferHistoryGet],[Utility randomStringWithLength:6]];
        }
            break;
        case dbMainInventory:
        {
            url = [NSString stringWithFormat:[Utility url:urlMainInventoryGet],[Utility randomStringWithLength:6]];
        }
            break;
        case dbPostCustomer:
        {
            url = [NSString stringWithFormat:[Utility url:urlPostCustomerGetList],[Utility randomStringWithLength:6]];
        }
            break;
        default:
            break;
    }
    NSURL *nsURL = [NSURL URLWithString:url];
    NSString *noteDataString = @"";
    noteDataString = [NSString stringWithFormat:@"modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
    NSLog(@"notedatastring: %@",noteDataString);
    NSLog(@"url: %@",url);
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    
    
//    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL: nsURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:nsURL];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest];
    
    [dataTask resume];
}

- (void)downloadItems:(enum enumDB)currentDB condition:(NSObject *)object
{
    propCurrentDB = currentDB;
    NSString *url;
    NSString *noteDataString = @"";
    switch (currentDB)
    {
        case dbSalesDetail:
        {
            url = [NSString stringWithFormat:[Utility url:urlSalesDetailGet],[Utility randomStringWithLength:6]];
            noteDataString = [Utility getNoteDataString:object];
        }
            break;
        case dbProductStatus:
        {
            url = [NSString stringWithFormat:[Utility url:urlProductStatusGet],[Utility randomStringWithLength:6]];
            noteDataString = [Utility getNoteDataString:object];
        }
            break;
        case dbSalesSummaryByEventByPeriod:
        {
            NSArray *dataList = (NSArray *)object;
            Event *event = dataList[0];
            NSString *startDate = dataList[1];
            NSString *endDate = dataList[2];
            
            url = [NSString stringWithFormat:[Utility url:urlSalesSummaryByEventByPeriodGet],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"eventID=%ld&startDate=%@&endDate=%@",event.eventID,startDate,endDate];
        }
            break;
        case dbSalesSummaryByPeriod:
        {
            url = [NSString stringWithFormat:[Utility url:urlSalesSummaryGet],[Utility randomStringWithLength:6]];
            noteDataString = [Utility getNoteDataString:object];
        }
            break;
        case dbAccountInventorySummary:
        {
            url = [NSString stringWithFormat:[Utility url:urlAccountInventorySummary],[Utility randomStringWithLength:6]];
            NSArray *arrData = (NSArray *)object;
            NSString *dateFrom = arrData[0];
            NSString *dateTo = arrData[1];
            
            noteDataString = [NSString stringWithFormat:@"dateFrom=%@&dateTo=%@",dateFrom,dateTo];
        }
            break;
        case dbPostCustomerByReceiptID:
        {
            url = [NSString stringWithFormat:[Utility url:urlPostCustomerByReceiptID],[Utility randomStringWithLength:6]];
            
            NSArray *data = (NSArray *)object;
            NSArray *arrReceiptIDList = data[0];
            NSString *accountYearMonth = data[1];
            int count = 0;
            for(NSNumber *item in arrReceiptIDList)
            {
                noteDataString = [NSString stringWithFormat:@"%@receiptID%03d=%@&",noteDataString,count,item];
                count++;
            }
            noteDataString = [NSString stringWithFormat:@"%@countReceipt=%d&",noteDataString,count];
            noteDataString = [NSString stringWithFormat:@"%@accountYearMonth=%@",noteDataString,accountYearMonth];
        }
            break;
        case dbAccountInventoryAdded:
        {
            url = [NSString stringWithFormat:[Utility url:urlAccountInventoryAdded],[Utility randomStringWithLength:6]];
            
            NSArray *data = (NSArray *)object;
            NSString *productCategory2 = data[0];
            NSString *dateIn = data[1];
            
            noteDataString = [NSString stringWithFormat:@"productCategory2=%@&dateIn=%@",productCategory2,dateIn];
        }
            break;
        case dbAccountReceiptHistory:
        {
            url = [NSString stringWithFormat:[Utility url:urlAccountReceiptHistoryGet],[Utility randomStringWithLength:6]];
            
            
            NSString *accountReceiptHistoryDate = (NSString *)object;
            noteDataString = [NSString stringWithFormat:@"accountReceiptHistoryDate=%@",accountReceiptHistoryDate];
        }
            break;
        case dbAccountReceiptHistoryDetail:
        {
            url = [NSString stringWithFormat:[Utility url:urlAccountReceiptHistoryDetailGet],[Utility randomStringWithLength:6]];
            
            
            AccountReceipt *accountReceipt = (AccountReceipt *)object;
            noteDataString = [NSString stringWithFormat:@"runningAccountReceiptHistory=%ld",accountReceipt.runningAccountReceiptHistory];
        }
            break;
        case dbAccountReceiptHistorySummary:
        {
            url = [NSString stringWithFormat:[Utility url:urlAccountReceiptHistorySummaryGet],[Utility randomStringWithLength:6]];
            
            
            AccountReceipt *accountReceipt = (AccountReceipt *)object;
            noteDataString = [NSString stringWithFormat:@"runningAccountReceiptHistory=%ld",accountReceipt.runningAccountReceiptHistory];
        }
            break;
        case dbAccountReceiptHistorySummaryByDate:
        {
            url = [NSString stringWithFormat:[Utility url:urlAccountReceiptHistorySummaryByDateGet],[Utility randomStringWithLength:6]];
            
            
            NSArray *arrData = (NSArray *)object;
            NSString *dateFrom = arrData[0];
            NSString *dateTo = arrData[1];
            
            noteDataString = [NSString stringWithFormat:@"dateFrom=%@&dateTo=%@",dateFrom,dateTo];
        }
            break;
        case dbSalesByChannel:
        {
            url = [NSString stringWithFormat:[Utility url:urlSalesByChannelGet],[Utility randomStringWithLength:6]];
            noteDataString = [Utility getNoteDataString:object];
        }
            break;
        case dbProductionOrderAdded:
        {
            url = [NSString stringWithFormat:[Utility url:urlProductionOrderAdded],[Utility randomStringWithLength:6]];
            
            NSArray *data = (NSArray *)object;
            NSString *productCategory2 = data[0];
            NSString *dateIn = data[1];
            
            noteDataString = [NSString stringWithFormat:@"productCategory2=%@&dateIn=%@",productCategory2,dateIn];
        }
            break;
        case dbProductTransfer:
        {
            url = [NSString stringWithFormat:[Utility url:urlProductTransferGet],[Utility randomStringWithLength:6]];
            
            NSArray *data = (NSArray *)object;
            NSString *productCategory2 = data[0];
            NSString *strTransferHistoryID = data[1];
            
            noteDataString = [NSString stringWithFormat:@"productCategory2=%@&transferHistoryID=%ld",productCategory2,[strTransferHistoryID integerValue]];
        }
            break;
        case dbMemberAndPoint:
        {
            url = [NSString stringWithFormat:[Utility url:urlMemberAndPointGet],[Utility randomStringWithLength:6]];
            NSString *searchText = (NSString *)object;
            noteDataString = [NSString stringWithFormat:@"searchText=%@",searchText];
        }
            break;
        case dbAccountReceiptByPeriod:
        {
            url = [NSString stringWithFormat:[Utility url:urlAccountReceiptByPeriod],[Utility randomStringWithLength:6]];
                        
            NSArray *arrData = (NSArray *)object;
            NSString *dateFrom = arrData[0];
            NSString *dateTo = arrData[1];
            
            noteDataString = [NSString stringWithFormat:@"dateFrom=%@&dateTo=%@",dateFrom,dateTo];
        }
            break;
        case dbReceiptByMember:
        {
            url = [NSString stringWithFormat:[Utility url:urlReceiptByMember],[Utility randomStringWithLength:6]];
            NSString *customerID = (NSString *)object;
            
            noteDataString = [NSString stringWithFormat:@"customerID=%@",customerID];
        }
            break;
        case dbRewardProgram:
        {
            url = [NSString stringWithFormat:[Utility url:urlRewardProgramGet],[Utility randomStringWithLength:6]];
            
            
            NSArray *arrData = (NSArray *)object;
            NSString *dateFrom = arrData[0];
            NSString *dateTo = arrData[1];
            
            noteDataString = [NSString stringWithFormat:@"dateFrom=%@&dateTo=%@",dateFrom,dateTo];
        }
            break;
        case dbAccountReceipt:
        {
            Receipt *receipt = (Receipt *)object;
            url = [NSString stringWithFormat:[Utility url:urlAccountReceiptGet],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"receiptID=%ld",receipt.receiptID];
        }
            break;
        case dbPostDetail:
        {
            NSArray *arrData = (NSArray *)object;
            NSString *preOrderEventID = arrData[0];
            NSString *page = arrData[1];
            url = [NSString stringWithFormat:[Utility url:urlPostDetailGet],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"preOrderEventID=%@&page=%@",preOrderEventID,page];
        }
            break;
        case dbPostDetailSearch:
        {
            NSArray *arrData = (NSArray *)object;
            NSString *preOrderEventID = arrData[0];
            NSString *page = arrData[1];
            NSString *searchText = arrData[2];
            url = [NSString stringWithFormat:[Utility url:urlPostDetailSearchGet],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"preOrderEventID=%@&page=%@&searchText=%@",preOrderEventID,page,searchText];
        }
            break;
        case dbPostDetailToPost:
        {
            NSArray *arrData = (NSArray *)object;
            NSString *preOrderEventID = arrData[0];
            NSString *page = arrData[1];
            url = [NSString stringWithFormat:[Utility url:urlPostDetailToPostGet],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"preOrderEventID=%@&page=%@",preOrderEventID,page];
        }
            break;
        case dbMainInventoryItem:
        {
            NSArray *arrData = (NSArray *)object;
            NSString *eventID = arrData[0];
            NSString *all = arrData[1];
            NSString *page = arrData[2];
            NSString *searchText = arrData[3];
            url = [NSString stringWithFormat:[Utility url:urlMainInventoryItemGet],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"eventID=%@&all=%@&page=%@&searchText=%@",eventID,all,page,searchText];
        }
            break;
        case dbCustomMadeIn:
        {
            NSArray *arrData = (NSArray *)object;
            NSString *page = arrData[0];
            url = [NSString stringWithFormat:[Utility url:urlCustomMadeIn],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"page=%@",page];
        }
            break;
        case dbCustomMadeOut:
        {
            NSArray *arrData = (NSArray *)object;
            NSString *page = arrData[0];
            url = [NSString stringWithFormat:[Utility url:urlCustomMadeOut],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"page=%@",page];
        }
            break;
        case dbSalesForDate:
        {
            NSArray *arrData = (NSArray *)object;
            NSString *eventID = arrData[0];
            NSDate *receiptDate = arrData[1];
            url = [NSString stringWithFormat:[Utility url:urlSalesForDateGet],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"eventID=%@&receiptDate=%@",eventID,[Utility dateToString:receiptDate toFormat:@"yyyy-MM-dd"]];
        }
        break;
        case dbProductDelete:
        {
            NSArray *arrData = (NSArray *)object;
            NSString *eventID = arrData[0];
            NSString *page = arrData[1];
            url = [NSString stringWithFormat:[Utility url:urlProductDeleteGetList],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"eventID=%@&page=%@",eventID,page];
        }
            break;
        case dbMainInventorySalePrice:
        {
            Event *event = (Event *)object;
            url = [NSString stringWithFormat:[Utility url:urlMainInventorySalePriceGet],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"eventID=%ld",event.eventID];
        }
            break;
        case dbProductSales:
        {
            NSArray *arrData = (NSArray *)object;
            NSString *productSalesSetID = arrData[0];
            url = [NSString stringWithFormat:[Utility url:urlProductSalesGetList],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"productSalesSetID=%@",productSalesSetID];
        }
            break;
        case dbPostCustomerSearch:
        {
            NSString *telephoneSearch = (NSString *)object;
            url = [NSString stringWithFormat:[Utility url:urlPostCustomerSearchGetList],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"telephoneSearch=%@",telephoneSearch];
        }
            break;
        case dbEventSalesSummary:
        {
            NSArray *dataList = (NSArray *)object;
            NSString *strEventID = dataList[0];
            NSString *strStartDate = dataList[1];
            NSString *strEndDate = dataList[2];
            url = [NSString stringWithFormat:[Utility url:urlEventSalesSummaryGetList],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"eventID=%@&startDate=%@&endDate=%@",strEventID,strStartDate,strEndDate];
        }
            break;
        case dbSearchSales:
        {
            NSArray *dataList = (NSArray *)object;
            NSString *searchText = dataList[0];
            NSString *page = dataList[1];            
            url = [NSString stringWithFormat:[Utility url:urlSearchSalesGetList],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"searchText=%@&page=%@",searchText,page];
        }
            break;
        case dbSearchSalesTelephone:
        {
            NSString *telephone = (NSString *)object;
            url = [NSString stringWithFormat:[Utility url:urlSearchSalesTelephoneGetList],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"telephone=%@",telephone];
        }
            break;
        case dbExpenseDaily:
        {
            ExpenseDaily *expenseDaily = (ExpenseDaily *)object;
            url = [NSString stringWithFormat:[Utility url:urlExpenseDailyGetList],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"inputDate=%@&eventID=%@",expenseDaily.inputDate,expenseDaily.eventID];
        }
            break;
        case dbReportTopSpender:
        {
            NSArray *dataList = (NSArray *)object;
            NSString *startDate = dataList[0];
            NSString *endDate = dataList[1];
            NSString *strOption = dataList[2];
            
            url = [NSString stringWithFormat:[Utility url:urlReportTopSpenderGetList],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"startDate=%@&endDate=%@&option=%@",startDate,endDate,strOption];
        }
            break;
        case dbReportTopSpenderDetail:
        {
            NSArray *dataList = (NSArray *)object;
            NSString *startDate = dataList[0];
            NSString *endDate = dataList[1];
            NSString *strOption = dataList[2];
            NSString *telephone = dataList[3];
            
            url = [NSString stringWithFormat:[Utility url:urlReportTopSpenderDetailGetList],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"startDate=%@&endDate=%@&option=%@&telephone=%@",startDate,endDate,strOption,telephone];
        }
            break;
        case dbReceiptSearch:
        {
            NSArray *dataList = (NSArray *)object;
            NSString *receiptNo = dataList[0];
            NSString *channel = dataList[1];
            url = [NSString stringWithFormat:[Utility url:urlReceiptSearchGet],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"receiptNo=%@&channel=%@",receiptNo,channel];
        }
            break;
        case dbSearchSalesTelephoneDetail:
        {
            url = [NSString stringWithFormat:[Utility url:urlSearchSalesTelephoneDetailGetList],[Utility randomStringWithLength:6]];
            noteDataString = [NSString stringWithFormat:@"telephone=%@",(NSString *)object];
        }
            break;
            
        default:
            break;
    }
    
    
    NSURL *nsURL = [NSURL URLWithString:url];
    noteDataString = [NSString stringWithFormat:@"%@&modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",noteDataString,[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
    NSLog(@"notedatastring: %@",noteDataString);
    NSLog(@"url: %@",url);
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:nsURL];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest];
    [dataTask resume];
}

- (void)insertItems:(enum enumDB)currentDB withData:(NSObject *)data
{
    propCurrentDB = currentDB;
    NSURL * url;
    NSString *noteDataString;
    switch (currentDB)
    {
        case dbUserAccount:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlUserAccountInsert]];
        }
            break;
        case dbEvent:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlEventInsert]];
        }
            break;
        case dbProduct:
        {
            NSMutableArray *productList = (NSMutableArray *)data;
            NSInteger countProduct = 0;

            noteDataString = [NSString stringWithFormat:@"countProduct=%ld",[productList count]];
            for(Product *item in productList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countProduct]];
                countProduct++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlProductInsert]];
        }
            break;
        case dbCashAllocationByEventIDAndInputDate:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlCashAllocationInsert]];
        }
            break;
        case dbPostCustomer:
        {
            NSMutableArray *arrData = (NSMutableArray*)data;
            PostCustomer *postCustomer = arrData[0];
            NSString *receiptID = arrData[1];
            NSString *postCustomerString = [Utility getNoteDataString:postCustomer];
            
            noteDataString = [NSString stringWithFormat:@"%@&receiptID=%@",postCustomerString,receiptID];
            
            url = [NSURL URLWithString:[Utility url:urlPostCustomerInsert]];
        }
            break;
        case dbUserAccountEventDeleteThenMultipleInsert:
        {            
            NSMutableArray *userAccountEventList = (NSMutableArray *)data;
            noteDataString = [NSString stringWithFormat:@"countEvent=%lu",(unsigned long)[userAccountEventList count]];
            noteDataString = [NSString stringWithFormat:@"%@&userAccountID=%ld",noteDataString,((UserAccountEvent *)userAccountEventList[0]).userAccountID];
            
            for(int i=0; i<[userAccountEventList count]; i++)
            {
                UserAccountEvent *userAccountEvent = userAccountEventList[i];
                
                noteDataString = [NSString stringWithFormat:@"%@&eventID%02d=%@&userAccountEventID%02d=%ld",noteDataString,i,userAccountEvent.eventID,i,userAccountEvent.userAccountEventID];
            }

            url = [NSURL URLWithString:[Utility url:urlUserAccountEventDeleteThenMultipleInsert]];
        }
            break;
        case dbReceiptAndProductBuyInsert:
        {
            //product->customMade->receiptproductitem->receipt->postcustomer->customerreceipt การเรียง execute table ใน database เพื่อป้องกันการเกิด lock table (การ lock table เกิดได้ใน 2 กรณี ของการ turn off auto commit 1.สับลำดับ execute table 2.การ update หรือ delete ที่ ไม่เรียงตาม primary key)
            NSMutableArray *arrData = (NSMutableArray *)data;
            NSMutableArray *arrProduct = arrData[0];
            NSMutableArray *arrCustomMade = arrData[1];
            NSMutableArray *arrReceiptProductItem = arrData[2];
            NSMutableArray *arrPreOrderEventIDHistory = arrData[3];
            Receipt *receipt = arrData[4];
            NSMutableArray *arrRewardPoint = arrData[5];
            NSMutableArray *arrPostCustomer = arrData[6];
            NSMutableArray *arrItemTrackingNo = arrData[7];
//            CustomerReceipt *customerReceipt = arrData[7];
            
            
            NSInteger countProduct = 0;
            NSInteger countCustomMade = 0;
            NSInteger countReceiptProductItem = 0;
            NSInteger countPreOrderEventIDHistory = 0;
            NSInteger countRewardPoint = 0;
            NSInteger countPostCustomer = 0;
            NSInteger countItemTrackingNo = 0;
            
            
            NSString *noteDataStringForReceipt = [Utility getNoteDataString:receipt];
            noteDataStringForReceipt = [noteDataStringForReceipt stringByReplacingOccurrencesOfString:@"shippingFee"
            withString:@"shippingFeeReceipt"];
            noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,noteDataStringForReceipt];
            noteDataString = [NSString stringWithFormat:@"%@&countRewardPoint=%ld&countPostCustomer=%ld&countProduct=%ld&countCustomMade=%ld&countReceiptProductItem=%ld&countPreOrderEventIDHistory=%ld&countItemTrackingNo=%ld",noteDataString,[arrRewardPoint count],[arrPostCustomer count],[arrProduct count],[arrCustomMade count],[arrReceiptProductItem count],[arrPreOrderEventIDHistory count], [arrItemTrackingNo count]];
            for(RewardPoint *item in arrRewardPoint)
            {
                noteDataString = [NSString stringWithFormat:@"%@&rewardPointID%02ld=%ld&customerIDReward%02ld=%ld&point%02ld=%ld&statusReward%02ld=%ld",noteDataString,countRewardPoint,item.rewardPointID,countRewardPoint,item.customerID,countRewardPoint,item.point,countRewardPoint,item.status];
                countRewardPoint++;
            }
            for(PostCustomer *item in arrPostCustomer)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countPostCustomer]];
                countPostCustomer++;
            }
            for(ItemTrackingNo *item in arrItemTrackingNo)
            {
                noteDataString = [NSString stringWithFormat:@"%@&receiptProductItemIDTrackingNo%02ld=%ld&postCustomerID%02ld=%ld",noteDataString,countItemTrackingNo,item.receiptProductItemID,countItemTrackingNo,item.postCustomerID];
                countItemTrackingNo++;
            }
            for(Product *item in arrProduct)
            {                
                noteDataString = [NSString stringWithFormat:@"%@&productIDMain%02ld=%@&status%02ld=%@",noteDataString,countProduct,item.productID,countProduct,item.status];
                countProduct++;
            }
            for(CustomMade *item in arrCustomMade)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@&remarkCustomMade%02ld=%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countCustomMade],countCustomMade,item.remark];
                countCustomMade++;
            }
            for(ReceiptProductItem *item in arrReceiptProductItem)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countReceiptProductItem]];
                countReceiptProductItem++;
            }
            for(PreOrderEventIDHistory *item in arrPreOrderEventIDHistory)
            {
                noteDataString = [NSString stringWithFormat:@"%@&preOrderEventIDHistoryID%02ld=%ld&receiptProductItemIDPreHis%02ld=%ld&preOrderEventIDPreHis%02ld=%ld",noteDataString,countPreOrderEventIDHistory,item.preOrderEventIDHistoryID,countPreOrderEventIDHistory,item.receiptProductItemID,countPreOrderEventIDHistory,item.preOrderEventID];
                countPreOrderEventIDHistory++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlReceiptAndProductBuyInsert]];
        }
            break;
        case dbCompareInventory:
        {
            NSArray *arrData = (NSArray*)data;
            NSString *strEventID = arrData[0];
            NSString *strCompareInventoryHistoryID = arrData[1];
            noteDataString = [NSString stringWithFormat:@"eventID=%@&compareInventoryHistoryID=%@",strEventID,strCompareInventoryHistoryID];
            url = [NSURL URLWithString:[Utility url:urlCompareInventoryInsert]];
        }
            break;
        case dbCompareInventoryNotMatchInsert:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlCompareInventoryNotMatchInsert]];
        }
            break;
        case dbProductSalesSet:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlProductSalesSetInsert]];
        }
            break;
        case dbEventCost:
        {
            NSMutableArray *eventCostList = (NSMutableArray *)data;
            EventCost *eventCost = eventCostList[0];
            NSInteger eventID = [eventCostList count]>0?[eventCost.eventID integerValue]:-1;
            noteDataString = [NSString stringWithFormat:@"countEventCost=%lu",(unsigned long)[eventCostList count]];
            noteDataString = [NSString stringWithFormat:@"%@&eventID=%ld",noteDataString,eventID];
            
            for(int i=0; i<[eventCostList count]; i++)
            {
                EventCost *eventCost = eventCostList[i];
                
                noteDataString = [NSString stringWithFormat:@"%@&eventCostID%02d=%ld&costLabelID%02d=%@&costLabel%02d=%@&cost%02d=%@",noteDataString,i,eventCost.eventCostID,i,eventCost.costLabelID,i,eventCost.costLabel,i,eventCost.cost];
            }
            url = [NSURL URLWithString:[Utility url:urlEventCostInsert]];
        }
            break;
        case dbProductCategory2:
        {
            NSMutableArray *productCategory2List = (NSMutableArray *)data;
            noteDataString = @"";
            for(int i=0; i<[productCategory2List count]; i++)
            {
                ProductCategory2 *productCategory2 = productCategory2List[i];
                noteDataString = [NSString stringWithFormat:@"%@&code%02ld=%@&name%02ld=%@",noteDataString,(long)i,productCategory2.code,(long)i,productCategory2.name];
            }
            noteDataString = [NSString stringWithFormat:@"%@&count=%ld",noteDataString,(long)[productCategory2List count]];
            NSRange needleRange = NSMakeRange(1,[noteDataString length]-1);
            noteDataString = [noteDataString substringWithRange:needleRange];
            
            url = [NSURL URLWithString:[Utility url:urlProductCategory2Insert]];
        }
            break;
        case dbProductCategory1:
        {
            NSMutableArray *productCategory1List = (NSMutableArray *)data;
            noteDataString = @"";
            for(int i=0; i<[productCategory1List count]; i++)
            {
                ProductCategory1 *productCategory1 = productCategory1List[i];
                noteDataString = [NSString stringWithFormat:@"%@&code%02ld=%@&name%02ld=%@&productCategory2%02ld=%@",noteDataString,(long)i,productCategory1.code,(long)i,productCategory1.name,(long)i,productCategory1.productCategory2];
            }
            noteDataString = [NSString stringWithFormat:@"%@&count=%ld",noteDataString,(long)[productCategory1List count]];
            NSRange needleRange = NSMakeRange(1,[noteDataString length]-1);
            noteDataString = [noteDataString substringWithRange:needleRange];
            
            url = [NSURL URLWithString:[Utility url:urlProductCategory1Insert]];
        }
            break;
        case dbColor:
        {
            NSMutableArray *colorList = (NSMutableArray *)data;
            noteDataString = @"";
            for(int i=0; i<[colorList count]; i++)
            {
                Color *color = colorList[i];
                noteDataString = [NSString stringWithFormat:@"%@&code%02ld=%@&name%02ld=%@",noteDataString,(long)i,color.code,(long)i,color.name];
            }
            noteDataString = [NSString stringWithFormat:@"%@&count=%ld",noteDataString,(long)[colorList count]];
            NSRange needleRange = NSMakeRange(1,[noteDataString length]-1);
            noteDataString = [noteDataString substringWithRange:needleRange];
            
            url = [NSURL URLWithString:[Utility url:urlColorInsert]];
        }
            break;
        case dbProductSize:
        {
            NSMutableArray *productSizeList = (NSMutableArray *)data;
            noteDataString = @"";
            for(int i=0; i<[productSizeList count]; i++)
            {
                ProductSize *productSize = productSizeList[i];
                noteDataString = [NSString stringWithFormat:@"%@&code%02ld=%@&sizeLabel%02ld=%@&sizeOrder%02ld=%@",noteDataString,(long)i,productSize.code,(long)i,productSize.sizeLabel,(long)i,productSize.sizeOrder];
            }
            noteDataString = [NSString stringWithFormat:@"%@&count=%ld",noteDataString,(long)[productSizeList count]];
            NSRange needleRange = NSMakeRange(1,[noteDataString length]-1);
            noteDataString = [noteDataString substringWithRange:needleRange];
            
            url = [NSURL URLWithString:[Utility url:urlProductSizeInsert]];
        }
            break;
        case dbProductName:
        {
            NSMutableArray *productNameList = (NSMutableArray *)data;
            noteDataString = [NSString stringWithFormat:@"count=%ld",[productNameList count]];
            for(int i=0; i<[productNameList count]; i++)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:productNameList[i] withRunningNo:i]];
            }

            url = [NSURL URLWithString:[Utility url:urlProductNameInsert]];
        }
            break;
        case dbProductSales:
        {
            NSMutableArray *productSalesList = (NSMutableArray *)data;
            noteDataString = [NSString stringWithFormat:@"countProductSales=%ld",[productSalesList count]];
            for(int i=0; i<[productSalesList count]; i++)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:productSalesList[i] withRunningNo:i]];
            }
            
            url = [NSURL URLWithString:[Utility url:urlProductSalesInsert]];
        }
            break;
        case dbImageRunningID:
        {
            noteDataString = [NSString stringWithFormat:@"runningID=%@",data];
            url = [NSURL URLWithString:[Utility url:urlImageRunningIDInsert]];
        }
            break;
        case dbLogin:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlLoginInsert]];
        }
            break;
        case dbItemRunningID:
        {
            NSString *countQR = (NSString *)data;
            noteDataString = [NSString stringWithFormat:@"countQR=%@",countQR];
            url = [NSURL URLWithString:[Utility url:urlItemRunningIDInsert]];
        }
            break;
        case dbDevice:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlDeviceInsert]];
        }
            break;
        case dbAccountInventory:
        {
            NSMutableArray *accountInventoryList = (NSMutableArray *)data;
            NSInteger countAccountInventory = 0;
            
            noteDataString = [NSString stringWithFormat:@"countAccountInventory=%ld",[accountInventoryList count]];
            for(AccountInventory *item in accountInventoryList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countAccountInventory]];
                countAccountInventory++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlAccountInventoryInsert]];
        }
            break;
        case dbAccountReceiptInsert:
        {
//            @[accountInventoryList,accountReceiptList,accountReceiptProductItemList,accountMappingList]
            NSArray *arrData = (NSArray*)data;
            NSMutableArray *accountInventoryList = arrData[0];
            NSMutableArray *accountReceiptList = arrData[1];
            NSMutableArray *accountReceiptProductItemList = arrData[2];
            NSMutableArray *accountMappingList = arrData[3];
            NSInteger countAccountInventory = 0;
            NSInteger countAccountReceipt = 0;
            NSInteger countAccountReceiptProductItem = 0;
            NSInteger countAccountMapping = 0;
            
            
            noteDataString = [NSString stringWithFormat:@"countAccountInventory=%ld",[accountInventoryList count]];
            for(AccountInventory *item in accountInventoryList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&accountInventoryID%03ld=%ld&productNameID%03ld=%ld&quantity%03ld=%f&status%03ld=%ld&inOutDate%03ld=%@",noteDataString,countAccountInventory,item.accountInventoryID,countAccountInventory,item.productNameID,countAccountInventory,item.quantity,countAccountInventory,item.status,countAccountInventory,item.inOutDate];
                countAccountInventory++;
            }
            
            
            noteDataString = [NSString stringWithFormat:@"%@&countAccountReceipt=%ld",noteDataString,[accountReceiptList count]];
            for(AccountReceipt *item in accountReceiptList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo3Digit:countAccountReceipt]];
                countAccountReceipt++;
            }
            
            
            noteDataString = [NSString stringWithFormat:@"%@&countAccountReceiptProductItem=%ld",noteDataString,[accountReceiptProductItemList count]];
            for(AccountReceiptProductItem *item in accountReceiptProductItemList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&accRecProItmID%03ld=%ld&accRecID%03ld=%ld&proNmeID%03ld=%ld&qty%03ld=%f&amtPerUnt%03ld=%f",noteDataString,countAccountReceiptProductItem,item.accountReceiptProductItemID,countAccountReceiptProductItem,item.accountReceiptID,countAccountReceiptProductItem,item.productNameID,countAccountReceiptProductItem,item.quantity,countAccountReceiptProductItem,item.amountPerUnit];
                countAccountReceiptProductItem++;
            }
            
            
            noteDataString = [NSString stringWithFormat:@"%@&countAccountMapping=%ld",noteDataString,[accountMappingList count]];
            for(AccountMapping *item in accountMappingList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&recID%03ld=%ld&recProItm%03ld=%ld",noteDataString,countAccountMapping,item.receiptID,countAccountMapping,item.receiptProductItemID];
                countAccountMapping++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlAccountReceiptInsert]];
        }
            break;
        case dbProductionOrder:
        {
            NSArray *dataList = (NSArray *)data;
            NSMutableArray *productionOrderList = dataList[0];
            Event *event = dataList[1];
            NSInteger countProductionOrder = 0;
            
            noteDataString = [NSString stringWithFormat:@"eventID=%ld&countProductionOrder=%ld",event.eventID,[productionOrderList count]];
            for(ProductionOrder *item in productionOrderList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countProductionOrder]];
                countProductionOrder++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlProductionOrderInsert]];
        }
            break;
        case dbProductAndProductionOrder:
        {
            NSArray *arrData = (NSArray *)data;
            NSMutableArray *productList = (NSMutableArray *)arrData[0];
            NSString *strRunningPoNo = (NSString *)arrData[1];
            NSInteger countProduct = 0;
            
            noteDataString = [NSString stringWithFormat:@"runningPoNo=%@&countProduct=%ld",strRunningPoNo,[productList count]];
            for(Product *item in productList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countProduct]];
                countProduct++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlProductAndProductionOrderInsert]];
        }
            break;
        case dbRewardProgram:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlRewardProgramInsert]];
        }
            break;
        case dbWriteLog:
        {
            NSString *stackTrace = (NSString *)data;
            noteDataString = [NSString stringWithFormat:@"stackTrace=%@",stackTrace];
            url = [NSURL URLWithString:[Utility url:urlWriteLog]];
        }
            break;
        case dbExpenseDaily:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlExpenseDailyInsert]];
        }
            break;
        case dbPostCustomerAdd:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlPostCustomerAddInsert]];
        }
            break;
        case dbItemTrackingNoPostCustomerAdd:
        {
            NSArray *dataList = (NSArray *)data;
            PostCustomer *postCustomer = dataList[0];
            NSArray *receiptProductItemList = dataList[1];
           
            NSInteger countData = 0;
            noteDataString = [Utility getNoteDataString:postCustomer];
            noteDataString = [NSString stringWithFormat:@"%@&countReceiptProductItem=%ld",noteDataString,(long)[receiptProductItemList count]];
            
            for(ReceiptProductItem *item in receiptProductItemList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&receiptProductItemID%02ld=%ld",noteDataString,(long)countData,item.receiptProductItemID];
                countData++;
            }
            url = [NSURL URLWithString:[Utility url:urlItemTrackingNoPostCustomerAddInsert]];
        }
            break;
        default:
            break;
    }
    
    noteDataString = [NSString stringWithFormat:@"%@&modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",noteDataString,[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
    NSLog(@"notedatastring: %@",noteDataString);
    NSLog(@"url: %@",url);
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *dataRaw, NSURLResponse *header, NSError *error) {
   
        if(!error || (error && error.code == -1005))//-1005 คือ1. ตอน push notification ไม่ได้ และ2. ตอน enterbackground ตอน transaction ยังไม่เสร็จ พอ enter foreground มันจะไม่ return data มาให้
        {
            switch (propCurrentDB)
            {
                case dbItemRunningID:
                {
                    if(!dataRaw)
                    {
                        //data parameter is nil
                        NSLog(@"Error: %@", [error debugDescription]);
                        [self.delegate removeOverlayViewConnectionFail];
                        return ;
                    }
                    
                    NSDictionary *json = [NSJSONSerialization
                                          JSONObjectWithData:dataRaw
                                          options:kNilOptions error:&error];
                    NSString *status = json[@"status"];
                    if([status isEqual:@"1"])
                    {
                        NSInteger ID = [json[@"ID"] integerValue];
                        if (self.delegate)
                        {
                            [self.delegate itemsInsertedWithReturnID:ID];
                        }
                    }
                    else
                    {
                        //Error
                        NSLog(@"insert fail");
                        NSLog(@"%@", status);
                        if (self.delegate)
                        {
//                            [self.delegate itemsFail];
                        }
                    }
                }
                    break;
                case dbProductSalesSet:
                {
                    if(!dataRaw)
                    {
                        //data parameter is nil
                        NSLog(@"Error: %@", [error debugDescription]);
                        [self.delegate removeOverlayViewConnectionFail];
                        return ;
                    }
                    
                    NSDictionary *json = [NSJSONSerialization
                                          JSONObjectWithData:dataRaw
                                          options:kNilOptions error:&error];
                    NSString *status = json[@"status"];
                    if([status isEqual:@"1"])
                    {
                        NSArray *data = json[@"data"];
                        NSMutableArray *productSalesInserted = [[NSMutableArray alloc]init];
                        
                        for(NSDictionary *jsonElement in data)
                        {
                            NSObject *object = [[ProductSales alloc]init];
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
                            [productSalesInserted addObject:object];
                        }
                        
                        if(self.delegate)
                        {
                            [self.delegate itemsInsertedWithReturnData:productSalesInserted];
                        }
                    }
                    else
                    {
                        //Error
                        NSLog(@"insert fail");
                        NSLog(@"%@", status);
                        if (self.delegate)
                        {
//                            [self.delegate itemsFail];
                        }
                    }
                }
                    break;
                default:
                {
                    if(!dataRaw)
                    {
                        //data parameter is nil
                        NSLog(@"Error: %@", [error debugDescription]);
                        return ;
                    }
                    
                    NSDictionary *json = [NSJSONSerialization
                                          JSONObjectWithData:dataRaw
                                          options:kNilOptions error:&error];
                    NSString *status = json[@"status"];
                    NSString *returnID = json[@"returnID"];
                    NSArray *dataJson = json[@"dataJson"];
                    NSString *strTableName = json[@"tableName"];
                    if(propCurrentDB == dbProductSales)
                    {
                        if([status isEqual:@"1"] && [strTableName isEqualToString:@"ProductSales"])
                        {
                            NSArray *arrClassName = @[@"ProductSales"];
                            NSArray *items = [Utility jsonToArray:dataJson arrClassName:arrClassName];
                            
                            
                            if(self.delegate)
                            {
                                [self.delegate itemsInsertedWithReturnData:items];
                            }
                        }
                    }
                    else if(propCurrentDB == dbPostCustomer || propCurrentDB == dbPostCustomerAdd)
                    {
                        if([status isEqual:@"1"] && [strTableName isEqualToString:@"PostCustomer"])
                        {
                            NSArray *arrClassName = @[@"PostCustomer"];
                            NSArray *items = [Utility jsonToArray:dataJson arrClassName:arrClassName];
                            
                            
                            if(self.delegate)
                            {
                                [self.delegate itemsInsertedWithReturnData:items];
                            }
                        }
                    }
                    else if(propCurrentDB == dbExpenseDaily)
                    {
                        if([status isEqual:@"1"] && [strTableName isEqualToString:@"ExpenseDaily"])
                        {
                            NSArray *arrClassName = @[@"ExpenseDaily"];
                            NSArray *items = [Utility jsonToArray:dataJson arrClassName:arrClassName];
                            
                            
                            if(self.delegate)
                            {
                                [self.delegate itemsInsertedWithReturnData:items];
                            }
                        }
                    }
                    else if(propCurrentDB == dbItemTrackingNoPostCustomerAdd)
                    {
                        if([status isEqual:@"1"] && [strTableName isEqualToString:@"ItemTrackingNoPostCustomerAdd"])
                        {
                            NSArray *arrClassName = @[@"PostCustomer"];
                            NSArray *items = [Utility jsonToArray:dataJson arrClassName:arrClassName];
                            
                            
                            if(self.delegate)
                            {
                                [self.delegate itemsInsertedWithReturnData:items];
                            }
                        }
                    }
                    else if(propCurrentDB == dbAccountReceiptInsert || propCurrentDB == dbReceiptAndProductBuyInsert)
                    {
                        if (self.delegate)
                        {
                            [self.delegate itemsInserted];
                        }
                    }
                    else if([status isEqual:@"1"])
                    {
                        NSLog(@"insert success");
                        if(returnID)
                        {
                            if (self.delegate)
                            {
                                [self.delegate itemsInsertedWithReturnID:returnID];
                            }
                        }
                        else if(strTableName)
                        {
                            NSArray *arrClassName;
                            if([strTableName isEqualToString:@"Event"])
                            {
                                arrClassName = @[@"Event"];
                            }
                            else if([strTableName isEqualToString:@"ProductName"])
                            {
                                arrClassName = @[@"ProductName"];
                            }
                            
                            
                            NSArray *items = [Utility jsonToArray:dataJson arrClassName:arrClassName];
                            if(self.delegate)
                            {
                                [self.delegate itemsInsertedWithReturnData:items];
                            }
                        }
                    }
                    else
                    {
                        //Error
                        NSLog(@"insert fail");
                        NSLog(@"%@", status);
                        if (self.delegate)
                        {
//                            [self.delegate itemsFail];
                        }
                    }
                }
                    break;
            }
        }
        else
        {
            if (self.delegate)
            {
                [self.delegate itemsFail];
//                [self.delegate connectionFail];
            }
            
            NSLog(@"Error: %@", [error debugDescription]);
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

- (void)insertItemsJson:(enum enumDB)currentDB withData:(NSObject *)data
{
    NSURL * url;
    NSData *jsonData;
    switch (currentDB)
    {
        case dbAccountReceiptInsert:
        {
            NSArray *arrData = (NSArray*)data;
            NSMutableArray *accountInventoryList = arrData[0];
            NSMutableArray *accountReceiptList = arrData[1];
            NSMutableArray *accountReceiptProductItemList = arrData[2];
            NSMutableArray *accountMappingList = arrData[3];
            

            NSMutableDictionary *mutDicData = [[NSMutableDictionary alloc]init];
            NSMutableArray *arrAccountInventory= [[NSMutableArray alloc]init];
            for(int i=0; i<[accountInventoryList count]; i++)
            {
                AccountInventory *accountInventory = accountInventoryList[i];
                NSDictionary *dicAccountInventory = [accountInventory dictionary];
                [arrAccountInventory addObject:dicAccountInventory];
            }
            NSMutableArray *arrAccountReceipt = [[NSMutableArray alloc]init];
            for(int i=0; i<[accountReceiptList count]; i++)
            {
                AccountReceipt *accountReceipt = accountReceiptList[i];
                NSDictionary *dicAccountReceipt = [accountReceipt dictionary];
                [arrAccountReceipt addObject:dicAccountReceipt];
            }
            NSMutableArray *arrAccountReceiptProductItem = [[NSMutableArray alloc]init];
            for(int i=0; i<[accountReceiptProductItemList count]; i++)
            {
                AccountReceiptProductItem *accountReceiptProductItem = accountReceiptProductItemList[i];
                NSDictionary *dicAccountReceiptProductItem = [accountReceiptProductItem dictionary];
                [arrAccountReceiptProductItem addObject:dicAccountReceiptProductItem];
            }
            NSMutableArray *arrAccountMapping = [[NSMutableArray alloc]init];
            for(int i=0; i<[accountMappingList count]; i++)
            {
                AccountMapping *accountMapping = accountMappingList[i];
                NSDictionary *dicAccountMapping = [accountMapping dictionary];
                [arrAccountMapping addObject:dicAccountMapping];
            }
            

//            NSMutableArray *mutDicData = [dicData mutableCopy];
            [mutDicData setValue:arrAccountInventory forKey:@"accountInventory"];
            [mutDicData setValue:arrAccountReceipt forKey:@"accountReceipt"];
            [mutDicData setValue:arrAccountReceiptProductItem forKey:@"accountReceiptProductItem"];
            [mutDicData setValue:arrAccountMapping forKey:@"accountMapping"];
            
            
            
            NSError *error;
            jsonData = [NSJSONSerialization dataWithJSONObject:mutDicData options:0 error:&error];
            
//            url = [NSURL URLWithString:[Utility url:urlOmiseCheckOut]];
            url = [NSURL URLWithString:[Utility url:urlAccountReceiptInsert]];
        }
            break;
            
        default:
            break;
    }

    NSLog(@"url: %@",url);
    
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:jsonData];
    
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *dataRaw, NSURLResponse *header, NSError *error) {
        
        if(!error || (error && error.code == -1005))//-1005 คือ1. ตอน push notification ไม่ได้ และ2. ตอน enterbackground ตอน transaction ยังไม่เสร็จ พอ enter foreground มันจะไม่ return data มาให้
        {
            switch (propCurrentDB)
            {
                default:
                {
                    if(!dataRaw)
                    {
                        //data parameter is nil
                        NSLog(@"Error: %@", [error debugDescription]);
                        return ;
                    }
                    
                    NSDictionary *json = [NSJSONSerialization
                                          JSONObjectWithData:dataRaw
                                          options:kNilOptions error:&error];
                    NSString *status = json[@"status"];
                    if([status isEqual:@"1"])
                    {
                        NSLog(@"insert success");
                        if(self.delegate)
                        {
                            [self.delegate itemsInserted];
                        }
                    }
                    else if([status isEqual:@"2"])
                    {
                        //alertMsg
                        if(self.delegate)
                        {
                            NSString *msg = json[@"msg"];
//                                [self.delegate alertMsg:msg];
                            NSLog(@"status: %@", status);
                            NSLog(@"msg: %@", msg);
                        }
                    }
                    else
                    {
                        //Error
                        NSLog(@"insert fail: %ld",currentDB);
                        NSLog(@"%@", status);
                        if (self.delegate)
                        {
                            [self.delegate itemsFail];
                        }
                    }
                }
                    break;
            }
        }
        else
        {
            if (self.delegate)
            {
                [self.delegate itemsFail];
                //                [self.delegate connectionFail];
            }
            
            NSLog(@"Error: %@", [error debugDescription]);
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

- (void)updateItems:(enum enumDB)currentDB withData:(NSObject *)data
{
    propCurrentDB = currentDB;
    NSURL * url;
    NSString *noteDataString;
    switch (currentDB)
    {
        case dbUserAccount:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlUserAccountUpdate]];
        }
            break;
        case dbEvent:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlEventUpdate]];
        }
            break;
        case dbProduct:
        {
            NSMutableArray *productList = (NSMutableArray *)data;
            NSInteger countProduct = 0;
            
            noteDataString = [NSString stringWithFormat:@"countProduct=%ld",[productList count]];
            for(Product *item in productList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countProduct]];
                countProduct++;
            }
                        
            url = [NSURL URLWithString:[Utility url:urlProductUpdate]];
        }
            break;
        case dbCashAllocationByEventIDAndInputDate:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlCashAllocationUpdate]];
        }
            break;
        case dbPostCustomer:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlPostCustomerUpdate]];
        }
            break;
        case dbProductEventID:
        {
            NSArray *eventSourceAndDestination = (NSArray*)data;
            noteDataString = [NSString stringWithFormat:@"eventSource=%@&eventDestination=%@",eventSourceAndDestination[0],eventSourceAndDestination[1]];
            url = [NSURL URLWithString:[Utility url:urlProductEventIDUpdate]];
        }
            break;
        case dbProductStatusByProductID:
        {
            Product *product = (Product*)data;
            noteDataString = [NSString stringWithFormat:@"productID=%@&status=%@&eventID=%ld",product.productID,product.status,product.eventID];
            url = [NSURL URLWithString:[Utility url:urlProductStatusUpdateByProductID]];
        }
            break;
        case dbProductEventIDByProductID:
        {
            Product *product = (Product*)data;
            noteDataString = [NSString stringWithFormat:@"productID=%@&eventID=%ld",product.productID,product.eventID];
            url = [NSURL URLWithString:[Utility url:urlProductEventIDUpdateByProductID]];
        }
            break;
        case dbReceiptProductItemAndProductUpdate:
        {
            NSArray *arrData = (NSArray *)data;
            NSArray *arrProduct = arrData[0];
            NSArray *arrCustomMade = arrData[1];
            NSArray *arrReceiptProductItem = arrData[2];
            
            NSInteger countProduct = 0;
            NSInteger countCustomMade = 0;
            NSInteger countReceiptProductItem = 0;
            noteDataString = [NSString stringWithFormat:@"countProduct=%ld&countCustomMade=%ld&countReceiptProductItem=%ld",[arrProduct count],[arrCustomMade count],[arrReceiptProductItem count]];
            
            for(Product *item in arrProduct)
            {
                noteDataString = [NSString stringWithFormat:@"%@&productIDMain%02ld=%@",noteDataString,countProduct,item.productID];
                countProduct++;
            }
            for(CustomMade *item in arrCustomMade)
            {
                noteDataString = [NSString stringWithFormat:@"%@&customMadeID%02ld=%ld",noteDataString,countCustomMade,item.customMadeID];
                countCustomMade++;
            }
            for(ReceiptProductItem *item in arrReceiptProductItem)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countReceiptProductItem]];
                countReceiptProductItem++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlReceiptProductItemAndProductUpdate]];
        }
            break;
        case dbCompareInventory:
        {
            NSInteger countCompareInventory = 0;
            NSMutableArray *compareInventoryList = (NSMutableArray *)data;
            CompareInventory *compareInventory = compareInventoryList[0];
            noteDataString = [NSString stringWithFormat:@"countCompareInventory=%ld&runningSetNo=%@",[compareInventoryList count],compareInventory.runningSetNo];
            for(CompareInventory *item in compareInventoryList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countCompareInventory]];
                countCompareInventory++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlCompareInventoryUpdate]];
        }
            break;
        case dbProductSalesSet:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlProductSalesSetUpdate]];
        }
            break;
        case dbProductSales:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlProductSalesUpdate]];
        }
            break;
        case dbProductSalesMultipleUpdate:
        {
            NSMutableArray *arrData = (NSMutableArray *)data;
            ProductSales *productSales = arrData[0];
            noteDataString = [NSString stringWithFormat:@"pricePromotion=%@",productSales.pricePromotion];
            for(int i=0; i<[arrData count]; i++)
            {
                ProductSales *productSales = arrData[i];
                noteDataString = [NSString stringWithFormat:@"%@&productSalesID%03ld=%ld",noteDataString,(long)i,productSales.productSalesID];
            }
            noteDataString = [NSString stringWithFormat:@"%@&countProductSalesID=%ld",noteDataString,(long)[arrData count]];
            url = [NSURL URLWithString:[Utility url:urlProductSalesMultipleUpdate]];
        }
            break;
        case dbReceiptProductItemPreOrder:
        {
            NSArray *arrData = (NSArray *)data;
            NSArray *arrProduct = arrData[0];
            NSArray *arrReceiptProductItem = arrData[1];
            NSInteger countProduct = 0;
            NSInteger countReceiptProductItem = 0;
            noteDataString = [NSString stringWithFormat:@"countProduct=%ld&countReceiptProductItem=%ld",[arrProduct count],[arrReceiptProductItem count]];
            for(Product *item in arrProduct)
            {
                noteDataString = [NSString stringWithFormat:@"%@&productIDMain%02ld=%@&status%02ld=%@&remark%02ld=%@",noteDataString,countProduct,item.productID,countProduct,item.status,countProduct,item.remark];
                countProduct++;
            }
            for(ReceiptProductItem *item in arrReceiptProductItem)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countReceiptProductItem]];
                countReceiptProductItem++;                
            }
            url = [NSURL URLWithString:[Utility url:urlReceiptProductItemPreOrder]];
        }
            break;
        case dbReceiptProductItemPreOrderCM:
        {
            NSArray *arrData = (NSArray *)data;
            NSArray *arrProduct = arrData[0];
            NSArray *arrCustomMade = arrData[1];
            NSArray *arrReceiptProductItem = arrData[2];
            NSInteger countProduct = 0;
            noteDataString = [NSString stringWithFormat:@"countProduct=%ld",[arrProduct count]];
            for(Product *item in arrProduct)
            {
                ReceiptProductItem *receiptProductItem = arrReceiptProductItem[countProduct];
                CustomMade *customMade = arrCustomMade[countProduct];
                noteDataString = [NSString stringWithFormat:@"%@&productID%02ld=%@&remark%02ld=%@&customMadeID%02ld=%ld&productIDPostCM%02ld=%@&receiptProductItemID%02ld=%ld&productIDPost%02ld=%@",noteDataString,countProduct,item.productID,countProduct,item.remark,countProduct,customMade.customMadeID,countProduct,customMade.productIDPost,countProduct,receiptProductItem.receiptProductItemID,countProduct,receiptProductItem.productID];
                countProduct++;
            }            
            url = [NSURL URLWithString:[Utility url:urlReceiptProductItemPreOrderCM]];
        }
            break;
        case dbCustomerReceiptUpdatePostCustomerID:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlCustomerReceiptUpdatePostCustomerID]];
        }
            break;
        case dbCustomerReceiptUpdateTrackingNo:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlCustomerReceiptUpdateTrackingNo]];
        }
            break;
        case dbReceiptProductItemUnpost:
        {
            NSArray *arrData = (NSArray *)data;
            NSArray *arrProduct = arrData[0];
            NSArray *arrReceiptProductItem = arrData[1];
            NSArray *arrCustomerReceipt = arrData[2];
            NSInteger countProduct = 0;
            noteDataString = [NSString stringWithFormat:@"countProduct=%ld",[arrProduct count]];
            for(Product *item in arrProduct)
            {
                ReceiptProductItem *receiptProductItem = arrReceiptProductItem[countProduct];
                CustomerReceipt *customerReceipt = arrCustomerReceipt[countProduct];
                noteDataString = [NSString stringWithFormat:@"%@&productID%02ld=%@&remark%02ld=%@&receiptProductItemID%02ld=%ld&customerReceiptID%02ld=%ld",noteDataString,countProduct,item.productID,countProduct,item.remark,countProduct,receiptProductItem.receiptProductItemID,countProduct,customerReceipt.customerReceiptID];
                countProduct++;
            }            
            url = [NSURL URLWithString:[Utility url:urlReceiptProductItemUnpost]];
        }
            break;
        case dbReceiptProductItemUnpostCM:
        {
            NSArray *arrData = (NSArray *)data;
            NSArray *arrProduct = arrData[0];
            NSArray *arrCustomMade = arrData[1];
            NSArray *arrReceiptProductItem = arrData[2];
            NSArray *arrCustomerReceipt = arrData[3];
            NSInteger countProduct = 0;
            noteDataString = [NSString stringWithFormat:@"countProduct=%ld",[arrProduct count]];
            for(Product *item in arrProduct)
            {
                ReceiptProductItem *receiptProductItem = arrReceiptProductItem[countProduct];
                CustomMade *customMade = arrCustomMade[countProduct];
                CustomerReceipt *customerReceipt = arrCustomerReceipt[countProduct];
                noteDataString = [NSString stringWithFormat:@"%@&productID%02ld=%@&customMadeID%02ld=%ld&receiptProductItemID%02ld=%ld&customMadeIDEdit%02ld=%@&customerReceiptID%02ld=%ld",noteDataString,countProduct,item.productID,countProduct,customMade.customMadeID,countProduct,receiptProductItem.receiptProductItemID,countProduct,receiptProductItem.productID,countProduct,customerReceipt.customerReceiptID];
                countProduct++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlReceiptProductItemUnpostCM]];
        }
            break;
        case dbProductCost:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlProductCostUpdate]];
        }
            break;
        case dbProductSalesUpdateCostMultiple:
        {
            NSMutableArray *arrData = (NSMutableArray *)data;
//            NSString *cost = arrData[[arrData count]-1];
//            [arrData removeObject:cost];
            ProductSales *productSales = arrData[0];
            noteDataString = [NSString stringWithFormat:@"cost=%@",productSales.cost];
            
            
            for(int i=0; i<[arrData count]; i++)
            {
                ProductSales *productSales = arrData[i];
                noteDataString = [NSString stringWithFormat:@"%@&productSalesID%03ld=%ld",noteDataString,(long)i,productSales.productSalesID];
            }
            noteDataString = [NSString stringWithFormat:@"%@&countProductSalesID=%ld",noteDataString,(long)[arrData count]];
            url = [NSURL URLWithString:[Utility url:urlProductSalesUpdateCostMultiple]];
        }
            break;
        case dbProductCategory2:
        {
            NSMutableArray *productCategory2List = (NSMutableArray *)data;
            noteDataString = @"";
            for(int i=0; i<[productCategory2List count]; i++)
            {
                ProductCategory2 *productCategory2 = productCategory2List[i];
                noteDataString = [NSString stringWithFormat:@"%@&code%02ld=%@&name%02ld=%@",noteDataString,(long)i,productCategory2.code,(long)i,productCategory2.name];
            }
            noteDataString = [NSString stringWithFormat:@"%@&count=%ld",noteDataString,(long)[productCategory2List count]];
            NSRange needleRange = NSMakeRange(1,[noteDataString length]-1);
            noteDataString = [noteDataString substringWithRange:needleRange];
            
            url = [NSURL URLWithString:[Utility url:urlProductCategory2Update]];
        }
            break;
        case dbProductCategory1:
        {
            NSMutableArray *productCategory1List = (NSMutableArray *)data;
            noteDataString = @"";
            for(int i=0; i<[productCategory1List count]; i++)
            {
                ProductCategory1 *productCategory1 = productCategory1List[i];
                noteDataString = [NSString stringWithFormat:@"%@&code%02ld=%@&name%02ld=%@&productCategory2%02ld=%@",noteDataString,(long)i,productCategory1.code,(long)i,productCategory1.name,(long)i,productCategory1.productCategory2];
            }
            noteDataString = [NSString stringWithFormat:@"%@&count=%ld",noteDataString,(long)[productCategory1List count]];
            NSRange needleRange = NSMakeRange(1,[noteDataString length]-1);
            noteDataString = [noteDataString substringWithRange:needleRange];
            
            url = [NSURL URLWithString:[Utility url:urlProductCategory1Update]];
        }
            break;
        case dbColor:
        {
            NSMutableArray *colorList = (NSMutableArray *)data;
            noteDataString = @"";
            for(int i=0; i<[colorList count]; i++)
            {
                Color *color = colorList[i];
                noteDataString = [NSString stringWithFormat:@"%@&code%02ld=%@&name%02ld=%@",noteDataString,(long)i,color.code,(long)i,color.name];
            }
            noteDataString = [NSString stringWithFormat:@"%@&count=%ld",noteDataString,(long)[colorList count]];
            NSRange needleRange = NSMakeRange(1,[noteDataString length]-1);
            noteDataString = [noteDataString substringWithRange:needleRange];
            
            url = [NSURL URLWithString:[Utility url:urlColorUpdate]];
        }
        break;
        case dbProductSize:
        {
            NSMutableArray *productSizeList = (NSMutableArray *)data;
            noteDataString = @"";
            for(int i=0; i<[productSizeList count]; i++)
            {
                ProductSize *productSize = productSizeList[i];
                noteDataString = [NSString stringWithFormat:@"%@&code%02ld=%@&sizeLabel%02ld=%@&sizeOrder%02ld=%@",noteDataString,(long)i,productSize.code,(long)i,productSize.sizeLabel,(long)i,productSize.sizeOrder];
            }
            noteDataString = [NSString stringWithFormat:@"%@&count=%ld",noteDataString,(long)[productSizeList count]];
            NSRange needleRange = NSMakeRange(1,[noteDataString length]-1);
            noteDataString = [noteDataString substringWithRange:needleRange];
            
            url = [NSURL URLWithString:[Utility url:urlProductSizeUpdate]];
        }
            break;
        case dbProductDeleteFromEvent:
        {
            NSString *strEventID = (NSString *)data;
            noteDataString = [NSString stringWithFormat:@"eventID=%@",strEventID];
            url = [NSURL URLWithString:[Utility url:urlProductDeleteFromEvent]];
        }
            break;
        case dbProductName:
        {
            NSMutableArray *productNameList = (NSMutableArray *)data;
            for(int i=0; i<[productNameList count]; i++)
            {
                ProductName *productName = productNameList[i];
                noteDataString = [NSString stringWithFormat:@"%@&productCategory2%02ld=%@&productCategory1%02ld=%@&code%02ld=%@&name%02ld=%@&detail%02ld=%@&active%02ld=%ld",noteDataString,(long)i,productName.productCategory2,(long)i,productName.productCategory1,(long)i,productName.code,(long)i,productName.name,(long)i,productName.detail,(long)i,productName.active];
            }
            noteDataString = [NSString stringWithFormat:@"%@&count=%ld",noteDataString,(long)[productNameList count]];
            NSRange needleRange = NSMakeRange(1,[noteDataString length]-1);
            noteDataString = [noteDataString substringWithRange:needleRange];
            
            url = [NSURL URLWithString:[Utility url:urlProductNameUpdate]];
        }
            break;
        case dbProductSalesUpdateDetail:
        {
            NSInteger countProductSales = 0;
            NSMutableArray *productSalesList = (NSMutableArray *)data;
            ProductSales *productSales = productSalesList[0];
            noteDataString = [NSString stringWithFormat:@"countProductSales=%ld&price=%@&pricePromotion=%@&detail=%@&imageDefault=%@",[productSalesList count],productSales.price,productSales.pricePromotion,productSales.detail,productSales.imageDefault];
            for(ProductSales *item in productSalesList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&productSalesID%02ld=%ld",noteDataString,countProductSales,item.productSalesID];
                countProductSales++;
            }
            url = [NSURL URLWithString:[Utility url:urlProductSalesUpdateDetail]];
        }
            break;
        case dbProductSalesUpdateCost:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlProductSalesUpdateCost]];
        }
            break;
        case dbUserAccountDeviceToken:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlUserAccountDeviceTokenUpdate]];
        }
            break;
        case dbSettingDeviceToken:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlSettingDeviceTokenUpdate]];
        }
            break;
        case dbSetting:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlSettingUpdate]];
        }
            break;
//        case dbPushSync:
//        {
//            noteDataString = [Utility getNoteDataString:data];
//            url = [NSURL URLWithString:[Utility url:urlPushSyncUpdate]];
//        }
//            break;
        case dbPushSyncUpdateByDeviceToken:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlPushSyncUpdateByDeviceToken]];
            return;
        }
            break;
        case dbReceipt:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlReceiptUpdate]];
        }
            break;
        case dbCustomMade:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlCustomMadeUpdate]];
        }
            break;
        case dbReceiptProductItemUpdateCMIn:
        {
            NSInteger countPostDetail = 0;
//            NSMutableArray *receiptProductItemList = (NSMutableArray *)data;
            NSArray *dataList = (NSArray *)data;
            NSMutableArray *postDetailList = dataList[0];
            NSString *customMadeIn = dataList[1];
//            ReceiptProductItem *receiptProductItem = receiptProductItemList[0];
            noteDataString = [NSString stringWithFormat:@"countReceiptProductItem=%ld&customMadeIn=%@",[postDetailList count],customMadeIn];
            for(PostDetail *item in postDetailList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&receiptProductItemID%02ld=%ld",noteDataString,countPostDetail,item.receiptProductItemID];
                countPostDetail++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlReceiptProductItemUpdateCMIn]];
        }
            break;
        case dbUserAccountUpdateCountNotSeen:
        {            
            url = [NSURL URLWithString:[Utility url:urlUserAccountUpdateCountNotSeen]];
        }
            break;
        case dbCredentials:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlCredentialsValidate]];
        }
            break;
        case dbPushSyncUpdateTimeSynced:
        {
            NSMutableArray *pushSyncList = (NSMutableArray *)data;
            NSInteger countPushSync = 0;
            for(PushSync *item in pushSyncList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&pushSyncID%02ld=%ld",noteDataString,(long)countPushSync,(long)item.pushSyncID];
                countPushSync++;
            }
            noteDataString = [NSString stringWithFormat:@"%@&countPushSync=%ld",noteDataString,(long)countPushSync];
            url = [NSURL URLWithString:[Utility url:urlPushSyncUpdateTimeSynced]];
        }
            break;
        case dbRewardProgram:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlRewardProgramUpdate]];
        }
            break;
        case dbReceiptProductItemPreOrderEventID:
        {
            NSArray *arrData = (NSArray *)data;
            NSArray *arrProduct = arrData[0];
            NSArray *arrReceiptProductItem = arrData[1];
            NSArray *arrPreOrderEventIDHistory = arrData[2];
            NSInteger countProduct = 0;
            NSInteger countReceiptProductItem = 0;
            NSInteger countPreOrderEventIDHistory = 0;
            noteDataString = [NSString stringWithFormat:@"countProduct=%ld&countReceiptProductItem=%ld&countPreOrderEventIDHistory=%ld",[arrProduct count],[arrReceiptProductItem count],[arrPreOrderEventIDHistory count]];
            for(Product *item in arrProduct)
            {
                noteDataString = [NSString stringWithFormat:@"%@&productMainID%02ld=%@&status%02ld=%@",noteDataString,countProduct,item.productID,countProduct,item.status];
                countProduct++;
            }
            for(ReceiptProductItem *item in arrReceiptProductItem)
            {
                noteDataString = [NSString stringWithFormat:@"%@&receiptProductItemID%02ld=%ld&preOrderEventID%02ld=%ld&productID%02ld=%@",noteDataString,(long)countReceiptProductItem,(long)item.receiptProductItemID,(long)countReceiptProductItem,(long)item.preOrderEventID,(long)countReceiptProductItem,item.productID];
                countReceiptProductItem++;
            }
            for(PreOrderEventIDHistory *item in arrPreOrderEventIDHistory)
            {
                noteDataString = [NSString stringWithFormat:@"%@&preOrderEventIDHistoryID%02ld=%ld&receiptProductItemIDPreHis%02ld=%ld&preOrderEventIDPreHis%02ld=%ld",noteDataString,countPreOrderEventIDHistory,item.preOrderEventIDHistoryID,countPreOrderEventIDHistory,item.receiptProductItemID,countPreOrderEventIDHistory,item.preOrderEventID];
                countPreOrderEventIDHistory++;
            }
            url = [NSURL URLWithString:[Utility url:urlReceiptProductItemPreOrderEventID]];
        }
            break;
        case dbEmailQRCode:
        {
            NSArray *dataList = (NSArray *)data;
            NSString *downloadLink = dataList[0];
            NSArray *emailQRCodeList = dataList[1];
            NSInteger countData = 0;
            noteDataString = [NSString stringWithFormat:@"downloadLink=%@&countData=%ld",downloadLink,[emailQRCodeList count]];
            for(EmailQRCode *item in emailQRCodeList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&codeWithoutNo%02ld=%@&productName%02ld=%@&color%02ld=%@&size%02ld=%@&price%02ld=%@&qty%02ld=%@",noteDataString,countData,item.code,countData,item.productName,countData,item.color,countData,item.size,countData,item.price,countData,item.qty];
                countData++;
            }
            url = [NSURL URLWithString:[Utility url:urlEmailQRCode]];
        }
            break;
        case dbScanUnpostCM:
        {
            NSArray *dataList = (NSArray *)data;
            NSArray *selectedPostDetailList = dataList[0];
            NSArray *scanProductIDGroup = dataList[1];
            NSString *modifiedUser = dataList[2];
            NSString *modifiedDate = dataList[3];
            NSInteger countData = 0;
            noteDataString = [NSString stringWithFormat:@"scanProductIDGroup=%@&modifiedUser=%@&modifiedDate=%@&countPostDetail=%ld",scanProductIDGroup,modifiedUser,modifiedDate,(long)[selectedPostDetailList count]];
            
            for(PostDetail *item in selectedPostDetailList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&productID%02ld=%@",noteDataString,(long)countData,item.productID];
                countData++;
            }
            url = [NSURL URLWithString:[Utility url:urlScanUnpostCM]];
        }
            break;
        case dbScanUnpost:
        {
            NSArray *dataList = (NSArray *)data;
            NSArray *selectedPostDetailList = dataList[0];
            NSArray *scanProductIDGroup = dataList[1];
            NSString *modifiedUser = dataList[2];
            NSString *modifiedDate = dataList[3];
            NSInteger countData = 0;
            noteDataString = [NSString stringWithFormat:@"scanProductIDGroup=%@&modifiedUser=%@&modifiedDate=%@&countPostDetail=%ld",scanProductIDGroup,modifiedUser,modifiedDate,(long)[selectedPostDetailList count]];
            
            for(PostDetail *item in selectedPostDetailList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&productID%02ld=%@",noteDataString,(long)countData,item.productID];
                countData++;
            }
            url = [NSURL URLWithString:[Utility url:urlScanUnpost]];
        }
            break;
        case dbScanPost:
        {
            NSArray *dataList = (NSArray *)data;
            NSArray *selectedPostDetailList = dataList[0];
            NSArray *scanProductIDGroup = dataList[1];
            NSString *modifiedUser = dataList[2];
            NSString *modifiedDate = dataList[3];
            NSInteger countData = 0;
            noteDataString = [NSString stringWithFormat:@"scanProductIDGroup=%@&modifiedUser=%@&modifiedDate=%@&countPostDetail=%ld",scanProductIDGroup,modifiedUser,modifiedDate,(long)[selectedPostDetailList count]];
            
            for(PostDetail *item in selectedPostDetailList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&receiptProductItemID%02ld=%ld",noteDataString,(long)countData,item.receiptProductItemID];
                countData++;
            }
            url = [NSURL URLWithString:[Utility url:urlScanPost]];
            NSLog(@"scanpost url:%@",url);
        }
            break;
        case dbScanDelete:
        {
            NSArray *dataList = (NSArray *)data;
            NSArray *scanProductIDGroup = dataList[0];
            NSString *modifiedUser = dataList[1];
            NSString *modifiedDate = dataList[2];
            NSInteger eventID = [dataList[3] integerValue];
            NSString *status = dataList[4];
            noteDataString = [NSString stringWithFormat:@"scanProductIDGroup=%@&modifiedUser=%@&modifiedDate=%@&eventID=%ld&status=%@",scanProductIDGroup,modifiedUser,modifiedDate,eventID,status];
            url = [NSURL URLWithString:[Utility url:urlScanDelete]];
        }
            break;
        case dbScanEvent:
        {
            NSArray *dataList = (NSArray *)data;
            NSArray *scanProductIDGroup = dataList[0];
            NSString *modifiedUser = dataList[1];
            NSString *modifiedDate = dataList[2];
            NSInteger eventID = [dataList[3] integerValue];
            NSString *status = dataList[4];
            noteDataString = [NSString stringWithFormat:@"scanProductIDGroup=%@&modifiedUser=%@&modifiedDate=%@&eventID=%ld&status=%@",scanProductIDGroup,modifiedUser,modifiedDate,eventID,status];
            url = [NSURL URLWithString:[Utility url:urlScanEvent]];
        }
            break;
        case dbItemTrackingNo:
        case dbItemTrackingNoPostCustomerDelete:
        {
            NSArray *dataList = (NSArray *)data;
            PostCustomer *postCustomer = dataList[0];
            NSArray *receiptProductItemList = dataList[1];
           
            NSInteger countData = 0;
            noteDataString = [NSString stringWithFormat:@"countReceiptProductItem=%ld&postCustomerID=%ld",(long)[receiptProductItemList count],postCustomer.postCustomerID];
            
            for(ReceiptProductItem *item in receiptProductItemList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&receiptProductItemID%02ld=%ld",noteDataString,(long)countData,item.receiptProductItemID];
                countData++;
            }            
            url = [NSURL URLWithString:[Utility url:urlItemTrackingNoUpdate]];
        }
            break;
        case dbItemTrackingNoTrackingNoUpdate:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlItemTrackingNoTrackingNoUpdate]];
//            url = [NSURL URLWithString:@"/SAIM/SAIMItemTrackingNoTrackingNoUpdate.php"];
            
            NSLog(@"dbItemTrackingNoTrackingNoUpdate url:%@",url);
        }
            break;
        default:
            break;
    }
    
    
    noteDataString = [NSString stringWithFormat:@"%@&modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",noteDataString,[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
    NSLog(@"notedatastring: %@",noteDataString);
    NSLog(@"url: %@",url);
    
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *dataRaw, NSURLResponse *header, NSError *error) {

        if(!error || (error && error.code == -1005))//-1005 คือตอน push notification ไม่ได้
        {
            if(!dataRaw)
            {
                //data parameter is nil
                NSLog(@"Error: %@", [error debugDescription]);
                return ;
            }
            
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:dataRaw
                                  options:kNilOptions error:&error];
            NSString *status = json[@"status"];
            if([status isEqual:@"1"])
            {
                NSLog(@"update success");
                NSString *function = json[@"function"];
                NSString *strID = json[@"id"];
                NSArray *dataJson = json[@"dataJson"];
                if([function isEqualToString:@"scanUnpostCM"] || [function isEqualToString:@"scanUnpost"] || [function isEqualToString:@"scanPost"] || [function isEqualToString:@"CustomerReceiptUpdatePostCustomerID"] || [function isEqualToString:@"scanDelete"])
                {
                    if (self.delegate)
                    {
                        [self.delegate itemsUpdatedWithReturnID:[strID integerValue]];
                    }
                }
                else if([function isEqualToString:@"changeProduct"])
                {
                    NSArray *arrClassName = @[@"Product",@"CustomMade",@"ReceiptProductItem"];
                    NSArray *items = [Utility jsonToArray:dataJson arrClassName:arrClassName];
                    
                    
                    if(self.delegate)
                    {
                        [self.delegate itemsUpdatedWithReturnData:items];
                    }
                }
                else if([function isEqualToString:@"cashAllocation"])
                {
                    NSArray *arrClassName = @[@"CashAllocation"];
                    NSArray *items = [Utility jsonToArray:dataJson arrClassName:arrClassName];
                    
                    
                    if(self.delegate)
                    {
                        [self.delegate itemsUpdatedWithReturnData:items];
                    }
                }
                else if([function isEqualToString:@"receiptRemark"])
                {
                    NSArray *arrClassName = @[@"Receipt"];
                    NSArray *items = [Utility jsonToArray:dataJson arrClassName:arrClassName];
                    
                    
                    if(self.delegate)
                    {
                        [self.delegate itemsUpdatedWithReturnData:items];
                    }
                }
                else if([function isEqualToString:@"customMadeEdit"])
                {
                    NSArray *arrClassName = @[@"CustomMade"];
                    NSArray *items = [Utility jsonToArray:dataJson arrClassName:arrClassName];
                    
                    
                    if(self.delegate)
                    {
                        [self.delegate itemsUpdatedWithReturnData:items];
                    }
                }
                else if([function isEqualToString:@"ItemTrackingNo"])
                {
                    NSArray *arrClassName = @[@"PostCustomer"];
                    NSArray *items = [Utility jsonToArray:dataJson arrClassName:arrClassName];
                    
                    
                    if(self.delegate)
                    {
                        [self.delegate itemsUpdatedWithReturnData:items];
                    }
                }
                else
                {
                    if (self.delegate)
                    {
                        [self.delegate itemsUpdated];
                    }
                }
                
            }
            else if([status isEqual:@"2"])
            {
                NSString *alert = json[@"alert"];
                if (self.delegate)
                {
                    [self.delegate itemsUpdated:alert];
                }
            }
            else
            {
                //Error
                NSLog(@"update fail");
                NSLog(@"%@", status);
                if (self.delegate)
                {
//                    [self.delegate itemsFail];
                }
            }
        }
        else
        {
            if (self.delegate)
            {
                [self.delegate itemsFail];
//                [self.delegate connectionFail];
            }
            NSLog(@"Error: %@", [error debugDescription]);
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

- (void)deleteItems:(enum enumDB)currentDB withData:(NSObject *)data
{
    propCurrentDB = currentDB;
    NSURL * url;
    NSString *noteDataString;
    switch (currentDB)
    {
        case dbUserAccount:
        {
            UserAccount *userAccount = (UserAccount *)data;
            
            noteDataString = [NSString stringWithFormat:@"username=%@", userAccount.username];
            url = [NSURL URLWithString:[Utility url:urlUserAccountDelete]];
        }
            break;
        case dbEvent:
        {
            Event *event = (Event *)data;
            
            noteDataString = [NSString stringWithFormat:@"eventID=%ld",event.eventID];
            url = [NSURL URLWithString:[Utility url:urlEventDelete]];
        }
            break;
        case dbPostCustomer:
        {
            PostCustomer *postCustomer = (PostCustomer *)data;
            
            noteDataString = [NSString stringWithFormat:@"postCustomerID=%ld",postCustomer.postCustomerID];
            url = [NSURL URLWithString:[Utility url:urlPostCustomerDelete]];
        }
            break;

        case dbProduct:
        {
            NSMutableArray *arrData = (NSMutableArray *)data;
            NSMutableArray *arrProduct = arrData[0];
            NSMutableArray *arrProductDelete = arrData[1];
            NSInteger countProductDelete = 0;
            NSInteger countProduct = 0;
            
            noteDataString = [NSString stringWithFormat:@"countProductDelete=%ld&countProduct=%ld",[arrProductDelete count],[arrProduct count]];
            for(ProductDelete *item in arrProductDelete)
            {
                noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:item withRunningNo:countProductDelete]];
                countProductDelete++;
            }
            for(Product *item in arrProduct)
            {
                noteDataString = [NSString stringWithFormat:@"%@&productIDMain%02ld=%@",noteDataString,countProduct,item.productID];
                countProduct++;
            }
            
            url = [NSURL URLWithString:[Utility url:urlProductDelete]];
        }
            break;
        case dbUserAccountEvent:
        {
            UserAccountEvent *userAccountEvent = (UserAccountEvent *)data;
            
            noteDataString = [NSString stringWithFormat:@"userAccountID=%ld",userAccountEvent.userAccountID];
            url = [NSURL URLWithString:[Utility url:urlUserAccountEventDelete]];
        }
            break;
        case dbReceiptAndReceiptProductItemDelete:
        {
            //product->customMade->receiptproductitem->receipt->postcustomer->customerreceipt การเรียง execute table ใน database เพื่อป้องกันการเกิด lock table (การ lock table เกิดได้ใน 2 กรณี ของการ turn off auto commit 1.สับลำดับ execute table 2.การ update หรือ delete ที่ ไม่เรียงตาม primary key)
            NSArray *arrData = (NSArray *)data;
            Receipt *receipt = arrData[0];
//            CustomerReceipt *customerReceipt = arrData[1];
            NSArray *arrItemTrackingNo = arrData[1];
            NSArray *arrReceiptProductItem = arrData[2];
            NSArray *arrCustomMade = arrData[3];
            NSArray *arrProduct = arrData[4];
            
            
            NSInteger countProduct = 0;
            NSInteger countCustomMade = 0;
            NSInteger countReceiptProductItem = 0;
            NSInteger countItemTrackingNo = 0;
            noteDataString = [NSString stringWithFormat:@"countProduct=%lu&countCustomMade=%lu&countReceiptProductItem=%lu&countItemTrackingNo=%lu",(unsigned long)[arrProduct count],(unsigned long)[arrCustomMade count],(unsigned long)[arrReceiptProductItem count],(unsigned long)[arrItemTrackingNo count]];
            
            for(Product *item in arrProduct)
            {
                noteDataString = [NSString stringWithFormat:@"%@&productID%02ld=%@",noteDataString,(long)countProduct,item.productID];
                countProduct++;
            }
            for(CustomMade *item in arrCustomMade)
            {
                noteDataString = [NSString stringWithFormat:@"%@&customMadeID%02ld=%ld",noteDataString,(long)countCustomMade,(long)item.customMadeID];
                countCustomMade++;
            }
            for(ReceiptProductItem *item in arrReceiptProductItem)
            {
                noteDataString = [NSString stringWithFormat:@"%@&receiptProductItemID%02ld=%ld",noteDataString,(long)countReceiptProductItem,(long)item.receiptProductItemID];
                countReceiptProductItem++;
            }
            for(ItemTrackingNo *item in arrItemTrackingNo)
            {
                noteDataString = [NSString stringWithFormat:@"%@&itemTrackingNoID%02ld=%ld",noteDataString,(long)countItemTrackingNo,(long)item.itemTrackingNoID];
                countItemTrackingNo++;
            }
            noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:receipt]];
//            noteDataString = [NSString stringWithFormat:@"%@&%@",noteDataString,[Utility getNoteDataString:customerReceipt]];
            
            
            url = [NSURL URLWithString:[Utility url:urlReceiptAndReceiptProductItemDelete]];
        }
            break;
        case dbProductSalesSet:
        {
            ProductSalesSet *productSalesSet = (ProductSalesSet *)data;
            
            noteDataString = [NSString stringWithFormat:@"productSalesSetID=%@",productSalesSet.productSalesSetID];
            url = [NSURL URLWithString:[Utility url:urlProductSalesSetDelete]];
        }
            break;
        case dbProductCategory2:
        {
            NSString *code = (NSString *)data;
            
            noteDataString = [NSString stringWithFormat:@"code=%@",code];
            url = [NSURL URLWithString:[Utility url:urlProductCategory2Delete]];
        }
            break;
        case dbProductCategory1:
        {
            ProductCategory1 *productCategory1 = (ProductCategory1 *)data;
            
            noteDataString = [NSString stringWithFormat:@"code=%@&productCategory2=%@",productCategory1.code,productCategory1.productCategory2];
            url = [NSURL URLWithString:[Utility url:urlProductCategory1Delete]];
        }
            break;
        case dbColor:
        {
            Color *color = (Color *)data;
            
            noteDataString = [NSString stringWithFormat:@"code=%@",color.code];
            url = [NSURL URLWithString:[Utility url:urlColorDelete]];
        }
            break;
        case dbProductSize:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlProductSizeDelete]];
        }
            break;
        case dbProductName:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlProductNameDelete]];
        }
            break;
        case dbProductSales:
        {
            NSInteger countProductSales = 0;
            NSMutableArray *productSalesList = (NSMutableArray *)data;            
            noteDataString = [NSString stringWithFormat:@"countProductSales=%ld",[productSalesList count]];
            for(ProductSales *item in productSalesList)
            {
                noteDataString = [NSString stringWithFormat:@"%@&productSalesID%02ld=%ld",noteDataString,countProductSales,item.productSalesID];
                countProductSales++;
            }
            
            
            url = [NSURL URLWithString:[Utility url:urlProductSalesDelete]];
        }
            break;
        case dbProductSalesDeleteProductNameID:
        {
            NSString *strProductNameID = (NSString *)data;
            
            noteDataString = [NSString stringWithFormat:@"productNameID=%@",strProductNameID];
            url = [NSURL URLWithString:[Utility url:urlProductSalesDeleteProductNameID]];
        }
            break;
        case dbAccountInventory:
        {
            AccountInventory *accountInventory = (AccountInventory*)data;
            
            noteDataString = [NSString stringWithFormat:@"accountInventoryID=%ld",accountInventory.accountInventoryID];
            url = [NSURL URLWithString:[Utility url:urlAccountInventoryDelete]];
        }
            break;
        case dbAccountReceiptHistory:
        {
            AccountReceipt *accountReceipt = (AccountReceipt*)data;
            
            noteDataString = [NSString stringWithFormat:@"runningAccountReceiptHistory=%ld",accountReceipt.runningAccountReceiptHistory];
            url = [NSURL URLWithString:[Utility url:urlAccountReceiptHistoryDelete]];
        }
            break;
        case dbProductionOrder:
        {
            ProductionOrder *productionOrder = (ProductionOrder*)data;
            
            noteDataString = [NSString stringWithFormat:@"productionOrderID=%ld",productionOrder.productionOrderID];
            url = [NSURL URLWithString:[Utility url:urlProductionOrderDelete]];
        }
            break;
        case dbRewardProgram:
        {
            RewardProgram *rewardProgram = (RewardProgram*)data;
            
            noteDataString = [NSString stringWithFormat:@"rewardProgramID=%ld",rewardProgram.rewardProgramID];
            url = [NSURL URLWithString:[Utility url:urlRewardProgramDelete]];
        }
            break;
        case dbExpenseDaily:
        {
            ExpenseDaily *expenseDaily = (ExpenseDaily *)data;
            noteDataString = [NSString stringWithFormat:@"expenseDailyID=%ld",expenseDaily.expenseDailyID];
            url = [NSURL URLWithString:[Utility url:urlExpenseDailyDelete]];
        }
            break;
        default:
            break;
    }
    
    
    noteDataString = [NSString stringWithFormat:@"%@&modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",noteDataString,[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
    NSLog(@"notedatastring: %@",noteDataString);
    NSLog(@"url: %@",url);
    
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *dataRaw, NSURLResponse *header, NSError *error) {
        if(!error || (error && error.code == -1005))//-1005 คือตอน push notification ไม่ได้
        {
            if(!dataRaw)
            {
                //data parameter is nil
                NSLog(@"Error: %@", [error debugDescription]);
                return ;
            }
            
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:dataRaw
                                  options:kNilOptions error:&error];
            NSString *status = json[@"status"];
            if([status isEqual:@"1"])
            {
                if(self.delegate)
                {
                    [self.delegate itemsDeleted];
                }
                NSLog(@"delete success");
            }
            else
            {
                //Error
                NSLog(@"delete fail");
                NSLog(@"%@", status);
                if (self.delegate)
                {
//                    [self.delegate itemsFail];
                }
            }
        }
        else
        {
            if (self.delegate)
            {
                [self.delegate itemsFail];
//                [self.delegate connectionFail];
            }
            NSLog(@"Error: %@", [error debugDescription]);
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}
- (void)syncItems:(enum enumDB)currentDB withData:(NSObject *)data
{
    propCurrentDB = currentDB;
    NSURL * url;
    NSString *noteDataString;
    switch (currentDB) {
        case dbPushSync:
        {
            noteDataString = [Utility getNoteDataString:data];
            url = [NSURL URLWithString:[Utility url:urlPushSyncSync]];
        }
        break;
        default:
        break;
    }
    noteDataString = [NSString stringWithFormat:@"%@&modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",noteDataString,[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *dataRaw, NSURLResponse *header, NSError *error) {

        if(!error || (error && error.code == -1005))
        {
            if(!dataRaw)
            {
                //data parameter is nil
                NSLog(@"Error: %@", [error debugDescription]);
                return ;
            }
            
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:dataRaw
                                  options:kNilOptions error:&error];
            NSString *status = json[@"status"];
            if([status isEqual:@"1"])
            {
                if (self.delegate)
                {
                    [self.delegate itemsSynced:json[@"payload"]];
                }
            }
            else if([status isEqual:@"0"])
            {
                NSLog(@"sync succes with no new row update");
            }
            else
            {
                //Error
                NSLog(@"sync fail");
                NSLog([NSString stringWithFormat:@"status: %@",status]);
            }
        }
        else
        {
            NSLog(@"Error: %@", [error debugDescription]);
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

-(void)sendEmail:(NSString *)toAddress withSubject:(NSString *)subject andBody:(NSString *)body
{
    NSString *bodyPercentEscape = [Utility percentEscapeString:body];
    NSString *noteDataString = [NSString stringWithFormat:@"toAddress=%@&subject=%@&body=%@", toAddress,subject,bodyPercentEscape];
    noteDataString = [NSString stringWithFormat:@"%@&modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",noteDataString,[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:[Utility url:urlSendEmail]];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *dataRaw, NSURLResponse *header, NSError *error) {

        if(!error || (error && error.code == -1005))
        {
            if(!dataRaw)
            {
                //data parameter is nil
                NSLog(@"Error: %@", [error debugDescription]);
                [self.delegate removeOverlayViewConnectionFail];
                return ;
            }
            
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:dataRaw
                                  options:kNilOptions error:&error];
            NSString *status = json[@"status"];
            if([status isEqual:@"1"])
            {

            }
            else
            {
                //Error
                NSLog(@"send email fail");
                NSLog(@"%@", status);
                if (self.delegate)
                {
//                    [self.delegate itemsFail];
                }
            }
        }
        else
        {
            if (self.delegate)
            {
                [self.delegate itemsFail];
            }
            NSLog(@"Error: %@", [error debugDescription]);
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

-(void)uploadPhoto:(NSData *)imageData fileName:(NSString *)fileName
{
    if (imageData != nil)
    {
        NSString *noteDataString = @"";
        noteDataString = [NSString stringWithFormat:@"%@&modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",noteDataString,[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
        
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        
        NSURL * url = [NSURL URLWithString:[Utility url:urlUploadPhoto]];
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
//        [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
        
    
        
        NSMutableData *body = [NSMutableData data];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [urlRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        
        NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
        [_params setObject:[Utility modifiedUser] forKey:@"modifiedUser"];
//        [_params setObject:[Utility deviceToken] forKey:@"modifiedDeviceToken"];
        [_params setObject:[Utility dbName] forKey:@"dbName"];
        for (NSString *param in _params)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.jpg\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [body appendData:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [urlRequest setHTTPBody:body];
        
        NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *dataRaw, NSURLResponse *header, NSError *error) {
            if(error && error.code != -1005)
            {
                if (self.delegate)
                {
                    [self.delegate connectionFail];
                }
                NSLog(@"Error: %@", [error debugDescription]);
                NSLog(@"Error: %@", [error localizedDescription]);
            }
        }];
        
        [dataTask resume];
    }
}

- (void)downloadImageWithFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSString* escapeString = [Utility percentEscapeString:fileName];
    NSString *noteDataString = [NSString stringWithFormat:@"imageFileName=%@",escapeString];
    noteDataString = [NSString stringWithFormat:@"%@&modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",noteDataString,[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
    NSURL * url = [NSURL URLWithString:[Utility url:urlDownloadPhoto]];
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *dataRaw, NSURLResponse *header, NSError *error) {
        if(error)
        {
            completionBlock(NO,nil);
        }
        else
        {
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:dataRaw
                                  options:kNilOptions error:&error];
            

            NSString *base64String = json[@"base64String"];
            if(json && base64String && ![base64String isEqualToString:@""])
            {
                NSData *nsDataEncrypted = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
                UIImage *image = [[UIImage alloc] initWithData:nsDataEncrypted];
                completionBlock(YES,image);
            }
            else
            {
                completionBlock(NO,nil);
            }            
        }
    }];
    
    [dataTask resume];
}
- (void)downloadFileWithFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded, NSData *data))completionBlock
{
    NSString* escapeString = [Utility percentEscapeString:fileName];
    NSString *noteDataString = [NSString stringWithFormat:@"fileName=%@",escapeString];
    noteDataString = [NSString stringWithFormat:@"%@&modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",noteDataString,[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
    NSURL * url = [NSURL URLWithString:[Utility url:urlDownloadFile]];
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *dataRaw, NSURLResponse *header, NSError *error) {
        if(error != nil)
        {
            completionBlock(NO,nil);
        }
        else
        {
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:dataRaw
                                  options:kNilOptions error:&error];
            
            
            NSString *base64String = json[@"base64String"];
            if(json && base64String && ![base64String isEqualToString:@""])
            {
                NSData *nsDataEncrypted = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
                completionBlock(YES,nsDataEncrypted);
            }
            else
            {
                completionBlock(NO,nil);
            }
        }
    }];
    
    [dataTask resume];
}

- (void)generateSalesPeriodFrom:(NSString *)periodFrom periodTo:(NSString *)periodTo eventID:(NSString *)strEventID;
{
    NSString *noteDataString = [NSString stringWithFormat:@"periodFrom=%@&periodTo=%@&eventID=%@", periodFrom,periodTo,strEventID];
    noteDataString = [NSString stringWithFormat:@"%@&modifiedUser=%@&modifiedDeviceToken=%@&dbName=%@",noteDataString,[Utility modifiedUser],[Utility deviceToken],[Utility dbName]];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:[Utility url:urlGenerateSalesAllEvent]];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[noteDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *dataRaw, NSURLResponse *header, NSError *error) {

        if(!error || (error && error.code == -1005))
        {
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:dataRaw
                                  options:kNilOptions error:&error];
            NSString *status = json[@"status"];
            
            if([status isEqual:@"1"]){
                NSLog(@"generate sales success");
                //Success
                //notify
                
                NSString *fileName = json[@"fileName"];
                if (self.delegate)
                {
                    [self.delegate salesGenerated:fileName];
                }
            } else {
                //Error
                NSLog(@"generate sales fail");
                if (self.delegate)
                {
                    [self.delegate salesGeneratedFail];
                }
            }
        }
        else
        {
            if (self.delegate)
            {
                [self.delegate itemsFail];
            }
            NSLog(@"Error: %@", [error debugDescription]);
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

@end
