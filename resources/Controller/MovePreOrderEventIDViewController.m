//
//  MovePreOrderEventIDViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 8/2/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "MovePreOrderEventIDViewController.h"
#import "PostDetail.h"
#import "Product.h"
#import "SharedProduct.h"
#import "Event.h"
#import "ReceiptProductItem.h"
#import "Utility.h"
#import "PushSync.h"
#import "PreOrderEventIDHistory.h"


@interface MovePreOrderEventIDViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_eventMovableList;
}
@end

@implementation MovePreOrderEventIDViewController
@synthesize arrPostDetail;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadViewProcess
{
}

- (void)loadView
{
    [super loadView];
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    //inventory จะ post ที่ไหน ดูจาก receiptproductitem.preordereventid
    //ถ้าเป็น inventory ย้ายไป post ที่ event ที่มีของเท่านั้น
    //ถ้าเป็น cm ย้ายไป post ที่ event ไหนก็ได้
    int i = 0;
    NSMutableSet *eventSet = [[NSMutableSet alloc]init];
    NSMutableSet *eventSetTemp = [[NSMutableSet alloc]init];
    for(PostDetail *item in arrPostDetail)
    {
        if([item.productType isEqualToString:@"P"])
        {
            Product *product = [Product getProduct:item.productID];
            
            NSMutableArray *productList = [SharedProduct sharedProduct].productList;
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _status = 'I' and _eventID != %ld",product.productCategory2,product.productCategory1,product.productName,product.color,product.size ,product.eventID];
            NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
            
            if(i == 0)
            {
                eventSet = [[NSSet setWithArray:[filterArray valueForKey:@"_eventID"]] mutableCopy];
            }
            else
            {
                eventSetTemp = [[NSSet setWithArray:[filterArray valueForKey:@"_eventID"]] mutableCopy];
                [eventSet intersectSet:eventSetTemp];
            }
        }

        i++;
    }
    
    _eventMovableList = [[NSMutableArray alloc]init];
    for(NSString *eventID in eventSet)
    {
        if([eventID integerValue] == 0)
        {
            [_eventMovableList addObject:[Event getMainEvent]];
        }
        else
        {
            Event *event = [Event getEvent:[eventID integerValue]];
            [_eventMovableList addObject:event];
        }
    }
    
    NSArray *eventOngoingAndPast = [Event SplitEventNowAndFutureAndPast:_eventMovableList];
    _eventMovableList = eventOngoingAndPast[0];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [_eventMovableList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    
    Event *event = _eventMovableList[indexPath.row];
    cell.textLabel.text = event.location;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [Utility formatDateForDisplay:event.periodFrom],[Utility formatDateForDisplay:event.periodTo]];
    cell.detailTextLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //change preordereventid to selected event and insert preordereventidHistory
    //release booked product and reserve product at event destination
    NSMutableArray *productUpdateList = [[NSMutableArray alloc]init];
    NSMutableArray *receiptProductItemList = [[NSMutableArray alloc]init];
    NSMutableArray *preOrderEventIDHistoryList = [[NSMutableArray alloc]init];
    Event *event = _eventMovableList[indexPath.row];
    for(PostDetail *item in arrPostDetail)
    {
        Product *product = [Product getProduct:item.productID];
        product.status = @"I";
        product.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        product.modifiedUser = [Utility modifiedUser];
        [productUpdateList addObject:product];
        
        
        NSMutableArray *productList = [SharedProduct sharedProduct].productList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _status = 'I' and _eventID = %ld",product.productCategory2,product.productCategory1,product.productName,product.color,product.size ,event.eventID];
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
        Product *productDestination = filterArray[0];
        productDestination.status = @"P";
        productDestination.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        productDestination.modifiedUser = [Utility modifiedUser];
        [productUpdateList addObject:productDestination];
        
        
        ReceiptProductItem *receiptProductItem = [ReceiptProductItem getReceiptProductItem:item.receiptProductItemID];
        receiptProductItem.preOrderEventID = event.eventID;
        receiptProductItem.productID = productDestination.productID;
        receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        receiptProductItem.modifiedUser = [Utility modifiedUser];
        [receiptProductItemList addObject:receiptProductItem];
        
        PreOrderEventIDHistory *preOrderEventIDHistory = [[PreOrderEventIDHistory alloc] initWithReceiptProductItemID:receiptProductItem.receiptProductItemID preOrderEventID:receiptProductItem.preOrderEventID];
        [PreOrderEventIDHistory addObject:preOrderEventIDHistory];
        [preOrderEventIDHistoryList addObject:preOrderEventIDHistory];
    }
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        productUpdateList = [[productUpdateList sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    }
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptProductItemID" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        receiptProductItemList = [[receiptProductItemList sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    }
    [_homeModel updateItems:dbReceiptProductItemPreOrderEventID withData:@[productUpdateList,receiptProductItemList,preOrderEventIDHistoryList]];
    
    //unwind to product post and reload
    [self performSegueWithIdentifier:@"segUnwindToProductPost" sender:self];
}

-(void)itemsDownloaded:(NSArray *)items
{
//    {
//        PushSync *pushSync = [[PushSync alloc]init];
//        pushSync.deviceToken = [Utility deviceToken];
//        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
//    }
//    
//    
//    [Utility itemsDownloaded:items];
//    [self removeOverlayViews];
//    [self loadViewProcess];
}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
//                                                              [self loadingOverlayView];
//                                                              [_homeModel downloadItems:dbMaster];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

-(void) loadingOverlayView
{
    [indicator startAnimating];
    indicator.layer.zPosition = 1;
    indicator.alpha = 1;
    
    
    // and just add them to navigationbar view
    [self.navigationController.view addSubview:overlayView];
    [self.navigationController.view addSubview:indicator];
}

-(void) removeOverlayViews{
    UIView *view = overlayView;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         view.alpha = 0.0;
                         indicator.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         dispatch_async(dispatch_get_main_queue(),^ {
                             [view removeFromSuperview];
                             [indicator stopAnimating];
                             [indicator removeFromSuperview];
                         } );
                     }
     ];
}

- (void) connectionFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility subjectNoConnection]
                                                                   message:[Utility detailNoConnection]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //                                                              exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}
@end
