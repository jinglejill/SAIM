//
//  HomeModel.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserAccount.h"
#import <UIKit/UIKit.h>

@protocol HomeModelProtocol <NSObject>

@optional
- (void)itemsDownloaded:(NSArray *)items;
- (void)itemsInserted;
- (void)itemsUpdated;
- (void)itemsUpdatedWithReturnID:(NSInteger)ID;
- (void)itemsUpdatedWithReturnData:(NSArray *)data;
- (void)itemsUpdated:(NSString *)alert;
- (void)itemsSynced:(NSArray *)items;
- (void)itemsDeleted;
- (void)itemsDeletedWithReturnData:(NSArray *)data;
- (void)emailSent;
- (void)photoUploaded;
- (void)connectionFail;
- (void)itemsInsertedWithReturnID:(NSInteger)ID;
- (void)itemsInsertedWithReturnData:(NSArray *)data;
- (void)itemsFail;
//- (void)itemsQueryOrSendMailFail;
- (void)salesGenerated:(NSString *)fileName;
- (void)salesGeneratedFail;
- (void)downloadProgress:(float)percent;
- (void)removeOverlayViewConnectionFail;
@end


enum enumAction
{
    list,
    add,
    edit,
    delete
};

@interface HomeModel : NSObject<NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, weak) id<HomeModelProtocol> delegate;
@property (nonatomic) enum enumDB propCurrentDB;
@property (nonatomic, retain) NSMutableData *dataToDownload;
@property (nonatomic) float downloadSize;

- (void)downloadItems:(enum enumDB)currentDB;
- (void)downloadItems:(enum enumDB)currentDB condition:(NSObject *)object;
- (void)insertItems:(enum enumDB)currentDB withData:(NSObject *)data;
- (void)insertItemsJson:(enum enumDB)currentDB withData:(NSObject *)data;
- (void)updateItems:(enum enumDB)currentDB withData:(NSObject *)data;
- (void)deleteItems:(enum enumDB)currentDB withData:(NSObject *)data;
- (void)syncItems:(enum enumDB)currentDB withData:(NSObject *)data;
- (void)sendEmail:(NSString *)toAddress withSubject:(NSString *)subject andBody:(NSString *)body;
- (void)uploadPhoto:(NSData *)photo fileName:(NSString *)fileName;
- (void)downloadImageWithFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
- (void)downloadFileWithFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded, NSData *data))completionBlock;
- (void)generateSalesPeriodFrom:(NSString *)periodFrom periodTo:(NSString *)periodTo eventID:(NSString *)strEventID;
@end

