//
//  ProductCategorySelectionViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 9/1/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductCategorySelectionViewController.h"
#import "APLSectionInfo.h"
#import "APLSectionHeaderView.h"
#import "SharedProductCategory2.h"
#import "ProductCategory2.h"
#import "ProductCategory1.h"
#import "ProductNameViewController.h"

@interface ProductCategorySelectionViewController ()
{
    NSArray *_sectionNameList;
    NSMutableArray *_menuInSectionList;
    NSMutableArray *_infoArray;
    NSIndexPath *_selectedIndexPath;
    NSMutableArray *_productCategory2List;
}

@end
#define DEFAULT_ROW_HEIGHT 88
#define HEADER_HEIGHT 48

static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";

@implementation ProductCategorySelectionViewController
- (IBAction)unwindToProductCategorySelection:(UIStoryboardSegue *)segue
{
    
}
- (void)loadView
{
    [super loadView];
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    _productCategory2List = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [_productCategory2List sortedArrayUsingDescriptors:sortDescriptors];
    _productCategory2List = [sortArray mutableCopy];
    
    _infoArray = [[NSMutableArray alloc] init];
    for(int i=0; i<[_productCategory2List count]; i++)
    {
        ProductCategory2 *productCategory2 = _productCategory2List[i];
        APLSectionInfo *sectionInfo = [[APLSectionInfo alloc] init];
        sectionInfo.sectionName = productCategory2.name;
        sectionInfo.open = NO;
        sectionInfo.menuInSection = [ProductCategory1 getProductCategory1List:productCategory2.code];
        
        NSNumber *defaultRowHeight = @(DEFAULT_ROW_HEIGHT);
        NSInteger countOfMenu = [sectionInfo.menuInSection count];
        for (NSInteger i = 0; i < countOfMenu; i++) {
            [sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
        }
        [_infoArray addObject:sectionInfo];
    }
    self.sectionInfoArray = _infoArray;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.openSectionIndex = NSNotFound;
    
    // Set up default values.
    self.tableView.sectionHeaderHeight = HEADER_HEIGHT;
    
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [self.tableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    static NSString *CellIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    APLSectionInfo *sectionInfo = _infoArray[section];
    NSArray *menuInSection = sectionInfo.menuInSection;
    ProductCategory1 *productCategory1 = menuInSection[item];
    cell.textLabel.text = productCategory1.name;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = @"";

    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    APLSectionHeaderView *sectionHeaderView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
    
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[section];
    sectionInfo.headerView = sectionHeaderView;
    
    sectionHeaderView.titleLabel.text = sectionInfo.sectionName;
    sectionHeaderView.section = section;
    sectionHeaderView.delegate = self;
    
    return sectionHeaderView;
}

#pragma mark - SectionHeaderViewDelegate

- (void)sectionHeaderView:(APLSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
    
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[sectionOpened];
    
    sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo.menuInSection count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
        
        APLSectionInfo *previousOpenSection = (self.sectionInfoArray)[previousOpenSectionIndex];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection.menuInSection count];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    
    // style the animation so that there's a smooth flow in either direction
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }
    
    // apply the updates
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [self.tableView endUpdates];
    
    self.openSectionIndex = sectionOpened;
}

- (void)sectionHeaderView:(APLSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[sectionClosed];
    
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    self.openSectionIndex = NSNotFound;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_sectionInfoArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[section];
    NSInteger numMenuInSection = [sectionInfo.menuInSection count];
    
    return sectionInfo.open ? numMenuInSection : 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"segProductName" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segProductName"])
    {
        NSInteger section = _selectedIndexPath.section;
        NSInteger item = _selectedIndexPath.item;
        APLSectionInfo *sectionInfo = _sectionInfoArray[section];
        NSArray *productCategory1List = sectionInfo.menuInSection;
        ProductNameViewController *vc = segue.destinationViewController;
        vc.productCategory1 = ((ProductCategory1 *)productCategory1List[item]).code;
        vc.productCategory2 = ((ProductCategory2 *)_productCategory2List[section]).code;
    }
}

@end
