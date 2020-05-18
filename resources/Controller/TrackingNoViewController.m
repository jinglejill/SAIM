//
//  TrackingNoViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/2/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "TrackingNoViewController.h"
#import "HomeModel.h"
#import "Utility.h"
#import "ProductCost.h"
#import "CustomerReceipt.h"
#import "ItemTrackingNo.h"
#import "PostDetail.h"
#import "TrackingNoScanViewController.h"
#import "SharedPushSync.h"
#import "PushSync.h"

@interface TrackingNoViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
}
@end
@implementation TrackingNoViewController
@synthesize strTrackingNo;
//@synthesize receiptID;
@synthesize edit;
@synthesize btnCancel;
@synthesize btnDone;
@synthesize postDetailList;
@synthesize postDetailIndex;


- (IBAction)unwindToTrackingNo:(UIStoryboardSegue *)segue
{
    TrackingNoScanViewController *vc = segue.sourceViewController;
    txtTrackingNo.text = vc.strTrackingNo;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    txtTrackingNo.text = strTrackingNo;
    [cell addSubview:txtTrackingNo];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Life Cycle method
- (void)loadView
{
    [super loadView];
    
    // Create new HomeModel object and assign it to _homeModel variable
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    
    float controlWidth = self.tableView.bounds.size.width - 15*2;//minus left, right margin
    float controlXOrigin = 15;
    float controlYOrigin = (44 - 25)/2;//table row height minus control height and set vertical center
    
    txtTrackingNo = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtTrackingNo.placeholder = @"Tracking No.";
    txtTrackingNo.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtTrackingNo.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    [txtTrackingNo setKeyboardType:UIKeyboardTypeDefault];
    
    
    [self loadViewProcess];
    PostDetail *postDetail = postDetailList[postDetailIndex];
    NSLog(@"post detail->productname:%@, color:%@, size:%@",postDetail.productName,postDetail.color,postDetail.size);
}

- (void)loadViewProcess
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

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
- (IBAction)scanTrackingNo:(id)sender {
    [self performSegueWithIdentifier:@"segTrackingNoScan" sender:self];
}

- (IBAction)saveTrackingNo:(id)sender
{
    edit = YES;

//    CustomerReceipt *customerReceipt = [[CustomerReceipt alloc]init];
//    customerReceipt.trackingNo = txtTrackingNo.text;
//    customerReceipt.receiptID = receiptID;
//
//    [_homeModel updateItems:dbCustomerReceiptUpdateTrackingNo withData:customerReceipt];
    
    
    
    ItemTrackingNo *itemTrackingNo = [[ItemTrackingNo alloc]init];
    itemTrackingNo.receiptProductItemID = _receiptProductItemID;
    itemTrackingNo.trackingNo = txtTrackingNo.text;
    itemTrackingNo.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    itemTrackingNo.modifiedUser = [Utility modifiedUser];
    [_homeModel updateItems:dbItemTrackingNoTrackingNoUpdate withData:itemTrackingNo];
}

-(void)itemsUpdated
{
    for(PostDetail *item in postDetailList)
    {
//        if(item.receiptID == receiptID)
        if(item.receiptProductItemID == _receiptProductItemID)
        {
            //update tracking no in table postdetail in postedviewcontroller
            item.trackingNo = txtTrackingNo.text;            
            break;
        }
    }
    
    [self performSegueWithIdentifier:@"segUnwindToProductPosted2" sender:self];
}
@end
