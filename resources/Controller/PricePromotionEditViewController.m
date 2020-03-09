//
//  PricePromotionEditViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/29/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "PricePromotionEditViewController.h"
#import "HomeModel.h"
#import "Utility.h"
#import "ProductSales.h"
#import "SharedPushSync.h"
#import "PushSync.h"


@interface PricePromotionEditViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
}
@end

@implementation PricePromotionEditViewController
@synthesize strPricePromotion;
@synthesize arrProductSalesID;
@synthesize edit;
@synthesize btnCancel;
@synthesize btnDone;
@synthesize productSalesList;

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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
     
    if([arrProductSalesID count]==1)
    {
        txtPricePromotion.text = strPricePromotion;
    }
    else
    {
        txtPricePromotion.text = @"";
    }
    
    [cell addSubview:txtPricePromotion];
    
    
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
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    
    float controlWidth = self.tableView.bounds.size.width - 15*2;//minus left, right margin
    float controlXOrigin = 15;
    float controlYOrigin = (44 - 25)/2;//table row height minus control height and set vertical center
    
    txtPricePromotion = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtPricePromotion.placeholder = @"Promtion price";
    txtPricePromotion.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPricePromotion.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    [txtPricePromotion setKeyboardType:UIKeyboardTypeDecimalPad];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    //validate username must be email
    if([sender isEqual:btnDone]){
        if(![self validateData])
        {
            return NO;
        }
    }
    return YES;
}
- (BOOL)validateData
{
    //location not empty
    if([[txtPricePromotion.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"Please input promotion price"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isEqual:btnDone])
    {
        edit = YES;
        if([arrProductSalesID count] == 1) //price at last index
        {
            //update sharedproductsales
            NSInteger productSalesID = [arrProductSalesID[0] integerValue];
            ProductSales *productSales = [[ProductSales alloc]init];
            
            for(ProductSales *item in productSalesList)
            {
                if(item.productSalesID == productSalesID)
                {
                    item.pricePromotion = txtPricePromotion.text;
                    
                    productSales.pricePromotion = txtPricePromotion.text;
                    productSales.productSalesID = productSalesID;
                    break;
                }
            }
            
            [_homeModel updateItems:dbProductSales withData:productSales];
        }
        else
        {
            //update sharedproductsales
            for(NSString *strProductSalesID in arrProductSalesID)
            {
                for(ProductSales *item in productSalesList)
                {
                    if(item.productSalesID == [strProductSalesID integerValue])
                    {
                        item.pricePromotion = txtPricePromotion.text;
                    }
                }
            }
            
            
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productSalesID" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
            NSArray *sortArray = [productSalesList sortedArrayUsingDescriptors:sortDescriptors];
            
            float itemsPerConnection = [Utility getNumberOfRowForExecuteSql]+0.0;
            float countUpdate = ceil([sortArray count]/itemsPerConnection);
            for(int i=0; i<countUpdate; i++)
            {
                NSInteger startIndex = i * itemsPerConnection;
                NSInteger count = MIN([sortArray count] - startIndex, itemsPerConnection );
                NSArray *subArray = [sortArray subarrayWithRange: NSMakeRange( startIndex, count )];
                
                [_homeModel updateItems:dbProductSalesMultipleUpdate withData:subArray];
            }
        }
    }
}

-(void)itemsDownloaded:(NSArray *)items
{
    {
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
    }
    
    
    [Utility itemsDownloaded:items];
    [self removeOverlayViews];
    [self loadViewProcess];
}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self loadingOverlayView];
                                                              [_homeModel downloadItems:dbMaster];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (void)itemsUpdated
{
    
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
