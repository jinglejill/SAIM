//
//  ProductSettingColorAndSizeViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/8/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductSettingColorAndSizeViewController.h"
#import "Utility.h"
#import "SharedColor.h"
#import "Color.h"
#import "SharedProductSize.h"
#import "ProductSize.h"
#import "SharedProductSales.h"
#import "ProductSales.h"
#import "ProductNameDetailViewController.h"
#import "Product.h"
#import "SharedProduct.h"

#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor         [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface ProductSettingColorAndSizeViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_colorList;
    NSMutableArray *_productSizeList;
    NSMutableArray *_selectedColorList;
    NSMutableArray *_selectedSizeList;
}
@end

@implementation ProductSettingColorAndSizeViewController
@synthesize productName;


- (IBAction)unwindToProductSettingColorAndSize:(UIStoryboardSegue *)segue
{

}

-(void)setColorAndSize
{
    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@ and _productNameID = %ld",@"0",productName.productNameID];
    NSArray *arrFilter = [productSalesList filteredArrayUsingPredicate:predicate1];
    
    //color
    NSSet *uniqueColor = [NSSet setWithArray:[arrFilter valueForKey:@"color"]];
    for(NSString *color in uniqueColor) {
        for(int i=0; i<[_colorList count]; i++)
        {
            Color *item = _colorList[i];
            if([color isEqualToString:item.code])
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                break;
            }
        }
    }
    
    //size
    NSSet *uniqueSize = [NSSet setWithArray:[arrFilter valueForKey:@"size"]];
    for(NSString *size in uniqueSize) {
        for(int i=0; i<[_productSizeList count]; i++)
        {
            ProductSize *item = _productSizeList[i];
            if([size isEqualToString:item.code])
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:2];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                break;
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)loadView
{
    [super loadView];
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    _selectedColorList = [[NSMutableArray alloc]init];
    _selectedSizeList = [[NSMutableArray alloc]init];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    
    {
        //color list
        _colorList = [SharedColor sharedColor].colorList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_code != %@",@"00"];
        NSArray *filterArray = [_colorList filteredArrayUsingPredicate:predicate1];
        _colorList = [filterArray mutableCopy];
        
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [_colorList sortedArrayUsingDescriptors:sortDescriptors];
        _colorList = [sortArray mutableCopy];
        
    }
    
    {
        //size list
        _productSizeList = [SharedProductSize sharedProductSize].productSizeList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_code != %@",@"00"];
        NSArray *filterArray = [_productSizeList filteredArrayUsingPredicate:predicate1];
        _productSizeList = [filterArray mutableCopy];
        
        
        for(ProductSize *item in _productSizeList)
        {
            item.intSizeOrder = [item.sizeOrder intValue];
        }
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_intSizeOrder" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [_productSizeList sortedArrayUsingDescriptors:sortDescriptors];
        _productSizeList = [sortArray mutableCopy];
    }
    
    //product list
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@",productName.productCategory2,productName.productCategory1,productName.code];
    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
    
    
    //color
    NSSet *uniqueColor = [NSSet setWithArray:[filterArray valueForKey:@"color"]];
    for(Color *item in _colorList)
    {
        if([uniqueColor containsObject: item.code])
        {
            item.beingUsed = YES;
        }
        else
        {
            item.beingUsed = NO;
        }
    }
    
    
    
    //size
    NSSet *uniqueSize = [NSSet setWithArray:[filterArray valueForKey:@"size"]];
    for(ProductSize *item in _productSizeList)
    {
        if([uniqueSize containsObject: item.code])
        {
            item.beingUsed = YES;
        }
        else
        {
            item.beingUsed = NO;
        }
    }

    
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self setColorAndSize];
    } );
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL allowEdit = NO;
    if(indexPath.section == 1 || indexPath.section == 2)
    {
        allowEdit = YES;
    }
    return allowEdit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 1?[_colorList count]:section == 2?[_productSizeList count]:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    
    NSInteger section = indexPath.section;
    if(section == 0)
    {
        cell.textLabel.text = productName.name;
        cell.textLabel.enabled = YES;
    }
    else if(section == 1)
    {
        Color *color = _colorList[indexPath.item];
        cell.textLabel.text = color.name;
        
        
        //check if it is in used, if yes disable cell unselect
        if(color.beingUsed)
        {
            cell.textLabel.enabled = NO;
        }
        else
        {
            cell.textLabel.enabled = YES;
        }
    }
    else if(section == 2)
    {
        ProductSize *productSize = _productSizeList[indexPath.item];
        cell.textLabel.text = productSize.sizeLabel;
        
        
        //check if it is in used, if yes disable cell unselect
        if(productSize.beingUsed)
        {
            cell.textLabel.enabled = NO;
        }
        else
        {
            cell.textLabel.enabled = YES;
        }
    }
    

    return cell;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if(section == 1)
    {
        Color *color = _colorList[indexPath.item];
        if(color.beingUsed)
        {
            [self alertMsg:@"This style's color is being used"];
            return NO;
        }
    }
    else if(section == 2)
    {
        ProductSize *productSize = _productSizeList[indexPath.item];
        if(productSize.beingUsed)
        {
            [self alertMsg:@"This style's size is being used"];
            return NO;
        }
    }
    
    return YES;
}

- (void)alertMsg:(NSString *)msg
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot unselect"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIColor *color = tBlueColor;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:color];
    
    
    UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(8, 0, 300, 20)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    titleLabel.text = section == 0?@"Style":section == 1?@"Color":@"Size";
    titleLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if(section == 0)
    {
        switch (indexPath.row) {
            case 0:
            {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
                break;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (void)itemsInserted
{

}

- (void)itemsDeleted
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
- (IBAction)doneButtonClicked:(id)sender {
    
    //send color and size to display in productname detail page
    //if exist show, if not show default value
    
    
    [_selectedColorList removeAllObjects];
    [_selectedSizeList removeAllObjects];
    
    
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    for(NSIndexPath *item in selectedRows)
    {
        if(item.section == 1)
        {
            Color *color = _colorList[item.row];
            [_selectedColorList addObject:color];
        }
        else if(item.section == 2)
        {
            ProductSize *productSize = _productSizeList[item.row];
            [_selectedSizeList addObject:productSize];
        }
    }
    [self performSegueWithIdentifier:@"segProductNameDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segProductNameDetail"])
    {
        ProductNameDetailViewController *vc = segue.destinationViewController;
        vc.selectedColorList = _selectedColorList;
        vc.selectedSizeList = _selectedSizeList;
        vc.selectedProductName = productName;
    }
}
- (IBAction)backButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"segUnwindToProductName" sender:self];
}
@end
