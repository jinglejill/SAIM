//
//  ProductNameDetailViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/12/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductNameDetailViewController.h"
#import "CustomUICollectionViewCellButton.h"
#import "Utility.h"
#import "ProductSales.h"
#import "ProductNameDetailEditViewController.h"
#import "CustomUICollectionReusableView.h"
#import "Color.h"
#import "ProductSize.h"
#import "ProductSalesSet.h"
#import "SharedProductSales.h"
#import "SharedProductSalesSet.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import "ProductName.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface ProductNameDetailViewController ()<UISearchBarDelegate>

{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_productNameDetailList;
    NSMutableArray *_mutArrProductNameDetailList;
    NSInteger _selectedIndexPathForRow;
    NSMutableArray *_arrSelectedRow;
    BOOL _selectButtonClicked;
    UIView *_viewUnderline;
    NSMutableArray *_arrProductSales;
    NSInteger _appRunningID;
    NSInteger _insert;
    
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;

@end


static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";

@implementation ProductNameDetailViewController
@synthesize colViewItem;
@synthesize productSalesSetID;
@synthesize btnCancel;
@synthesize btnEdit;
@synthesize btnSelect;
@synthesize btnSelectAll;
@synthesize selectedColorList;
@synthesize selectedSizeList;
@synthesize selectedProductName;

- (IBAction)unwindToProductSales:(UIStoryboardSegue *)segue
{
    ProductNameDetailEditViewController *source = [segue sourceViewController];
    if(source.edit == YES)
    {
        [self.colViewItem reloadData];
    }
}

- (IBAction)cancelAction:(id)sender {
    _selectButtonClicked = NO;
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnSelect]];
    [self.navigationItem setLeftBarButtonItem:nil];
    
    
    for(ProductSales *item in _mutArrProductNameDetailList)
    {
        item.editType = @"0";
    }
    [self setData];
}

- (IBAction)selectAction:(id)sender {
    _selectButtonClicked = YES;
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnCancel, btnEdit]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItem:btnSelectAll];
    btnSelectAll.title = @"Select all";
    btnEdit.title = @"Edit";
    
    
    for(ProductSales *item in _mutArrProductNameDetailList)
    {
        item.editType = @"1";
    }
    [self setData];
}

- (IBAction)editAction:(id)sender {
    
    _arrSelectedRow = [[NSMutableArray alloc]init];
    BOOL valid = NO;
    {
        for(ProductSales *item in _productNameDetailList)
        {
            if([item.editType isEqualToString:@"2"])
            {
                valid = YES;
                break;
            }
        }
        if(!valid)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                           message:@"Please select item to edit"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        for(ProductSales *item in _productNameDetailList)
        {
            if([item.editType isEqualToString:@"2"])
            {
                NSString *strProductSalesID = [NSString stringWithFormat:@"%ld",item.productSalesID];
//                [_arrSelectedRow addObject:strProductSalesID];
                [_arrSelectedRow addObject:item];
            }
        }
    }
    
    [self performSegueWithIdentifier:@"segProductNameDetailEdit" sender:self];
}

- (IBAction)selectAllAction:(id)sender {
    if([btnSelectAll.title isEqualToString:@"Select all"])
    {
        btnSelectAll.title = @"Unselect all";
        for(ProductSales *item in _productNameDetailList)
        {
            item.editType = @"2";
        }

    }
    else
    {
        btnSelectAll.title = @"Select all";
        for(ProductSales *item in _productNameDetailList)
        {
            item.editType = @"1";
        }
    }
    
    //    ทุกตัว select all ก้ให้ show unselect
    //    ทุกตัว unselect all ก้ให้ show select
    //    else select all
    [self updateButtonShowCountSelect];
    
    [colViewItem reloadData];
}
-(void)updateButtonShowCountSelect
{
    NSInteger countSelect = 0;
    NSInteger countUnselect = 0;
    for(ProductSales *item in _productNameDetailList)
    {
        if([item.editType integerValue] == 1)
        {
            countUnselect++;
        }
        else if([item.editType integerValue] == 2)
        {
            countSelect++;
        }
    }
    if(countUnselect == [_productNameDetailList count])
    {
        btnSelectAll.title = @"Select all";
    }
    else if(countSelect == [_productNameDetailList count])
    {
        btnSelectAll.title = @"Unselect all";
    }
    else
    {
        btnSelectAll.title = @"Select all";
    }
    if(countSelect != 0)
    {
        btnEdit.title = [NSString stringWithFormat:@"Edit(%ld)",countSelect];
    }
    else
    {
        btnEdit.title = @"Edit";
    }
}
- (NSString *)getNextAppRunningID
{
    
    return [NSString stringWithFormat:@"A%ld",_appRunningID++];
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
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"Style List"];
    self.dataSourceForSearchResult = [NSArray new];
    self.searchBar.delegate = self;
    
    
    _mutArrProductNameDetailList = [[NSMutableArray alloc]init];
    _arrProductSales = [[NSMutableArray alloc]init];
    _arrSelectedRow = [[NSMutableArray alloc]init];
    _selectButtonClicked = NO;
    _appRunningID = 0;
    
    
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnSelect]];
    [self.navigationItem setLeftBarButtonItem:nil];
    
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    NSMutableArray *productNameDetailList = [SharedProductSales sharedProductSales].productSalesList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@ and _productNameID = %ld",@"0",selectedProductName.productNameID];
    NSArray *filterArray = [productNameDetailList filteredArrayUsingPredicate:predicate1];
    productNameDetailList = [filterArray mutableCopy];
    

    BOOL found = NO;
    NSInteger nextID = [Utility getNextID:tblProductSales];
    NSInteger countID = 0;
    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
    NSMutableArray *insertProductSalesTempList = [[NSMutableArray alloc]init];
    NSMutableArray *insertProductSalesList = [[NSMutableArray alloc]init];
    //list only from selected color and size, and add if not exist
    for(int i=0; i<[selectedColorList count]; i++)
    {
        for(int j=0; j<[selectedSizeList count]; j++)
        {
            found = false;
            Color *color = selectedColorList[i];
            ProductSize *productSize = selectedSizeList[j];
            for(ProductSales *item in productNameDetailList)
            {
                if([item.color isEqualToString:color.code] && [item.size isEqualToString:productSize.code])
                {
                    [_mutArrProductNameDetailList addObject:item];
                    found = YES;
                    break;
                }
            }
            if(!found)
            {
                //set default value to newly added and insert to db include sharedproductsales
                ProductSales *productSales = [[ProductSales alloc]init];
                productSales.productSalesID = nextID-countID++;//nextID+(countID++);
                productSales.productSalesSetID = @"0";
                productSales.productNameID = selectedProductName.productNameID;
                productSales.color = color.code;
                productSales.size = productSize.code;
                productSales.price = @"0";
                productSales.detail = @"";
                productSales.percentDiscountMember = @"10";
                productSales.percentDiscountFlag = @"0";
                productSales.percentDiscount = @"0";
                productSales.pricePromotion = @"0";
                productSales.shippingFee = @"50";
                productSales.imageDefault = @"";
                productSales.imageID = @"-1";
                productSales.modifiedDate = @"";
                productSales.modifiedUser = [Utility modifiedUser];
                productSales.cost = @"0";
                
                
                NSMutableArray *arrProductSales = [[NSMutableArray alloc]init];
                [_mutArrProductNameDetailList addObject:productSales]; //to show only productsalesset = 0 (default)
                [arrProductSales addObject:productSales];//include new productsales from all productsalesset, update in db and shared
                
                
                //copy for other productsalessets (for pricepromotion setting)
                NSMutableArray *productSalesSetList = [SharedProductSalesSet sharedProductSalesSet].productSalesSetList;
                for(ProductSalesSet *item in productSalesSetList)
                {
                    if(![item.productSalesSetID isEqualToString:@"0"])
                    {
                        ProductSales *productSalesOther = [self copyProductSales:productSales withSetID:item.productSalesSetID];
                        productSalesOther.productSalesID = nextID-(countID++);//nextID+(countID++);
                        [arrProductSales addObject:productSalesOther];
                    }
                }

                
                for(ProductSales *item in arrProductSales)
                {
                    item.modifiedUser = [Utility modifiedUser];
                    item.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                    
                    
                    
                    [insertProductSalesTempList addObject:item];
                    if([insertProductSalesTempList count] == [Utility getNumberOfRowForExecuteSql])
                    {
                        insertProductSalesList = [NSMutableArray arrayWithArray:insertProductSalesTempList];
                        [insertProductSalesTempList removeAllObjects];
                        [_homeModel insertItems:dbProductSales withData:insertProductSalesList];
                        [self loadingOverlayView];
                        _insert = 1;
                        
//                        //update sharedproductsales
//                        [productSalesList addObjectsFromArray:insertProductSalesList];
                    }
                }
            }
        }
    }
    if([insertProductSalesTempList count] > 0)
    {
        insertProductSalesList = [NSMutableArray arrayWithArray:insertProductSalesTempList];
        [insertProductSalesTempList removeAllObjects];
        [_homeModel insertItems:dbProductSales withData:insertProductSalesList];
        [self loadingOverlayView];
        _insert = 1;
        
        
//        //update sharedproductsales
//        [productSalesList addObjectsFromArray:insertProductSalesList];
    }
    
    
    
    
    //delete what is not in the selected color
    for(ProductSales *item in productNameDetailList)
    {
        found = NO;
        for(int i=0; i<[selectedColorList count]; i++)
        {
            Color *color = selectedColorList[i];
            if([item.color isEqualToString:color.code])
            {
                found = YES;
                break;
            }
        }
        if(!found)
        {
            //remove from productsales db include shared for all productsalessetid
            for(ProductSales *item in productSalesList)
            {
                ProductName *productName = [ProductName getProductName:item.productNameID];
                item.productCategory2 = productName.productCategory2;
                item.productCategory1 = productName.productCategory1;
                item.productName = productName.code;
            }
            //ลบ สำหรับทุก productsalesset
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@", selectedProductName.productCategory2,selectedProductName.productCategory1,selectedProductName.code,item.color];
            NSArray *arrFilter = [productSalesList filteredArrayUsingPredicate:predicate1];
            
            
            //remove in db
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productSalesID" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
            NSArray *sortArray = [arrFilter sortedArrayUsingDescriptors:sortDescriptors];
            
            float itemsPerConnection = [Utility getNumberOfRowForExecuteSql]+0.0;
            float countUpdate = ceil([sortArray count]/itemsPerConnection);
            for(int i=0; i<countUpdate; i++)
            {
                NSInteger startIndex = i * itemsPerConnection;
                NSInteger count = MIN([sortArray count] - startIndex, itemsPerConnection );
                NSArray *subArray = [sortArray subarrayWithRange: NSMakeRange( startIndex, count )];
                
                [_homeModel deleteItems:dbProductSales withData:subArray];
                
                //remove from shared
                [productSalesList removeObjectsInArray:subArray];
            }
        }
    }
    
    
    
    //delete what is not in the selected size
    for(ProductSales *item in productNameDetailList)
    {
        found = false;
        for(int i=0; i<[selectedSizeList count]; i++)
        {
            ProductSize *productSize = selectedSizeList[i];
            if([item.size isEqualToString:productSize.code])
            {
                found = YES;
                break;
            }
        }
        if(!found)
        {
            //remove from productsales db include shared for all productsalessetid
            NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
            for(ProductSales *item in productSalesList)
            {
                ProductName *productName = [ProductName getProductName:item.productNameID];
                item.productCategory2 = productName.productCategory2;
                item.productCategory1 = productName.productCategory1;
                item.productName = productName.code;
            }
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _size = %@", selectedProductName.productCategory2,selectedProductName.productCategory1,selectedProductName.code,item.size];
            NSArray *arrFilter = [productSalesList filteredArrayUsingPredicate:predicate1];
            
            
            //remove in db
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productSalesID" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
            NSArray *sortArray = [arrFilter sortedArrayUsingDescriptors:sortDescriptors];
            
            float itemsPerConnection = [Utility getNumberOfRowForExecuteSql]+0.0;
            float countUpdate = ceil([sortArray count]/itemsPerConnection);
            for(int i=0; i<countUpdate; i++)
            {
                NSInteger startIndex = i * itemsPerConnection;
                NSInteger count = MIN([sortArray count] - startIndex, itemsPerConnection );
                NSArray *subArray = [sortArray subarrayWithRange: NSMakeRange( startIndex, count )];
                
                [_homeModel deleteItems:dbProductSales withData:subArray];
                
                //remove from shared
                [productSalesList removeObjectsInArray:subArray];
            }
        }
    }
    
    
    if(!_insert)
    {
        for(ProductSales *item in _mutArrProductNameDetailList)
        {
            item.editType = @"0";
            item.colorText = [Utility getColorName:item.color];
            item.sizeText = [Utility getSizeLabel:item.size];
            item.sizeOrder = [Utility getSizeOrder:item.size];
        }
        
        
        [self setData];
    }
    
}

-(void)setData
{
    if(self.searchBarActive)
    {
        _productNameDetailList = self.dataSourceForSearchResult;
    }
    else
    {
        _productNameDetailList = _mutArrProductNameDetailList;
    }
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_colorText" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_sizeOrder" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortArray = [_productNameDetailList sortedArrayUsingDescriptors:sortDescriptors];
    _productNameDetailList = [sortArray mutableCopy];
    
    
    //run row no
    int i=0;
    for(ProductSales *item in _productNameDetailList)
    {
        i +=1;
        item.row = [NSString stringWithFormat:@"%d", i];
    }
    
    [colViewItem reloadData];
}
- (ProductSales *)copyProductSales:(ProductSales *)productSales withSetID:(NSString *)productSalesSetID
{
    ProductSales *item = [[ProductSales alloc]init];

    item.productSalesID = 0;
    item.productSalesSetID = productSalesSetID;
    item.productNameID = productSales.productNameID;
    item.color = productSales.color;
    item.size = productSales.size;
    item.price = productSales.price;
    item.detail = productSales.detail;
    item.percentDiscountMember = productSales.percentDiscountMember;
    item.percentDiscountFlag = productSales.percentDiscountFlag;
    item.percentDiscount = productSales.percentDiscount;
    item.pricePromotion = productSales.pricePromotion;
    item.shippingFee = productSales.shippingFee;
    item.imageDefault = productSales.imageDefault;
    item.imageID = productSales.imageID;
    item.modifiedDate = @"";
    item.modifiedUser = [Utility modifiedUser];
    item.cost = productSales.cost;
    return item;
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Register cell classes
    [colViewItem registerClass:[CustomUICollectionViewCellButton class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewItem.delegate = self;
    colViewItem.dataSource = self;
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger rowNo;
    
    if (self.searchBarActive)
    {
        rowNo = self.dataSourceForSearchResult.count;
    }
    else
    {
        rowNo = [_productNameDetailList count];
    }
    
    
    NSInteger countColumn = 5;
    return (rowNo+1)*countColumn;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomUICollectionViewCellButton *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell.label isDescendantOfView:cell]) {
        [cell.label removeFromSuperview];
    }
    
    if ([cell.imageView isDescendantOfView:cell]) {
        [cell.imageView removeFromSuperview];
    }
    if ([cell.leftBorder isDescendantOfView:cell]) {
        [cell.leftBorder removeFromSuperview];
        [cell.topBorder removeFromSuperview];
        [cell.rightBorder removeFromSuperview];
        [cell.bottomBorder removeFromSuperview];
    }
    
    //cell border
    {
        cell.leftBorder.frame = CGRectMake(cell.bounds.origin.x
                                           , cell.bounds.origin.y, 1, cell.bounds.size.height);
        cell.topBorder.frame = CGRectMake(cell.bounds.origin.x
                                          , cell.bounds.origin.y, cell.bounds.size.width, 1);
        cell.rightBorder.frame = CGRectMake(cell.bounds.origin.x+cell.bounds.size.width
                                            , cell.bounds.origin.y, 1, cell.bounds.size.height);
        cell.bottomBorder.frame = CGRectMake(cell.bounds.origin.x
                                             , cell.bounds.origin.y+cell.bounds.size.height, cell.bounds.size.width, 1);
    }
    
    NSInteger item = indexPath.item;
    NSArray *header;
    if (_selectButtonClicked)
    {
        header = @[@"SEL",@"No.",@"Color",@"Size",@"Price"];
    }
    else
    {
        header = @[@"Edit",@"No.",@"Color",@"Size",@"Price"];
    }
    
    NSInteger countColumn = [header count];
    
    if(item/countColumn == 0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    else if(item%countColumn == 2)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentLeft;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item%countColumn == 1 || item%countColumn == 4)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentRight;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item%countColumn == 3)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentCenter;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    

    if(item/countColumn == 0)
    {
        NSInteger remainder = item%countColumn;
        cell.label.text = header[remainder];
    }
    else
    {
        ProductSales *productSales = _productNameDetailList[item/countColumn-1];
        switch (item%countColumn) {
            case 0:
            {
                cell.imageView.userInteractionEnabled = YES;
                [cell addSubview:cell.imageView];
                
                CGRect frame = cell.bounds;
                NSInteger imageSize = 26;
                frame.origin.x = (frame.size.width-imageSize)/2;
                frame.origin.y = (frame.size.height-imageSize)/2;
                frame.size.width = imageSize;
                frame.size.height = imageSize;
                cell.imageView.frame = frame;
                cell.imageView.tag = item;
                
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell.imageView addGestureRecognizer:cell.singleTap];
                
                
                if([productSales.editType isEqualToString:@"0"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"edit2.png"];
                    [cell.singleTap removeTarget:self action:@selector(editPricePromotion:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(editPricePromotion:)];
                }
                else if([productSales.editType isEqualToString:@"1"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"unselect.png"];
                    [cell.singleTap removeTarget:self action:@selector(editPricePromotion:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(selectRow:)];
                }
                else if([productSales.editType isEqualToString:@"2"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"select.png"];
                    [cell.singleTap removeTarget:self action:@selector(editPricePromotion:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(selectRow:)];
                }
                
                [cell addSubview:cell.leftBorder];
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.rightBorder];
                [cell addSubview:cell.bottomBorder];
            }
                break;
            case 1:
            {
                cell.label.text = productSales.row;
            }
                break;
            case 2:
            {
                cell.label.text = productSales.colorText;
            }
                break;
            case 3:
            {
                cell.label.text = productSales.sizeText;
            }
                break;
            case 4:
            {
                NSString *strPrice = productSales.price;
                cell.label.text = [Utility formatBaht:strPrice withMinFraction:0 andMaxFraction:0];
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}


- (void) editPricePromotion:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 5;
    UIView* view = gestureRecognizer.view;
    _selectedIndexPathForRow = view.tag;
    
    ProductSales *productSales = _productNameDetailList[_selectedIndexPathForRow/countColumn-1];
    NSString *strProductSalesID = [NSString stringWithFormat:@"%ld",productSales.productSalesID];
    _arrSelectedRow = [[NSMutableArray alloc]init];
    [_arrSelectedRow addObject:productSales];
//    [_arrSelectedRow addObject:strProductSalesID];
    
    
    [self performSegueWithIdentifier:@"segProductNameDetailEdit" sender:self];
}
- (void) selectRow:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 5;
    UIView* view = gestureRecognizer.view;
    
    _selectedIndexPathForRow = view.tag;
    ProductSales *productSales = _productNameDetailList[_selectedIndexPathForRow/countColumn-1];
    
    if([productSales.editType isEqualToString:@"1"])
    {
        productSales.editType = @"2";
    }
    else if([productSales.editType isEqualToString:@"2"])
    {
        productSales.editType = @"1";
    }
    
    //    ทุกตัว select all ก้ให้ show unselect
    //    ทุกตัว unselect all ก้ให้ show select
    //    else select all
    [self updateButtonShowCountSelect];
    [colViewItem reloadData];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segProductNameDetailEdit"])
    {
        ProductNameDetailEditViewController *vc = segue.destinationViewController;
        
        vc.arrProductSalesID = _arrSelectedRow;
        vc.productNameDetailList = _productNameDetailList;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    @[@"Select",@"No.",@"Item",@"Color",@"Price",@"Price promotion"];
    
    
    CGFloat width;
    NSArray *arrSize = @[@30,@26,@0,@60,@60];
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewItem.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
        width -= 1;
    }
    
    
    CGSize size = CGSizeMake(width, 30);
    return size;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.colViewItem.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewItem reloadData];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 20, 1);//top, left, bottom, right -> collection view
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CustomUICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        
        CGRect frame = headerView.bounds;
        headerView.label.frame = frame;
        headerView.label.textAlignment = NSTextAlignmentLeft;
        headerView.label.text = selectedProductName.name;
        headerView.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [headerView addSubview:headerView.label];
        
        CGRect frame2 = headerView.bounds;
        //        frame2.size.width = frame2.size.width - 20;
        headerView.labelAlignRight.frame = frame2;
        headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
        NSString *strCountItem = [NSString stringWithFormat:@"%ld",self.searchBarActive?self.dataSourceForSearchResult.count:[_productNameDetailList count]];
        strCountItem = [Utility formatBaht:strCountItem];
        headerView.labelAlignRight.text = strCountItem;
        [headerView addSubview:headerView.labelAlignRight];
        [self setLabelUnderline:headerView.labelAlignRight underline:headerView.viewUnderline];
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(UILabel *)setLabelUnderline:(UILabel *)label underline:(UIView *)viewUnderline
{
    //    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
    CGRect expectedLabelSize = [label.text boundingRectWithSize:label.frame.size
                                                        options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                                     attributes:@{NSFontAttributeName:label.font}
                                                        context:nil];
    CGFloat xOrigin=0;
    switch (label.textAlignment) {
        case NSTextAlignmentCenter:
            xOrigin=(label.frame.size.width - expectedLabelSize.size.width)/2;
            break;
        case NSTextAlignmentLeft:
            xOrigin=0;
            break;
        case NSTextAlignmentRight:
            xOrigin=label.frame.size.width - expectedLabelSize.size.width;
            break;
        default:
            break;
    }
    viewUnderline.frame=CGRectMake(xOrigin,
                                   expectedLabelSize.size.height-1,
                                   expectedLabelSize.size.width,
                                   1);
    viewUnderline.backgroundColor=label.textColor;
    [label addSubview:viewUnderline];
    return label;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section { 
    
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 20);
    return headerSize;
}
#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"_colorText contains[c] %@ || _sizeText contains[c] %@ || _price contains[c] %@", searchText,searchText,searchText];
    self.dataSourceForSearchResult  = [_mutArrProductNameDetailList filteredArrayUsingPredicate:resultPredicate];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
    if (searchText.length>0)
    {
        // search and reload data source
        self.searchBarActive = YES;
        [self filterContentForSearchText:searchText scope:@""];
        [self setData];
    }
    else{
        // if text lenght == 0
        // we will consider the searchbar is not active
        //        self.searchBarActive = NO;
        
        [self cancelSearching];
        [self setData];
    }
    
//    BOOL editOrSelect = NO;;
//    if([_productNameDetailList count]>0)
//    {
//        ProductSales *productSales = _productNameDetailList[0];
//        editOrSelect = [productSales.editType integerValue]==0;
//    }
//    if(editOrSelect)
//    {
//        return;
//    }
    if(!_selectButtonClicked)
    {
        return;
    }
    
    
    //    ถ้า select all แล้ว narrow search ให้เคลียร์อันที่หลุดออกไป
    //    ถ้า select all แล้ว wider search ไม่ต้องทำไร
    //copy selected row ออกมา
    //clear เป็น o
    //เอา selected row ใส่คืน
    NSMutableArray *copySelectedList = [[NSMutableArray alloc]init];
    for(ProductSales *item in _productNameDetailList)
    {
        if([item.editType integerValue] == 2)
        {
            [copySelectedList addObject:item];
        }
    }
    
    BOOL match;
    for(ProductSales *item in _mutArrProductNameDetailList)
    {
        match = NO;
        for(ProductSales *copyItem in copySelectedList)
        {
            if(item.productSalesID == copyItem.productSalesID)
            {
                match = YES;
                item.editType = @"2";
                break;
            }
        }
        if(!match)
        {
            item.editType = @"1";
        }
    }
    
    //    ทุกตัว select all ก้ให้ show unselect
    //    ทุกตัว unselect all ก้ให้ show select
    //    else select all
    [self updateButtonShowCountSelect];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [self setData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchBarActive = YES;
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
//    self.searchBarActive = NO;
    [self.searchBar setShowsCancelButton:NO animated:YES];
}
-(void)cancelSearching{
    self.searchBarActive = NO;
    [self.searchBar resignFirstResponder];
    self.searchBar.text  = @"";
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

-(void)itemsInsertedWithReturnData:(NSArray *)items
{
    _insert = 0;
    [self removeOverlayViews];
    [ProductSales addProductSalesList:[items[0] mutableCopy]];
    
    
    
    NSMutableArray *productNameDetailList = [SharedProductSales sharedProductSales].productSalesList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@ and _productNameID = %ld",@"0",selectedProductName.productNameID];
    NSArray *filterArray = [productNameDetailList filteredArrayUsingPredicate:predicate1];
    _mutArrProductNameDetailList = [filterArray mutableCopy];
    
    
    
    for(ProductSales *item in _mutArrProductNameDetailList)
    {
        item.editType = @"0";
        item.colorText = [Utility getColorName:item.color];
        item.sizeText = [Utility getSizeLabel:item.size];
        item.sizeOrder = [Utility getSizeOrder:item.size];
    }
    
    [self setData];
}
@end
