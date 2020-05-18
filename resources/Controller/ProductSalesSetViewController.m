//
//  ProductSalesSetViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/23/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductSalesSetViewController.h"
#import "Utility.h"
#import "ProductSalesSet.h"
#import "ProductSales.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "ProductSalesViewController.h"
#import "Event.h"
#import "SharedEvent.h"
#import "SharedProductSales.h"
#import "SharedProductSalesSet.h"
#import "SharedPushSync.h"
#import "PushSync.h"

@interface ProductSalesSetViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productSalesSetList;
    NSIndexPath *_selectionIndexPath;
    ProductSalesSet *_productSalesSet;
    NSInteger _itemEditing;
    UITextField *_textEdit;
    NSString *_productSalesSetID;

}

@end

@implementation ProductSalesSetViewController
@synthesize btnCopy;
@synthesize fromEventMenu;
@synthesize productSalesSetID;


- (IBAction)unwindToEventPrice:(UIStoryboardSegue *)segue
{
    
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
    
    
    _itemEditing = -1;
    _textEdit = [[UITextField alloc]init];
    _textEdit.delegate = self;
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    _productSalesSetList = [SharedProductSalesSet sharedProductSalesSet].productSalesSetList;
    _productSalesSetList = [self sortList];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
//    [self.view addGestureRecognizer:tapGesture];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self textFieldShouldReturn:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //update db
    if([[_textEdit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:@"Product sale set cannot be empty"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [_textEdit removeFromSuperview];
        _itemEditing = -1;
        _productSalesSet.productSalesSetName = textField.text;
        [self sortList];
        [self.tableView reloadData];
        
        [_homeModel updateItems:dbProductSalesSet withData:_productSalesSet];
    }
    return NO;
}

- (void)itemsDeleted
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_productSalesSetList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    
    NSInteger item = indexPath.item;
    
    ProductSalesSet *productSalesSet = _productSalesSetList[item];
    
    if(_itemEditing != item)
    {
        cell.textLabel.text = productSalesSet.productSalesSetName;
    }else
    {
        cell.textLabel.text = @"";
    }
    
    if(item != 0)
    {
        cell.rightButtons = [self createRightButtons:2 withData:productSalesSet];
    }
    
    
    
    [cell.doubleTap removeTarget:self action:@selector(showTextBoxToEdit:)];
    [cell.doubleTap addTarget:self action:@selector(showTextBoxToEdit:)];
    cell.doubleTap.numberOfTapsRequired = 2;
    cell.doubleTap.numberOfTouchesRequired = 1;
    cell.tag = item;
    [cell addGestureRecognizer:cell.doubleTap];
    
    return cell;
}

-(void)showTextBoxToEdit:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"double tap");
    UIView* view = gestureRecognizer.view;
    _productSalesSet = _productSalesSetList[view.tag];
    
    
    float controlWidth = self.tableView.bounds.size.width - 15*2;//minus left, right margin
    float controlXOrigin = 15;
    float controlYOrigin = (view.frame.size.height - 25)/2;//table row height minus control height and set vertical center
    
    _textEdit.frame = CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25);
    _textEdit.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    
    _textEdit.text = _productSalesSet.productSalesSetName;
    [UIView animateWithDuration:0.0 animations:^{
        [view addSubview:_textEdit];
    } completion:^(BOOL finished){
        [_textEdit becomeFirstResponder];
    }];
    
    _itemEditing = view.tag;
    [self.tableView reloadData];
}

-(NSArray *) createRightButtons: (int) number withData:(ProductSalesSet *)productSalesSet
{
    NSMutableArray * result = [NSMutableArray array];
    if(number == 1)
    {
        NSString* titles[1] = {@"Edit"};
        UIColor * colors[1] = {[UIColor lightGrayColor]};
        
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[0] backgroundColor:colors[0] callback:^BOOL(MGSwipeTableCell * sender){
            _productSalesSetID = productSalesSet.productSalesSetID;
            [self performSegueWithIdentifier:@"segProductSales" sender:self];

            return YES; //Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    else
    {
        NSString* titles[2] = {@"Delete",@"Edit"};
        UIColor * colors[2] = {[UIColor redColor],[UIColor lightGrayColor]};
        for (int i = 0; i < number; ++i)
        {
            MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
                if(i==0)
                {
                    if([self productSalesSetIsBeingUsed:productSalesSet])
                    {
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning: cannot delete"
                                                                                       message:@"This set is being used"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {}];
                        
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else
                    {
                        int j=0;
                        for(ProductSalesSet *item in _productSalesSetList)
                        {
                            if([item isEqual:productSalesSet])
                            {
                                break;
                            }
                            j++;
                        }
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:0];
                        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                                       message:nil
                                                                                preferredStyle:UIAlertControllerStyleActionSheet];
                        [alert addAction:
                         [UIAlertAction actionWithTitle:@"Delete set"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction *action) {
                                                    [_homeModel deleteItems:dbProductSalesSet withData:productSalesSet];
                                                    [_productSalesSetList removeObject:productSalesSet];
                                                    NSMutableArray *arrDeleteItem = [[NSMutableArray alloc]init];
                                                    for(ProductSales *item in [SharedProductSales sharedProductSales].productSalesList)
                                                    {
                                                        if([item.productSalesSetID isEqualToString:productSalesSet.productSalesSetID])
                                                        {
                                                            [arrDeleteItem addObject:item];
                                                        }
                                                    }
                                                    [[SharedProductSales sharedProductSales].productSalesList removeObjectsInArray:arrDeleteItem];
                                                    
                                                    [self.tableView reloadData];
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
                            popPresenter.sourceView = cell;
                            popPresenter.sourceRect = cell.bounds;
                            //        popPresenter.barButtonItem = _barButtonIpad;
                        }
                        ///////////////
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }
                else
                {
                    _productSalesSetID = productSalesSet.productSalesSetID;
                    [self performSegueWithIdentifier:@"segProductSales" sender:self];
                }
                
                BOOL autoHide = i != 0;
                return autoHide; //Don't autohide in delete button to improve delete expansion animation
            }];
            [result addObject:button];
        }
    }
    
    
    return result;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segProductSales"])
    {
        ProductSalesViewController *vc = segue.destinationViewController;
        
        vc.productSalesSetID = _productSalesSetID;
    }
}
-(BOOL)productSalesSetIsBeingUsed:(ProductSalesSet *)productSalesSet//(NSString *)productSalesSetID
{
    NSString *productSalesSetID = productSalesSet.productSalesSetID;
    for(Event *item in [SharedEvent sharedEvent].eventList)
    {
        if([item.productSalesSetID isEqualToString:productSalesSetID])
        {
            return YES;
        }
    }
    return NO;
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
    [self removeOverlayViews];
    
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

- (NSString *)getNextFileName:(NSString *)fileName
{
    NSInteger i=1;
    NSString *nextFileName = fileName;
    while([self fileNameExist:nextFileName])
    {
        if(i == 1)
        {
            nextFileName = [NSString stringWithFormat:@"%@ %ld",fileName,(long)++i];
        }
        else
        {
            NSString *strOccurence = [NSString stringWithFormat:@" %ld",(long)i];
            NSString *strReplace = [NSString stringWithFormat:@" %ld",(long)++i];
            nextFileName = [nextFileName stringByReplacingOccurrencesOfString:strOccurence withString:strReplace];
        }
    }
    return nextFileName;
}
- (BOOL)fileNameExist:(NSString *)fileName
{
    for(ProductSalesSet *item in _productSalesSetList)
    {
        if([item.productSalesSetName isEqualToString:fileName])
        {
            return YES;
        }
    }
    return NO;
}
- (IBAction)copyProductSalesSet:(id)sender {
    //get selected set
    //copy, rename and insert
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if([selectedRows count] == 0)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"Please select product sales set to copy"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        dispatch_async(dispatch_get_main_queue(),^ {
            [self presentViewController:alert animated:YES completion:nil];
        } );
    }
    else
    {
        NSIndexPath *item = selectedRows[0];
        ProductSalesSet *productSalesSet = _productSalesSetList[item.row];
        
        
        [self loadingOverlayView];
        _productSalesSet = [[ProductSalesSet alloc]init];
        _productSalesSet.productSalesSetID = productSalesSet.productSalesSetID;//productsalessetid -> source
        _productSalesSet.productSalesSetName = [self getNextFileName:productSalesSet.productSalesSetName];//name -> the copy one

        [_homeModel insertItems:dbProductSalesSet withData:_productSalesSet];
    }
}

-(void)removeOverlayViewConnectionFail
{
    [self removeOverlayViews];
    [self connectionFail];
}

- (void)itemsInsertedWithReturnData:(NSMutableArray *)data
{
   
    //update sharedproductsalesset
    NSString *productSalesSetIDCopy;
    if([data count]>0)
    {
        ProductSales *productSales = data[0];
        productSalesSetIDCopy = productSales.productSalesSetID;
    }
    _productSalesSet.productSalesSetID = productSalesSetIDCopy;
    _productSalesSet.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    _productSalesSet.modifiedUser = [Utility modifiedUser];
    [[SharedProductSalesSet sharedProductSalesSet].productSalesSetList addObject:_productSalesSet];
    _productSalesSetList = [SharedProductSalesSet sharedProductSalesSet].productSalesSetList;
    
    
    
    //update shared productsales
    NSMutableArray *productSalesListCopy = [[NSMutableArray alloc]init];
    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
    for(ProductSales *item in data)
    {
        ProductSales *productSales = [[ProductSales alloc]init];
        productSales.productSalesID = item.productSalesID;
        productSales.productSalesSetID = item.productSalesSetID;
        productSales.productNameID = item.productNameID;
        productSales.color = item.color;
        productSales.size = item.size;
        productSales.price = item.price;
        productSales.detail = item.detail;
        productSales.percentDiscountMember = item.percentDiscountMember;
        productSales.percentDiscountFlag = item.percentDiscountFlag;
        productSales.percentDiscount = item.percentDiscount;
        productSales.pricePromotion = item.pricePromotion;
        productSales.shippingFee = item.shippingFee;
        productSales.imageDefault = item.imageDefault;
        productSales.imageID = item.imageID;
        productSales.cost = item.cost;
        productSales.modifiedDate = item.modifiedDate;
        productSales.modifiedUser = [Utility modifiedUser];
        [productSalesListCopy addObject:productSales];
    }

    [productSalesList addObjectsFromArray:productSalesListCopy];
    
    
    _productSalesSetList = [self sortList];
    [self.tableView reloadData];
    [self removeOverlayViews];
}

-(NSMutableArray *)sortList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@",@"0"];
    NSArray *filtered1  = [_productSalesSetList filteredArrayUsingPredicate:predicate1];
    
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"_productSalesSetID != %@",@"0"];
    NSArray *filtered2  = [_productSalesSetList filteredArrayUsingPredicate:predicate2];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productSalesSetName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:NO];
    NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortedArray1 = [filtered2 sortedArrayUsingDescriptors:sortDescriptors1];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    [tempArray addObjectsFromArray:filtered1];
    [tempArray addObjectsFromArray:sortedArray1];
    return tempArray;
}

-(BOOL) stringIsInteger:(NSString *) str {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
    
    if(!!number) //is numeric
    {
        if([number floatValue] != [number intValue])//ถ้า no. เป็น float
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(fromEventMenu)
    {
        productSalesSetID = ((ProductSalesSet *)_productSalesSetList[indexPath.item]).productSalesSetID;        
        [self performSegueWithIdentifier:@"segUnwindToAddEditEvent" sender:self];
    }
}


@end
