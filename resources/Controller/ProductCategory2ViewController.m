//
//  ProductCategory2ViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/10/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductCategory2ViewController.h"
#import "HomeModel.h"
#import "Utility.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "ProductCategory2.h"
#import "SharedProduct.h"
#import "SharedProductCategory2.h"
#import "SharedProductCategory1.h"
#import "SharedCustomMade.h"
#import "SharedPushSync.h"
#import "SharedColor.h"
#import "PushSync.h"


@interface ProductCategory2ViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productCategory2List;
    NSMutableArray *_defaultList;
    NSMutableArray *_newList;
    NSMutableArray *_initialDataList;
}
@end

@implementation ProductCategory2ViewController
@synthesize tableViewList;
- (IBAction)unwindToProductCategory2:(UIStoryboardSegue *)segue
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
    _defaultList = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [_defaultList sortedArrayUsingDescriptors:sortDescriptors];
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
        ProductCategory2 *productCategory2 = _defaultList[row];
        cell.textNewLabel.text = productCategory2.name;
        [cell.contentView addSubview:cell.textNewLabel];
        cell.rightButtons = [self createRightButtons:1 indexPath:indexPath];
    }
    else if(section == 1)
    {
        ProductCategory2 *productCategory2 = _newList[row];
        cell.textNewLabel.text = productCategory2.name;
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
        ProductCategory2 *productCategory2Initial = _initialDataList[i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        ProductCategory2 *productCategory2 = _defaultList[i];
        if(cell != nil)
        {
            productCategory2.name = cell.textNewLabel.text;
            if(![productCategory2.name isEqualToString:productCategory2Initial.name])
            {
                productCategory2.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                productCategory2.modifiedUser = [Utility modifiedUser];
            }
        }
    }
    
    //add current data to temp
    //remove all newLabelList
    //add temp data to newlabellist
    [self convertCodeToProductCategory2ID];//table นี้ใช้ code เป็น primary key เลยต้อง copy code ใส่ใน default id อันนี้ทำได้เพราะ code ที่ใช้เป็นตัวเลขเท่านั้น
//    NSInteger nextID = [Utility getNextID:tblProductCategory2];
    NSInteger intNextCode = [[self getNextCode] integerValue];
    NSMutableArray *productCategory2NewList = [[NSMutableArray alloc]init];
    for(int i=0; i<[_newList count]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        ProductCategory2 *productCategory2 = [[ProductCategory2 alloc]init];
        if(cell != nil)
        {
            productCategory2.code = [NSString stringWithFormat:@"%02ld",intNextCode + i];
            productCategory2.name = cell.textNewLabel.text;
        }        
        [productCategory2NewList addObject:productCategory2];
    }
    
    //remove all newLabelList
    //add temp data to newlabellist
    [_newList removeAllObjects];
    [_newList addObjectsFromArray:productCategory2NewList];
}

-(void)convertCodeToProductCategory2ID
{
    for(ProductCategory2 *item in [SharedProductCategory2 sharedProductCategory2].productCategory2List)
    {
        item.productCategory2ID = [item.code integerValue];
    }
}
-(BOOL)productCategory2InUse:(NSString *)code
{
    {
        NSMutableArray *productList = [SharedProduct sharedProduct].productList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",code];
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];

        if([filterArray count]>0)
        {
            return YES;
        }
    }
    {
        NSMutableArray *customMadeList = [SharedCustomMade sharedCustomMade].customMadeList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",code];
        NSArray *filterArray = [customMadeList filteredArrayUsingPredicate:predicate1];
        if([filterArray count]>0)
        {
            return YES;
        }
    }
    {
        //เช็คว่ามี product cat1 อยู่ภายใต้มั๊ย
        NSMutableArray *productCategory1List = [SharedProductCategory1 sharedProductCategory1].productCategory1List;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",code];
        NSArray *filterArray = [productCategory1List filteredArrayUsingPredicate:predicate1];
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
                                                ProductCategory2 *productCategory2 = _defaultList[indexPath.row];
                                                if(![self productCategory2InUse:productCategory2.code])
                                                {
                                                    [_homeModel deleteItems:dbProductCategory2 withData:productCategory2.code];
                                                    
                                                    //update sharedproductcategory2
                                                    [[SharedProductCategory2 sharedProductCategory2].productCategory2List removeObject:productCategory2];
                                                    [_defaultList removeObjectAtIndex:indexPath.row];
                                                }
                                                else
                                                {
                                                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot delete"
                                                                                                                   message:@"This main category is in use"
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
    ProductCategory2 *productCategory2 = [[ProductCategory2 alloc]init];
    productCategory2.name = @"";
    [_newList addObject:productCategory2];
    
    
    //reload table
    [tableViewList reloadData];
}

- (IBAction)doneButtonClicked:(id)sender {
    
    [self updateDefaultAndAddNewData];
    
    
    //prepare data for update
    NSMutableArray *updateList = [[NSMutableArray alloc]init];
    for(int i=0; i<[_defaultList count]; i++)
    {
        ProductCategory2 *productCategory2 = _defaultList[i];
        ProductCategory2 *productCategory2Initial = _initialDataList[i];
        if(![productCategory2.name isEqualToString:productCategory2Initial.name])
        {
            [updateList addObject:productCategory2];
        }
    }

    if([updateList count]>0)
    {
        [_homeModel updateItems:dbProductCategory2 withData:updateList];
    }
    if([_newList count]>0)
    {
        NSMutableArray *blankList = [[NSMutableArray alloc]init];
        for(int i=0; i<[_newList count]; i++)
        {
            ProductCategory2 *productCategory2 = _newList[i];
            if([productCategory2.name isEqualToString:@""])
            {
                [blankList addObject:productCategory2];
            }
        }
        [_newList removeObjectsInArray:blankList];
        
        //update sharedproductcat2
        [[SharedProductCategory2 sharedProductCategory2].productCategory2List addObjectsFromArray:_newList];
        [_homeModel insertItems:dbProductCategory2 withData:_newList];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)getNextCode
{
    //gen next running code
    NSMutableArray *productCategory2List = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2];
//    NSArray *filterArray = [productCategory1List filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_code" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [productCategory2List sortedArrayUsingDescriptors:sortDescriptors];
    productCategory2List = [sortArray mutableCopy];
    
    if([productCategory2List count] == 0)
    {
        return @"1";
    }
    else
    {
        ProductCategory2 *productCategory2 = productCategory2List[0];
        NSInteger number = [productCategory2.code intValue];
        return [NSString stringWithFormat:@"%02ld",number+1];
    }
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
