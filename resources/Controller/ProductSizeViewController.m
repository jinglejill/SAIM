//
//  SizeViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/17/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductSizeViewController.h"
#import "HomeModel.h"
#import "Utility.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "ProductSize.h"
#import "SharedProduct.h"
#import "SharedCustomMade.h"
#import "SharedProductSize.h"
#import "SharedPushSync.h"
#import "PushSync.h"

@interface ProductSizeViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_defaultList;
    NSMutableArray *_newList;
    NSMutableArray *_initialDataList;
    UIBarButtonItem *_blankBarButtonItem;
    BOOL _sortButtonClicked;
}
@end


@implementation ProductSizeViewController
@synthesize tableViewList;
@synthesize btnCancelButton;
@synthesize btnDoneButton;
@synthesize btnSortButton;

- (IBAction)unwindToColor:(UIStoryboardSegue *)segue
{
    
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
    
    
    _blankBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    _sortButtonClicked = NO;
    

    [self loadViewProcess];
}

- (void)loadViewProcess
{
    [self setDefaultList];//section=0 only
}

-(void)setDefaultList
{
    _defaultList = [[NSMutableArray alloc]init];
    _newList = [[NSMutableArray alloc]init];
    _defaultList = [SharedProductSize sharedProductSize].productSizeList;
    for(ProductSize *item in _defaultList)
    {
        item.intSizeOrder = [item.sizeOrder intValue];
    }
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_intSizeOrder" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [_defaultList sortedArrayUsingDescriptors:sortDescriptors];
    _defaultList = [sortArray mutableCopy];
    _initialDataList = [[NSMutableArray alloc] initWithArray:_defaultList copyItems:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _sortButtonClicked?1:2;
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
    if ([cell.costLabel isDescendantOfView:cell]) {
        [cell.costLabel removeFromSuperview];
    }
    
    if(_sortButtonClicked)
    {
        if(section == 0)
        {
            ProductSize *productSize = _defaultList[row];
            cell.costLabel.text = productSize.sizeLabel;
            [cell addSubview:cell.costLabel];
            //            cell.rightButtons = [self createRightButtons:1 indexPath:indexPath];
        }
    }
    else
    {
        if(section == 0)
        {
            ProductSize *productSize = _defaultList[row];
            cell.textNewLabel.text = productSize.sizeLabel;
            [cell.contentView addSubview:cell.textNewLabel];
            cell.rightButtons = [self createRightButtons:1 indexPath:indexPath];
        }
        else if(section == 1)
        {
            ProductSize *productSize = _newList[row];
            cell.textNewLabel.text = productSize.sizeLabel;
            cell.textNewLabel.placeholder = @"New item";
            [cell.contentView addSubview:cell.textNewLabel];
            cell.rightButtons = [self createRightButtons:1 indexPath:indexPath];
        }
    }
    
    
    return cell;
}

-(void)updateDefaultAndAddNewData
{
    //update data in defaultLabelList
    for(int i=0; i<[_defaultList count]; i++)
    {
        ProductSize *productSizeInitial = _initialDataList[i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        ProductSize *productSize = _defaultList[i];
        if(cell != nil)
        {
            productSize.sizeLabel = cell.textNewLabel.text;
            if(![productSize.sizeLabel isEqualToString:productSizeInitial.sizeLabel])
            {
                productSize.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                productSize.modifiedUser = [Utility modifiedUser];
            }
        }
    }
    
    //add current data to temp
    //remove all newLabelList
    //add temp data to newlabellist
    [self convertCodeToProductSizeID];//table นี้ใช้ code เป็น primary key เลยต้อง copy code ใส่ใน default id อันนี้ทำได้เพราะ code ที่ใช้เป็นตัวเลขเท่านั้น
//    NSInteger nextID = [Utility getNextID:tblProductSize];
    NSInteger intNextCode = [[self getNextCode] integerValue];
    NSMutableArray *productSizeNewList = [[NSMutableArray alloc]init];
    for(int i=0; i<[_newList count]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        ProductSize *productSize = [[ProductSize alloc]init];
        if(cell != nil)
        {
            productSize.code = [NSString stringWithFormat:@"%02ld",intNextCode + i];
            productSize.sizeLabel = cell.textNewLabel.text;
        }
        [productSizeNewList addObject:productSize];
    }
    
    //remove all newLabelList
    //add temp data to newlabellist
    [_newList removeAllObjects];
    [_newList addObjectsFromArray:productSizeNewList];
}
- (NSString *)getNextCode
{
    //gen next running code
    NSMutableArray *productSizeList = [SharedProductSize sharedProductSize].productSizeList;
    //    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2];
    //    NSArray *filterArray = [productCategory1List filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_code" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [productSizeList sortedArrayUsingDescriptors:sortDescriptors];
    productSizeList = [sortArray mutableCopy];
    
    if([productSizeList count] == 0)
    {
        return @"1";
    }
    else
    {
        ProductSize *productSize = productSizeList[0];
        NSInteger number = [productSize.code intValue];
        return [NSString stringWithFormat:@"%02ld",number+1];
    }
}
-(void)convertCodeToProductSizeID
{
    for(ProductSize *item in [SharedProductSize sharedProductSize].productSizeList)
    {
        item.productSizeID = [item.code integerValue];
    }
}
-(BOOL)productSizeInUse:(NSString *)code
{
    {
        NSMutableArray *productList = [SharedProduct sharedProduct].productList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_size = %@",code];
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
        
        if([filterArray count]>0)
        {
            return YES;
        }
    }
    {
        NSMutableArray *customMadeList = [SharedCustomMade sharedCustomMade].customMadeList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_size = %@",code];
        NSArray *filterArray = [customMadeList filteredArrayUsingPredicate:predicate1];
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
                                                ProductSize *productSize = _defaultList[indexPath.row];
                                                if(![self productSizeInUse:productSize.code])
                                                {
                                                    [_homeModel deleteItems:dbProductSize withData:productSize];
                                                    
                                                    //update sharedproductsize
                                                    [[SharedProductSize sharedProductSize].productSizeList removeObject:productSize];
                                                    [_defaultList removeObjectAtIndex:indexPath.row];
                                                }
                                                else
                                                {
                                                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot delete"
                                                                                                                   message:@"This size is in use"
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
    ProductSize *productSize = [[ProductSize alloc]init];
    productSize.sizeLabel = @"";
    [_newList addObject:productSize];
    
    
    //reload table
    [tableViewList reloadData];
}

- (IBAction)doneButtonClicked:(id)sender {
    
    [self updateDefaultAndAddNewData];
    [self updateDataInDB];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)updateDataInDB
{
    NSMutableArray *updateList = [[NSMutableArray alloc]init];
    for(int i=0; i<[_defaultList count]; i++)
    {
        ProductSize *productSize = _defaultList[i];
        ProductSize *productSizeInitial = _initialDataList[i];
        if(![productSize.sizeLabel isEqualToString:productSizeInitial.sizeLabel])
        {
            [updateList addObject:productSize];
        }
    }
    
    if([updateList count]>0)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_code" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [updateList sortedArrayUsingDescriptors:sortDescriptors];
        
        float itemsPerConnection = [Utility getNumberOfRowForExecuteSql]+0.0;
        float countUpdate = ceil([sortArray count]/itemsPerConnection);
        for(int i=0; i<countUpdate; i++)
        {
            NSInteger startIndex = i * itemsPerConnection;
            NSInteger count = MIN([sortArray count] - startIndex, itemsPerConnection );
            NSArray *subArray = [sortArray subarrayWithRange: NSMakeRange( startIndex, count )];
            
            [_homeModel updateItems:dbProductSize withData:subArray];
        }
    }
    if([_newList count]>0)
    {
        NSMutableArray *blankList = [[NSMutableArray alloc]init];
        for(int i=0; i<[_newList count]; i++)
        {
            ProductSize *productSize = _newList[i];
            if([productSize.sizeLabel isEqualToString:@""])
            {
                [blankList addObject:productSize];
            }
            else
            {
                productSize.sizeOrder = productSize.code;
            }
        }
        [_newList removeObjectsInArray:blankList];
        
        
        if([_newList count]>0)
        {
            //update sharedproductcat2
            [[SharedProductSize sharedProductSize].productSizeList addObjectsFromArray:_newList];
            [_homeModel insertItems:dbProductSize withData:_newList];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if (indexPath.row == 0) // Don't move the first row
    //        return NO;
    
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    ProductSize *productSizeToMove = [_defaultList objectAtIndex:sourceIndexPath.row];
    [_defaultList removeObjectAtIndex:sourceIndexPath.row];
    [_defaultList insertObject:productSizeToMove atIndex:destinationIndexPath.row];
    
    //update size order
    NSInteger count = 0;
    for(ProductSize *item in _defaultList)
    {
        item.sizeOrder = [NSString stringWithFormat:@"%ld",(long)++count];
    }
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_code" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [_defaultList sortedArrayUsingDescriptors:sortDescriptors];
    
    float itemsPerConnection = [Utility getNumberOfRowForExecuteSql]+0.0;
    float countUpdate = ceil([sortArray count]/itemsPerConnection);
    for(int i=0; i<countUpdate; i++)
    {
        NSInteger startIndex = i * itemsPerConnection;
        NSInteger count = MIN([sortArray count] - startIndex, itemsPerConnection );
        NSArray *subArray = [sortArray subarrayWithRange: NSMakeRange( startIndex, count )];
        
        [_homeModel updateItems:dbProductSize withData:subArray];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (IBAction)sortItem:(id)sender {
    if([btnSortButton.title isEqualToString:@"Sort"])
    {
        //do done button clicked//////////////////////
        [self updateDefaultAndAddNewData];
        [self updateDataInDB];
        [self setDefaultList];//section=0 only
        
        
        btnSortButton.title = @"Back";
        _sortButtonClicked = YES;
        [self.tableViewList reloadData];
        [self.tableView setEditing:YES animated:YES];
        self.navigationController.toolbarHidden = YES;
        
        //hide cancel and done button, change sort button to cancel
        [self.navigationItem setLeftBarButtonItems:@[_blankBarButtonItem]];
        [self.navigationItem setRightBarButtonItems:@[btnSortButton]];
    }
    else
    {
        btnSortButton.title = @"Sort";
        _sortButtonClicked = NO;
        [self.tableViewList reloadData];
        [self.tableView setEditing:NO animated:YES];
        self.navigationController.toolbarHidden = NO;
        
        [self.navigationItem setLeftBarButtonItems:@[btnCancelButton]];
        [self.navigationItem setRightBarButtonItems:@[btnDoneButton,btnSortButton]];
        
        _initialDataList = [[NSMutableArray alloc] initWithArray:_defaultList copyItems:YES];
    }
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
