//
//  ProductCategory1SelectionViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/15/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductCategory1SelectionViewController.h"
#import "Utility.h"
#import "SharedProductCategory1.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "ProductCategory1.h"
#import "SharedProduct.h"
#import "SharedCustomMade.h"
#import "ProductNameViewController.h"

@interface ProductCategory1SelectionViewController ()
{
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productCategory1List;
    NSMutableArray *_defaultList;
    NSMutableArray *_newList;
    NSMutableArray *_initialDataList;
    NSString *_selectedProductCategory1;
}
@end

@implementation ProductCategory1SelectionViewController
@synthesize tableViewList;
@synthesize productCategory2;

- (IBAction)unwindToProductCategory1Selection:(UIStoryboardSegue *)segue
{
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [tableViewList registerClass:[MGSwipeTableCell class] forCellReuseIdentifier:@"TableViewList"];
}

- (void)loadView
{
    [super loadView];
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
    [tableViewList reloadData];
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_defaultList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: cellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    
    ProductCategory1 *productCategory1 = _defaultList[row];
    cell.textLabel.text = productCategory1.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCategory1 *productCategory1 = _defaultList[indexPath.row];
    _selectedProductCategory1 = productCategory1.code;
    [self performSegueWithIdentifier:@"segProductName" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segProductName"])
    {
        ProductNameViewController *vc = segue.destinationViewController;
        vc.productCategory1 = _selectedProductCategory1;
        vc.productCategory2 = productCategory2;
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
