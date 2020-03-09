//
//  ProductNameViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/5/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductNameViewController.h"
#import "HomeModel.h"
#import "Utility.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "ProductCategory1.h"
#import "ProductName.h"
#import "ProductSettingColorAndSizeViewController.h"
#import "ProductCategory1SelectionViewController.h"
#import "AdminMenuViewController.h"
#import "ProductNameDetailViewController.h"
#import "Color.h"
#import "ProductSize.h"
#import "SharedProductName.h"
#import "SharedCustomMade.h"
#import "SharedColor.h"
#import "SharedProduct.h"
#import "SharedProductSales.h"
#import "SharedProductSize.h"
#import "SharedPushSync.h"
#import "PushSync.h"



@interface ProductNameViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productCategory1List;
    NSMutableArray *_defaultList;
    NSMutableArray *_newList;
    NSMutableArray *_initialDataList;
    ProductName *_selectedProductName;
}
@end



@implementation ProductNameViewController
@synthesize tableViewList;
@synthesize productCategory2;
@synthesize productCategory1;

- (IBAction)unwindToProductName:(UIStoryboardSegue *)segue
{
    [self.tableView reloadData];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    
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
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    [self setDefaultList];
}
-(void)setDefaultList
{
    _defaultList = [[NSMutableArray alloc]init];
    _newList = [[NSMutableArray alloc]init];
    
    
    
    _defaultList = [SharedProductName sharedProductName].productNameList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@",productCategory2, productCategory1];
    NSArray *filterArray = [_defaultList filteredArrayUsingPredicate:predicate1];
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_active" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
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
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TableViewList"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    
    if ([cell.textNewLabel isDescendantOfView:cell]) {
        [cell.textNewLabel removeFromSuperview];
    }
    CGRect frame = cell.textNewLabel.frame;
    frame.size.width = frame.size.width - 40;
    cell.textNewLabel.frame = frame;
    cell.textNewLabel.delegate = self;
    
    
    if(section == 0)
    {
        ProductName *productName = _defaultList[row];
        cell.textNewLabel.text = productName.name;
        [cell addSubview:cell.textNewLabel];
        
        
        if([productName.code isEqualToString:@"00"])
        {
            cell.rightButtons = [self createRightButtons:2 indexPath:indexPath startButton:1];
        }
        else
        {
            cell.rightButtons = [self createRightButtons:2 indexPath:indexPath startButton:0];
        }
        
        BOOL selectedVal = productName.active==1;
        if(selectedVal == YES)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if(section == 1)
    {
        ProductName *productName = _newList[row];
        cell.textNewLabel.text = productName.name;
        cell.textNewLabel.placeholder = @"New item";
        [cell addSubview:cell.textNewLabel];
        cell.rightButtons = [self createRightButtons:2 indexPath:indexPath startButton:0];
    }
    
    return cell;
}

-(void)updateDefaultAndAddNewData
{
    //update data in defaultLabelList
    for(int i=0; i<[_defaultList count]; i++)
    {
        ProductName *productNameInitial = _initialDataList[i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        ProductName *productName = _defaultList[i];
        if(cell != nil)
        {
            productName.name = cell.textNewLabel.text;
            if(![productName.name isEqualToString:productNameInitial.name])
            {
                productName.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                productName.modifiedUser = [Utility modifiedUser];
            }
        }
    }
    
    //add current data to temp
    //remove all newLabelList
    //add temp data to newlabellist
    NSInteger nextID = [Utility getNextID:tblProductName];
    NSMutableArray *productNameNewList = [[NSMutableArray alloc]init];
    for(int i=0; i<[_newList count]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        ProductName *productName = [[ProductName alloc]init];
        if(cell != nil)
        {
            productName.productNameID = nextID+i;
            productName.code = [self getNextCode];
            productName.name = cell.textNewLabel.text;
            productName.productCategory2 = productCategory2;
            productName.productCategory1 = productCategory1;
            productName.detail = @"";
            productName.active = cell.accessoryType == UITableViewCellAccessoryCheckmark?1:0;
            productName.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            productName.modifiedUser = [Utility modifiedUser];
        }
        [productNameNewList addObject:productName];
    }
    
    //remove all newLabelList
    //add temp data to newlabellist
    [_newList removeAllObjects];
    [_newList addObjectsFromArray:productNameNewList];
}

- (NSString *)getNextCode
{
    NSMutableArray *productNameList = [SharedProductName sharedProductName].productNameList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ && _productCategory1 = %@",productCategory2,productCategory1];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    
    
    NSInteger i=1;
    while([self codeExist:i dataList:filterArray])
    {
        i++;
    }
    return [NSString stringWithFormat:@"%02ld",i];
}
- (BOOL)codeExist:(NSInteger)i dataList:(NSArray*)dataList
{
    NSString *code = [NSString stringWithFormat:@"%02ld",i];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_code = %@",code];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate1];
    return [filterArray count] != 0;
}

-(BOOL)productNameInUse:(NSString *)code
{
    {
        NSMutableArray *productList = [SharedProduct sharedProduct].productList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@",productCategory2, productCategory1, code];
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
        
        if([filterArray count]>0)
        {
            return YES;
        }
    }
    {
        NSMutableArray *customMadeList = [SharedCustomMade sharedCustomMade].customMadeList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@",productCategory2, productCategory1, code];
        NSArray *filterArray = [customMadeList filteredArrayUsingPredicate:predicate1];
        if([filterArray count]>0)
        {
            return YES;
        }
    }
    
    return NO;
}

-(NSArray *) createRightButtons: (int) number indexPath:(NSIndexPath*)indexPath startButton:(int) index
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"Delete", @"Edit"};
    UIColor * colors[2] = {[UIColor redColor], [UIColor lightGrayColor]};
    for (int i = index; i < number; ++i)
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
                                                ProductName *productName = _defaultList[indexPath.row];
                                                if(![self productNameInUse:productName.code])
                                                {
                                                    //delete productname
                                                    [_homeModel deleteItems:dbProductName withData:productName];
                                                    
                                                    
                                                    //update sharedproductname
                                                    [[SharedProductName sharedProductName].productNameList removeObject:productName];
                                                    [_defaultList removeObjectAtIndex:indexPath.row];
                                                    
                                                    
                                                    
                                                    //delete productsales
                                                    NSString *strProductNameID = [NSString stringWithFormat:@"%ld",productName.productNameID];
                                                    [_homeModel deleteItems:dbProductSalesDeleteProductNameID withData:strProductNameID];
                                                    
                                                    
                                                    //update shared
                                                    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
                                                    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productName.productNameID];
                                                    NSArray *filterArray = [productSalesList filteredArrayUsingPredicate:predicate1];
                                                    [productSalesList removeObjectsInArray:filterArray];                                                    
                                                }
                                                else
                                                {
                                                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot delete"
                                                                                                                   message:@"This style is in use"
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
            else if(i == 1)
            {
                NSLog(@"edit product name");
                
                
                //ถ้าเป็น CM ให้ข้ามหน้า product setting color and size ไปหน้า productname detail เลย
                if(indexPath.section == 0)
                {
                    ProductName *productName = _defaultList[indexPath.item];
                    if([productName.code isEqualToString:@"00"])
                    {
                        [self performSegueWithIdentifier:@"segProductNameDetail" sender:self];
                    }
                    else
                    {
                        [self segueToProductSettingColorAndSize:indexPath];
                    }
                }
                else
                {
                    //seg to product setting color and size
                    [self segueToProductSettingColorAndSize:indexPath];
                }
            }

            BOOL autoHide = i != 0;
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    return result;
}
- (void)segueToProductSettingColorAndSize:(NSIndexPath *)indexPath
{
    //do donebuttonclicked
    [self updateDefaultAndAddNewData];
    [self updateDataInDB];
    
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    ProductSettingColorAndSizeViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"ProductSettingColorAndSizeViewController"];
    
    if(indexPath.section == 0)
    {
        _selectedProductName = _defaultList[indexPath.item];
    }
    else if(indexPath.section == 1)
    {
        _selectedProductName = _newList[indexPath.item];
    }
    vc.productName = _selectedProductName;
    
    
    //setdefaultlist
    [self setDefaultList];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segProductNameDetail"])
    {
        ProductName *productName;
        for(ProductName *item in _defaultList)
        {
            if([item.code isEqualToString:@"00"])
            {
                productName = item;
                break;
            }
        }
        
        NSMutableArray *colorList = [SharedColor sharedColor].colorList;
        NSMutableArray *_selectedColorList = [[NSMutableArray alloc]init];
        for(Color *item in colorList)
        {
            if([item.code isEqualToString:@"00"])
            {
                [_selectedColorList addObject:item];
                break;
            }
        }
        
        NSMutableArray *productSizeList = [SharedProductSize sharedProductSize].productSizeList;
        NSMutableArray *_selectedSizeList = [[NSMutableArray alloc]init];
        for(ProductSize *item in productSizeList)
        {
            if([item.code isEqualToString:@"00"])
            {
                [_selectedSizeList addObject:item];
                break;
            }
        }
        ProductNameDetailViewController *vc = segue.destinationViewController;
        vc.selectedColorList = _selectedColorList;
        vc.selectedSizeList = _selectedSizeList;
        vc.selectedProductName = productName;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ProductName *productName = _defaultList[indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        productName.active = 0;
//        [self.itemDetailsList setObject:[NSNumber numberWithBool:NO] forKey:[self.allKeys objectAtIndex:indexPath.row]];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        productName.active = 1;
//        [self.itemDetailsList setObject:[NSNumber numberWithBool:YES] forKey:[self.allKeys objectAtIndex:indexPath.row]];
    }
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
    ProductName *productName = [[ProductName alloc]init];
    productName.name = @"";
    productName.active = 1;
    [_newList addObject:productName];
    
    
    //reload table
    [tableViewList reloadData];
}

- (IBAction)doneButtonClicked:(id)sender {
    
    [self updateDefaultAndAddNewData];
    [self updateDataInDB];
    
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[AdminMenuViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

-(void)updateDataInDB
{
    NSMutableArray *updateList = [[NSMutableArray alloc]init];
    for(int i=0; i<[_defaultList count]; i++)
    {
        ProductName *productName = _defaultList[i];
        ProductName *productNameInitial = _initialDataList[i];
        if((![productName.name isEqualToString:productNameInitial.name] && ![productName.name isEqualToString:@""]) || productName.active != productNameInitial.active)
        {
            [updateList addObject:productName];
        }
    }
    
    if([updateList count]>0)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productCategory2" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_productCategory1" ascending:YES];
        NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_code" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
        NSArray *sortArray = [updateList sortedArrayUsingDescriptors:sortDescriptors];
        
        float itemsPerConnection = [Utility getNumberOfRowForExecuteSql]+0.0;
        float countUpdate = ceil([sortArray count]/itemsPerConnection);
        for(int i=0; i<countUpdate; i++)
        {
            NSInteger startIndex = i * itemsPerConnection;
            NSInteger count = MIN([sortArray count] - startIndex, itemsPerConnection );
            NSArray *subArray = [sortArray subarrayWithRange: NSMakeRange( startIndex, count )];
                        
            [_homeModel updateItems:dbProductName withData:subArray];
        }
    }
    
    if([_newList count]>0)
    {
        NSMutableArray *blankList = [[NSMutableArray alloc]init];
        for(int i=0; i<[_newList count]; i++)
        {
            ProductName *productName = _newList[i];
            if([productName.name isEqualToString:@""])
            {
                [blankList addObject:productName];
            }
        }
        [_newList removeObjectsInArray:blankList];
        
        //update sharedproductname
//        [[SharedProductName sharedProductName].productNameList addObjectsFromArray:_newList];
        [self loadingOverlayView];
        [_homeModel insertItems:dbProductName withData:_newList];
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
- (void)itemsUpdated
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
