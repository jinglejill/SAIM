//
//  ProductCategory1ViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/13/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductCategory1ViewController.h"
#import "HomeModel.h"
#import "Utility.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "ProductCategory1.h"
#import "ProductName.h"
#import "AdminMenuViewController.h"
#import "ProductSales.h"
#import "SharedProductName.h"
#import "SharedProduct.h"
#import "SharedProductCategory1.h"
#import "SharedProductSales.h"
#import "SharedCustomMade.h"
#import "SharedPushSync.h"
#import "PushSync.h"

@interface ProductCategory1ViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productCategory1List;
    NSMutableArray *_defaultList;
    NSMutableArray *_newList;
    NSMutableArray *_initialDataList;
}
@end


@implementation ProductCategory1ViewController
@synthesize tableViewList;
@synthesize productCategory2;

- (IBAction)unwindToProductCategory1:(UIStoryboardSegue *)segue
{
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    
    // Register cell classes
    [tableViewList registerClass:[MGSwipeTableCell class] forCellReuseIdentifier:@"TableViewList"];
}

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
    
    
    _defaultList = [[NSMutableArray alloc]init];
    _newList = [[NSMutableArray alloc]init];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    _defaultList = [SharedProductCategory1 sharedProductCategory1].productCategory1List;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2];
    NSArray *filterArray = [_defaultList filteredArrayUsingPredicate:predicate1];
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    _defaultList = [sortArray mutableCopy];
    _initialDataList = [[NSMutableArray alloc] initWithArray:_defaultList copyItems:YES];
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0?[_defaultList count]:[_newList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGSwipeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TableViewList"];
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TableViewList"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    
    if ([cell.textNewLabel isDescendantOfView:cell]) {
        [cell.textNewLabel removeFromSuperview];
    }
    
    
    if(section == 0)
    {
        ProductCategory1 *productCategory1 = _defaultList[row];
        cell.textNewLabel.text = productCategory1.name;
        [cell.contentView addSubview:cell.textNewLabel];
        cell.rightButtons = [self createRightButtons:1 indexPath:indexPath];
    }
    else if(section == 1)
    {
        ProductCategory1 *productCategory1 = _newList[row];        
        cell.textNewLabel.text = productCategory1.name;
        cell.textNewLabel.placeholder = @"New item";
        [cell.contentView addSubview:cell.textNewLabel];
        cell.rightButtons = [self createRightButtons:1 indexPath:indexPath];
    }
    
    return cell;
}

-(void)updateDefaultAndAddNewData
{
    //update data in defaultLabelList
    for(int i=0; i<[_defaultList count]; i++)
    {
        ProductCategory1 *productCategory1Initial = _initialDataList[i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        ProductCategory1 *productCategory1 = _defaultList[i];
        if(cell != nil)
        {
            productCategory1.name = cell.textNewLabel.text;
            if(![productCategory1.name isEqualToString:productCategory1Initial.name])
            {
                productCategory1.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                productCategory1.modifiedUser = [Utility modifiedUser];
            }
        }
    }
    
    //add current data to temp
    //remove all newLabelList
    //add temp data to newlabellist
//    [self convertCodeToProductCategory1ID];
    NSInteger intNextCode = [[self getNextCode] integerValue];
    NSMutableArray *productCategory1NewList = [[NSMutableArray alloc]init];
    for(int i=0; i<[_newList count]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        ProductCategory1 *productCategory1 = [[ProductCategory1 alloc]init];
        if(cell != nil)
        {
            productCategory1.code = [NSString stringWithFormat:@"%02ld",intNextCode + i];
            productCategory1.name = cell.textNewLabel.text;
            productCategory1.productCategory2 = productCategory2;
            productCategory1.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            productCategory1.modifiedUser = [Utility modifiedUser];
        }        
        [productCategory1NewList addObject:productCategory1];
    }
    
    //remove all newLabelList
    //add temp data to newlabellist
    [_newList removeAllObjects];
    [_newList addObjectsFromArray:productCategory1NewList];
}

-(BOOL)productCategory1InUse:(NSString *)code
{
    {
        NSMutableArray *productList = [SharedProduct sharedProduct].productList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@",productCategory2, code];
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
        
        if([filterArray count]>0)
        {
            return YES;
        }
    }
    {
        NSMutableArray *customMadeList = [SharedCustomMade sharedCustomMade].customMadeList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@",productCategory2, code];
        NSArray *filterArray = [customMadeList filteredArrayUsingPredicate:predicate1];
        if([filterArray count]>0)
        {
            return YES;
        }
    }
    
    //เช็ค productname
    {
        NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _code != %@",productCategory2 ,code, @"00"];
        NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
        if([filterArray count]>0)
        {
            return YES;
        }
    }
    
    return NO;
}

-(NSArray *) createRightButtons: (int) number indexPath:(NSIndexPath*)indexPath
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[1] = {@"Delete"};
    UIColor * colors[1] = {[UIColor redColor]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            if (i==0)
            {
                MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
                [alert addAction:
                 [UIAlertAction actionWithTitle:@"Delete item"
                                          style:UIAlertActionStyleDestructive
                                        handler:^(UIAlertAction *action) {
                                            
                                            [self updateDefaultAndAddNewData];
                                            
                                            
                                            //remove selected row
                                            if(indexPath.section == 0)
                                            {
                                                ProductCategory1 *productCategory1 = _defaultList[indexPath.row];
                                                if(![self productCategory1InUse:productCategory1.code])
                                                {
                                                    [_homeModel deleteItems:dbProductCategory1 withData:productCategory1];
                                                    
                                                    //update sharedproductcategory1
                                                    [[SharedProductCategory1 sharedProductCategory1].productCategory1List removeObject:productCategory1];
                                                    [_defaultList removeObjectAtIndex:indexPath.row];
                                                    
                                                    
                                                    //delete productname code='00' ด้วย
                                                    NSString *strProductNameID = @"";
//                                                    ProductName *productName = [[ProductName alloc]init];
                                                    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
                                                    for(ProductName *item in productNameList)
                                                    {
                                                        if([item.productCategory2 isEqualToString:productCategory2] && [item.productCategory1 isEqualToString:productCategory1.code] && [item.code isEqualToString:@"00"])
                                                        {
                                                            strProductNameID = [NSString stringWithFormat:@"%ld",item.productNameID];
                                                            [_homeModel deleteItems:dbProductName withData:item];
                                                            
                                                            //update sharedproductname
                                                            [productNameList removeObject:item];
                                                            break;
                                                        }
                                                    }
                                                    
                                                    //delete productsales selected productnameid, update sharedproductsales
                                                    [_homeModel deleteItems:dbProductSalesDeleteProductNameID withData:strProductNameID];
                                                    
                                                    
                                                    NSMutableArray *deleteProductSales = [[NSMutableArray alloc]init];
                                                    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
                                                    for(ProductSales *item in productSalesList)
                                                    {
                                                        if(item.productNameID == [strProductNameID integerValue])
                                                        {
                                                            [deleteProductSales addObject:item];
                                                        }
                                                    }
                                                    [productSalesList removeObjectsInArray:deleteProductSales];
                                                }
                                                else
                                                {
                                                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot delete"
                                                                                                                   message:@"This sub category is in use"
                                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                                    
                                                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                                          handler:^(UIAlertAction * action) {}];
                                                    
                                                    [alert addAction:defaultAction];                                                    
                                                    [self presentViewController:alert animated:YES completion:nil];
                                                    
                                                }
                                            }
                                            else
                                            {
                                                [_newList removeObjectAtIndex:indexPath.row];
                                            }
                                            
                                            
                                            //reload table
                                            [tableViewList reloadData];
                                            
                                        }]];
                [alert addAction:
                 [UIAlertAction actionWithTitle:@"Cancel"
                                          style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction *action) {}]];
                
                
                ///////////////ipad
                if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                {
                    [alert setModalPresentationStyle:UIModalPresentationPopover];
                    
                    UIPopoverPresentationController *popPresenter = [alert
                                                                     popoverPresentationController];
                    //                        CGRect frame = cell.imageView.bounds;
                    //                        frame.origin.y = frame.origin.y-15;
                    popPresenter.sourceView = cell;
                    popPresenter.sourceRect = cell.bounds;
                    //        popPresenter.barButtonItem = _barButtonIpad;
                }
                ///////////////
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            BOOL autoHide = i != 0;
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    return result;
}

- (NSString *)getNextCode
{
    //gen next running code
    NSMutableArray *productCategory1List = [SharedProductCategory1 sharedProductCategory1].productCategory1List;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2];
    NSArray *filterArray = [productCategory1List filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_code" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    productCategory1List = [sortArray mutableCopy];
    
    if([productCategory1List count] == 0)
    {
        return @"1";
    }
    else
    {
        ProductCategory1 *productCategory1 = productCategory1List[0];
        NSInteger number = [productCategory1.code intValue];
        return [NSString stringWithFormat:@"%02ld",number+1];
    }
}
//- (NSInteger)getNextCodeWithProductCategory1:(NSString *)productCategory1
//{
//    //gen next running code
//    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@",productCategory2,productCategory1];
//    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
//    
//    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_code" ascending:NO];
//    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
//    productNameList = [sortArray mutableCopy];
//    
//    if([productNameList count] == 0)
//    {
//        return 0;
//    }
//    else
//    {
//        ProductName *productName = productNameList[0];
//        NSInteger number = [productName.code intValue];
//        return number;
//    }
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Life Cycle method
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

- (BOOL)validateData
{
    return YES;
}

- (IBAction)addItem:(id)sender {
    [self updateDefaultAndAddNewData];
    
    //add new row
    ProductCategory1 *productCategory1 = [[ProductCategory1 alloc]init];
    productCategory1.name = @"";
    [_newList addObject:productCategory1];
    
    
    //reload table
    [tableViewList reloadData];
}

- (IBAction)doneButtonClicked:(id)sender {
    
    [self updateDefaultAndAddNewData];
    
    
    //prepare data for update
    NSMutableArray *updateList = [[NSMutableArray alloc]init];
    for(int i=0; i<[_defaultList count]; i++)
    {
        ProductCategory1 *productCategory1 = _defaultList[i];
        ProductCategory1 *productCategory1Initial = _initialDataList[i];
        if(![productCategory1.name isEqualToString:productCategory1Initial.name] && ![productCategory1.name isEqualToString:@""])
        {
            [updateList addObject:productCategory1];
        }
    }
    
    if([updateList count]>0)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productCategory2" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_code" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
        NSArray *sortArray = [updateList sortedArrayUsingDescriptors:sortDescriptors];
        
        float itemsPerConnection = [Utility getNumberOfRowForExecuteSql]+0.0;
        float countUpdate = ceil([sortArray count]/itemsPerConnection);
        for(int i=0; i<countUpdate; i++)
        {
            NSInteger startIndex = i * itemsPerConnection;
            NSInteger count = MIN([sortArray count] - startIndex, itemsPerConnection );
            NSArray *subArray = [sortArray subarrayWithRange: NSMakeRange( startIndex, count )];
                        
            [_homeModel updateItems:dbProductCategory1 withData:subArray];
        }
    }
    
    if([_newList count]>0)
    {
        NSMutableArray *blankList = [[NSMutableArray alloc]init];
        for(int i=0; i<[_newList count]; i++)
        {
            ProductCategory1 *productCategory1 = _newList[i];
            if([productCategory1.name isEqualToString:@""])
            {
                [blankList addObject:productCategory1];
            }
        }
        [_newList removeObjectsInArray:blankList];
        
        //update sharedproductcat1
        [[SharedProductCategory1 sharedProductCategory1].productCategory1List addObjectsFromArray:_newList];
        [_homeModel insertItems:dbProductCategory1 withData:_newList];
        
        
        
        //add productname cm
        NSInteger nextID = [Utility getNextID:tblProductName];
        NSMutableArray *productNameNewList = [[NSMutableArray alloc]init];
        for(int i=0; i<[_newList count]; i++)
        {
            ProductCategory1 *productCategory1 = _newList[i];
            ProductName *productName = [[ProductName alloc]init];
            productName.productNameID = nextID+i;
            productName.code = @"00";
            productName.name = [NSString stringWithFormat:@"CM %@",productCategory1.name];
            productName.productCategory2 = productCategory2;
            productName.productCategory1 = productCategory1.code;
            productName.detail = @"";
            productName.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            productName.modifiedUser = [Utility modifiedUser];
            
            [productNameNewList addObject:productName];
        }
        //update sharedproductname
//        [[SharedProductName sharedProductName].productNameList addObjectsFromArray:productNameNewList];
        [self loadingOverlayView];
        [_homeModel insertItems:dbProductName withData:productNameNewList];
    }

    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[AdminMenuViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}
-(void)itemsInsertedWithReturnData:(NSMutableArray *)data
{
    [self removeOverlayViews];
    [Utility addToSharedDataList:data];
    [self loadViewProcess];
}
- (void)itemsDeleted
{
}

- (void)itemsInserted
{
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
