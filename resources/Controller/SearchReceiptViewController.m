//
//  SearchReceiptViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 7/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//


#import "SearchReceiptViewController.h"
#import "AddEditPostCustomerViewController.h"
#import "ProductDetailViewController.h"
#import "CustomTableViewCellReceipt.h"
#import "CustomTableViewCellReceiptProductItem.h"
#import "ItemTrackingNo.h"
#import "SharedReplaceReceiptProductItem.h"
#import "SharedPostBuy.h"
#import "SharedProductBuy.h"
#import "SharedRewardPoint.h"
#import "RewardPoint.h"
#import "Message.h"

#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface SearchReceiptViewController ()
{
    NSMutableArray *_receiptListForDate;
    NSMutableArray *_receiptProductItemListForDate;
    NSMutableArray *_productListForDate;
    NSMutableArray *_customMadeListForDate;
    NSMutableArray *_itemTrackingNoListForDate;
    NSMutableArray *_postCustomerListForDate;
    NSMutableArray *_eventListForDate;
    
    NSMutableArray *_receiptList;
    NSMutableArray *_receiptProductItemList;
    NSMutableArray *_selectedReceiptProductItemList;
    PostCustomer *_selectedPostCustomer;
    
    NSString *_selectedReceiptID;
}
@end

static NSString * const reuseIdentifierReceipt = @"CustomTableViewCellReceipt";
static NSString * const reuseIdentifierReceiptProductItem = @"CustomTableViewCellReceiptProductItem";

@implementation SearchReceiptViewController
@synthesize txtSearchText;
@synthesize tbvData;
@synthesize segConSearchBy;


- (IBAction)unwindToSearchReceipt:(UIStoryboardSegue *)segue
{
    if([segue.sourceViewController isMemberOfClass:[AddEditPostCustomerViewController class]])
    {
        if([[segue identifier] isEqualToString:@"segUnwindToSearchReceipt"])
        {
            AddEditPostCustomerViewController *vc = segue.sourceViewController;
            if(vc.selectedPostCustomer)
            {
                PostCustomer *postCustomer = [self getPostCustomer:vc.selectedPostCustomer.postCustomerID];
                if(postCustomer)
                {
                    [_postCustomerListForDate removeObject:postCustomer];
                }
                [_postCustomerListForDate addObject: vc.selectedPostCustomer];
                            
                
                for(ReceiptProductItem *item in _selectedReceiptProductItemList)
                {
                    ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:item.receiptProductItemID];
                    itemTrackingNo.postCustomerID = vc.selectedPostCustomer.postCustomerID;
                }
                [self setData];
            }
        }
        else if([[segue identifier] isEqualToString:@"segUnwindToSearchReceiptCancel"])
        {
            [self setData];
        }
        else if([[segue identifier] isEqualToString:@"segUnwindToSearchReceiptDelete"])
        {
            for(ReceiptProductItem *item in _selectedReceiptProductItemList)
            {
                ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:item.receiptProductItemID];
                itemTrackingNo.postCustomerID = 0;
            }
            [self setData];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Register table
    tbvData.delegate = self;
    tbvData.dataSource = self;
    tbvData.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierReceipt bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierReceipt];
    }
    
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    
    if(self.homeModel.propCurrentDB == dbReceiptSearch)
    {
        int i=0;
        
        _receiptListForDate = items[i++];
        _receiptProductItemListForDate = items[i++];
        _productListForDate = items[i++];
        _customMadeListForDate = items[i++];
        _itemTrackingNoListForDate = items[i++];
        _postCustomerListForDate = items[i++];
        _eventListForDate = items[i++];
        
        [self setData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == tbvData)
    {
        return [_receiptListForDate count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        return 1;
    }
    else
    {
        return [[self getReceiptProductItemList:tableView.tag] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbvData)
    {
        CustomTableViewCellReceipt *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierReceipt];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        Receipt *receipt = _receiptListForDate[indexPath.section];
        NSString *receiptTime = [Utility formatDate:receipt.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yy-MM-dd HH:mm"];
        cell.lblReceiptLabel.text = [NSString stringWithFormat:@"%ld. Receipt",indexPath.section+1];
        [cell.lblReceiptLabel sizeToFit];
        cell.lblReceiptLabelWidth.constant = cell.lblReceiptLabel.frame.size.width;
        
        
        NSString *receiptNoID = [NSString stringWithFormat:@"#%@ (%@)",receipt.receiptNoID,receiptTime];
        [cell.btnReceipt setTitle:receiptNoID forState:UIControlStateNormal];

        
        cell.lblCash.text = [receipt.cashAmount isEqualToString:@"0"]?@"-":[Utility formatBaht:receipt.cashAmount];
        cell.lblCredit.text = [receipt.creditAmount isEqualToString:@"0"]?@"-":[Utility formatBaht:receipt.creditAmount];
        cell.lblTransfer.text = [receipt.transferAmount isEqualToString:@"0"]?@"-":[Utility formatBaht:receipt.transferAmount];
        
        cell.lblTotal.text = [Utility formatBaht:receipt.total];
        cell.lblShippingFee.text = [Utility formatBaht:receipt.shippingFee];
        
        
        //discountValue
        float discountValue = 0;
        NSString *strDiscountValue = @"";
        NSString *strDiscountLabel = @"Discount";
        if([receipt.discount isEqualToString:@"1"])//baht
        {
            discountValue = [receipt.discountValue floatValue];
        }
        else if([receipt.discount isEqualToString:@"2"])//percent
        {
            discountValue = [receipt.discountPercent floatValue]*[receipt.total floatValue]/100;
            strDiscountLabel = [NSString stringWithFormat:@"Disc (%@\uFF05)",receipt.discountPercent];
        }
        strDiscountValue = [NSString stringWithFormat:@"%f",discountValue];
        
        NSString *minusSign = discountValue > 0?@"-":@"";
        cell.lblDiscount.text = [NSString stringWithFormat:@"%@%@",minusSign,[Utility formatBaht:strDiscountValue]];
        
        
        cell.lblAfterDiscount.text = [Utility formatBaht:receipt.payPrice];
        
        
        //redeemed value
        if(receipt.redeemedValue > 0)
        {
            NSString *strRedeemedValue = [NSString stringWithFormat:@"%f",receipt.redeemedValue];
            cell.lblRedeemedValue.text = [NSString stringWithFormat:@"-%@",[Utility formatBaht:strRedeemedValue]];
            
            cell.lblRedeemedValueTop.constant = 2;
            cell.lblRedeemedValueHeight.constant = 17;
            cell.lblRedeemedValueLabelHeight.constant = 17;
        }
        else
        {
            cell.lblRedeemedValueTop.constant = 0;
            cell.lblRedeemedValueHeight.constant = 0;
            cell.lblRedeemedValueLabelHeight.constant = 0;
        }
        
        //after discount
        cell.lblAfterDiscount.text = [Utility formatBaht:receipt.payPrice];
        cell.lblEarnedPointDot.hidden = receipt.earnedPoints > 0?NO:YES;
        
        
        
        //discountReason
        NSArray *receiptProductItemList = [self getReceiptProductItemList:receipt.receiptID];
        NSString *strDiscountReason = @"";
        for(ReceiptProductItem *item in receiptProductItemList)
        {
            if([Utility isStringEmpty:strDiscountReason])
            {
                strDiscountReason = [NSString stringWithFormat:@"%@",item.discountReason];
            }
            else
            {
                strDiscountReason = [NSString stringWithFormat:@"%@,%@",strDiscountReason,item.discountReason];
            }
        }
        cell.lblDiscountReason.text = strDiscountReason;
        if(![Utility isStringEmpty:strDiscountReason])
        {
            [cell.lblDiscountReason sizeToFit];
            cell.lblDiscountReasonHeight.constant = cell.lblDiscountReason.frame.size.height;
        }
        
        
        
        //remark
        cell.txtRemark.text = receipt.remark;
        cell.txtRemark.tag = receipt.receiptID;
        cell.txtRemark.delegate = self;
        
        
        //tbvData for receiptProductItem
        cell.tbvData.tag = receipt.receiptID;
        
        
        //Register table
        cell.tbvData.delegate = self;
        cell.tbvData.dataSource = self;
        
        {
            UINib *nib = [UINib nibWithNibName:reuseIdentifierReceiptProductItem bundle:nil];
            [cell.tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierReceiptProductItem];
        }
        {
            NSArray *receiptProductItemList = [self getReceiptProductItemList:receipt.receiptID];
            float tableViewHeight = [receiptProductItemList count]*30;
            cell.tbvDataHeight.constant = tableViewHeight;
            [cell.tbvData reloadData];
        }
        
        

        //button for delivery address
        cell.btnPostCustomer.tag = receipt.receiptID;
        
        
        
        if([self hasPost:receipt.receiptID])
        {
            cell.btnPostCustomer.imageView.image = [UIImage imageNamed:@"postCustomer2.png"];
            [cell.btnPostCustomer addTarget:self action:@selector(addEditPostCustomer:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            cell.btnPostCustomer.imageView.image = [UIImage imageNamed:@"postCustomerNo2.png"];
            [cell.btnPostCustomer addTarget:self action:@selector(addEditPostCustomer:) forControlEvents:UIControlEventTouchUpInside];
        }

        
        //button delete
//        cell.btnDeleteWidth.constant = 0;
//        cell.btnDeteteTrailing.constant = 0;
        cell.btnDelete.tag = receipt.receiptID;
        [cell.btnDelete addTarget:self action:@selector(deleteReceiptTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //event
        Event *event = [self getEvent:[receipt.eventID integerValue]];
        cell.lblEventLabel.hidden = NO;
        cell.lblEvent.hidden = NO;
        cell.lblEvent.text = event.location;
        
        
        return cell;
    }
    else
    {
        //table for receiptProductItem
        NSArray *receiptProductItemList = [self getReceiptProductItemList:tableView.tag];
        ReceiptProductItem *receiptProductItem = receiptProductItemList[indexPath.item];
        
        
        CustomTableViewCellReceiptProductItem *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierReceiptProductItem];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        NSString *strProduct = [NSString stringWithFormat:@"%ld. %@ / %@ / %@",(indexPath.item+1),receiptProductItem.productName,receiptProductItem.color,receiptProductItem.size];
        if([receiptProductItem.productType isEqualToString:@"A"]
        || [receiptProductItem.productType isEqualToString:@"B"]
        || [receiptProductItem.productType isEqualToString:@"D"]
        || [receiptProductItem.productType isEqualToString:@"E"]
        || [receiptProductItem.productType isEqualToString:@"F"]
        )
        {
            //change product
            NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
            NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:strProduct attributes:attributes];
            
            [cell.btnProduct setAttributedTitle:attrText forState:UIControlStateNormal];
        }
        else
        {
            [cell.btnProduct setTitle:strProduct forState:UIControlStateNormal];
        }
        
//        cell.btnProduct.enabled = NO;
        [cell.btnProduct addTarget:self action:@selector(showActionList:) forControlEvents:UIControlEventTouchUpInside];
        cell.btnProduct.tag = receiptProductItem.receiptProductItemID;
        
        
        //I=Inventory,C=Custom made,A=change I,B=change C,P=preorder,D=change P,S=post preorder,R=post CM,E=change R,F=change S
        if([receiptProductItem.productType isEqualToString:@"C"]
        || [receiptProductItem.productType isEqualToString:@"B"]
        || [receiptProductItem.productType isEqualToString:@"P"]
        || [receiptProductItem.productType isEqualToString:@"D"]
        || [receiptProductItem.productType isEqualToString:@"S"]
        || [receiptProductItem.productType isEqualToString:@"R"]
        || [receiptProductItem.productType isEqualToString:@"E"]
        || [receiptProductItem.productType isEqualToString:@"F"]
        )
        {
            if(receiptProductItem.isPreOrder2)
            {
                UIColor *color = [UIColor colorWithRed:255/255.0 green:47/255.0 blue:146/255.0 alpha:1];
                [cell.btnProduct setTitleColor:color forState:UIControlStateNormal];
            }
            else
            {
                [cell.btnProduct setTitleColor:tBlueColor forState:UIControlStateNormal];
            }
        }
        else
        {
            [cell.btnProduct setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        
        
        
        cell.lblPrice.text = [Utility formatBaht:receiptProductItem.priceSales];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbvData)
    {
        CustomTableViewCellReceipt *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierReceipt];
        Receipt *receipt = _receiptListForDate[indexPath.section];
        cell.lblDiscountReason.text = receipt.discountReason;
        float discountReasonHeight = 17;
        
        
        NSArray *receiptProductItemList = [self getReceiptProductItemList:receipt.receiptID];
        NSString *strDiscountReason = @"";
        for(ReceiptProductItem *item in receiptProductItemList)
        {
            if([Utility isStringEmpty:strDiscountReason])
            {
                strDiscountReason = [NSString stringWithFormat:@"%@",item.discountReason];
            }
            else
            {
                strDiscountReason = [NSString stringWithFormat:@"%@,%@",strDiscountReason,item.discountReason];
            }
        }
        cell.lblDiscountReason.text = strDiscountReason;
        if(![Utility isStringEmpty:strDiscountReason])
        {
            [cell.lblDiscountReason sizeToFit];
            discountReasonHeight = cell.lblDiscountReason.frame.size.height;
        }
        
        float redeemedValueHeight = receipt.redeemedValue > 0?19:0;
        return 176+[receiptProductItemList count]*30 -17+discountReasonHeight+redeemedValueHeight;
    }
    else
    {
        return 30;
    }
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        if(section == 0)
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
            [view setBackgroundColor:[UIColor systemGroupedBackgroundColor]]; //your background color...
            return view;
        }
    }
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        [view setBackgroundColor:[UIColor systemGroupedBackgroundColor]]; //your background color...
        return view;
    }
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if(tableView == tbvData)
    {
        if(section == 0)
        {
            return 30;
        }
    }
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        return 30;
    }
    return 0.01f;
}

-(void)setData
{
    _receiptList = _receiptListForDate;
    _receiptProductItemList = _receiptProductItemListForDate;
    for(ReceiptProductItem *item in _receiptProductItemList)
    {
        if(item.isPreOrder2)
        {
            ProductName *productName = [ProductName getProductName:item.preOrder2ProductNameID];
            item.productName = productName.name;
            item.color = [Utility getColorName:item.preOrder2Color];
            item.size = [Utility getSizeLabel:item.preOrder2Size];
            item.sizeOrder = [Utility getSizeOrder:item.preOrder2Size];
        }
        else if([item.productType isEqualToString:@"I"] || [item.productType isEqualToString:@"A"] || [item.productType isEqualToString:@"P"] || [item.productType isEqualToString:@"D"] || [item.productType isEqualToString:@"S"] || [item.productType isEqualToString:@"F"] || [item.productType isEqualToString:@"U"])
        {
            Product *product = [self getProduct:item.productID];
            NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
            item.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
            item.color = [Utility getColorName:product.color];
            item.size = [Utility getSizeLabel:product.size];
            item.sizeOrder = [Utility getSizeOrder:product.size];
        }
        else if([item.productType isEqualToString:@"C"] || [item.productType isEqualToString:@"B"] || [item.productType isEqualToString:@"E"] || [item.productType isEqualToString:@"V"])
        {
            CustomMade *customMade = [self getCustomMade:[item.productID integerValue]];
            NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
            item.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
            item.color = customMade.body;
            item.size = customMade.size;
            item.sizeOrder = [Utility getSizeOrder:customMade.size];
            item.toe = customMade.toe;
            item.body = customMade.body;
            item.accessory = customMade.accessory;
            item.customMadeRemark = customMade.remark;
        }
        else if([item.productType isEqualToString:@"R"])
        {
            CustomMade *customMade = [self getCustomMadeFromProductIDPost:item.productID];
            NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
            item.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
            item.color = customMade.body;
            item.size = customMade.size;
            item.sizeOrder = [Utility getSizeOrder:customMade.size];
            item.toe = customMade.toe;
            item.body = customMade.body;
            item.accessory = customMade.accessory;
            item.customMadeRemark = customMade.remark;
        }
    }
    
    
    //เรียงตาม receiptid, item,color,size
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptID" ascending:NO];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
        NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
        NSSortDescriptor *sortDescriptor4 = [[NSSortDescriptor alloc] initWithKey:@"_sizeOrder" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4, nil];
        _receiptProductItemList = [[_receiptProductItemList sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    }
    
    [self prepareDataForCollectionView];
        
    [tbvData reloadData];
}

- (Product *)getProduct:(NSString *)productID
{
    NSMutableArray *productList = _productListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productID = %@",productID];
    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    
    return nil;
}

- (CustomMade *)getCustomMade:(NSInteger)customMadeID
{
    NSMutableArray *customMadeList = _customMadeListForDate;
    for(CustomMade *item in customMadeList)
    {
        if(item.customMadeID == customMadeID)
        {
            return item;
        }
    }
    return nil;
}

- (CustomMade *)getCustomMadeFromProductIDPost:(NSString *)productIDPost
{
    NSMutableArray *customMadeList = _customMadeListForDate;//[SharedCustomMade sharedCustomMade].customMadeList;
    for(CustomMade *item in customMadeList)
    {
        if([item.productIDPost isEqualToString:productIDPost])
        {
            return item;
        }
    }
    return nil;
}

- (Receipt *)getReceipt:(NSInteger)receiptID
{
    NSMutableArray *receiptList = _receiptListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [receiptList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}

- (PostCustomer *) getPostCustomer:(NSInteger)postCustomerID
{
    NSMutableArray *postCustomerList = _postCustomerListForDate;
    for(PostCustomer *item in postCustomerList)
    {
        if(item.postCustomerID == postCustomerID)
        {
            return item;
        }
    }
    return nil;
}

-(ReceiptProductItem *)getReceiptProductItem:(NSInteger)receiptProductItemID
{
    NSMutableArray *receiptProductItemList = _receiptProductItemListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",receiptProductItemID];
    NSArray *filterArray = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}

- (NSArray *)getReceiptProductItemList:(NSInteger)receiptID
{
    NSMutableArray *receiptProductItemList = _receiptProductItemListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray  = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptProductItemID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortArray;
}

- (ItemTrackingNo *)getItemTrackingNo:(NSInteger)receiptProductItemID
{
    NSMutableArray *itemTrackingNoList = _itemTrackingNoListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",receiptProductItemID];
    NSArray *filterArray  = [itemTrackingNoList filteredArrayUsingPredicate:predicate1];
    
    return filterArray[0];
}

- (Event *)getEvent:(NSInteger)eventID
{
    NSMutableArray *eventList = _eventListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %ld",eventID];
    NSArray *filterArray  = [eventList filteredArrayUsingPredicate:predicate1];
    
    return filterArray[0];
}

- (NSArray *)getItemTrackingNoList:(NSInteger)receiptID
{
    NSMutableArray *itemTrackingNoList = [[NSMutableArray alloc]init];
    NSArray *receiptProductItemList = [self getReceiptProductItemList:receiptID];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:item.receiptProductItemID];
        [itemTrackingNoList addObject:itemTrackingNo];
    }
    
    return itemTrackingNoList;
}

- (NSArray *)getCustomMadeList:(NSArray *)receiptProductItemList
{
    NSMutableArray *customMadeList = [[NSMutableArray alloc]init];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        if([item.productType isEqualToString:@"C"] || [item.productType isEqualToString:@"B"] || [item.productType isEqualToString:@"E"])
        {
            CustomMade *customMade = [self getCustomMade:[item.productID integerValue]];
            if(customMade)
            {
                [customMadeList addObject:customMade];
            }
        }
        else if([item.productType isEqualToString:@"R"])
        {
            CustomMade *customMade = [self getCustomMadeFromProductIDPost:item.productID];
            if(customMade)
            {
                [customMadeList addObject:customMade];
            }
        }
    }
    return customMadeList;
}

- (NSArray *)getProductList:(NSArray *)receiptProductItemList
{
    NSMutableArray *productList = [[NSMutableArray alloc]init];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        if([item.productType isEqualToString:@"I"] || [item.productType isEqualToString:@"P"] || [item.productType isEqualToString:@"S"] || [item.productType isEqualToString:@"R"])
        {
            Product *product = [self getProduct:item.productID];
            if(product)
            {
                [productList addObject:product];
            }
        }
    }
    return productList;
}

- (BOOL) hasPost:(NSInteger)receiptID
{
    BOOL hasPost = NO;
    NSArray *receiptProductItemList = [self getReceiptProductItemList:receiptID];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:item.receiptProductItemID];
        if(itemTrackingNo.postCustomerID > 0)
        {
            hasPost = YES;
            break;
        }
    }
    
    return hasPost;
}

-(void)prepareDataForCollectionView
{
    //allocate cash, credit, transfer to each receiptProductItem
    NSInteger previousReceiptID = 0;
    float remainingCash = 0;
    float remainingCredit = 0;
    float remainingTransfer = 0;
    float remainingPayItem = 0;
    int row = 0;
    for(ReceiptProductItem *item in _receiptProductItemList)
    {
        if(previousReceiptID != item.receiptID)
        {
            Receipt *receipt = [self getReceipt:item.receiptID];
            previousReceiptID = item.receiptID;
            
            
            remainingCash = [receipt.cashAmount floatValue];
            remainingCredit = [receipt.creditAmount floatValue];
            remainingTransfer = [receipt.transferAmount floatValue];
            row = 0;
        
        }
        
        item.row = [NSString stringWithFormat:@"%d",++row];
        
        float discountValue = 0;
        if(item.discount == 1)
        {
            discountValue = item.discountValue;
        }
        else if(item.discount == 2)
        {
            discountValue = roundf(item.discountPercent*[Utility floatValue:item.priceSales]/100*100)/100;
        }
        remainingPayItem = [item.priceSales floatValue] + item.shippingFee - discountValue;
        
        //cash
        if(remainingPayItem <= remainingCash)
        {
            item.cash = remainingPayItem;
            remainingCash -= remainingPayItem;
            continue;
        }
        else
        {
            item.cash = remainingCash;
            remainingCash = 0;
            remainingPayItem -= item.cash;
            if(remainingPayItem <= remainingCredit)
            {
                item.credit = remainingPayItem;
                remainingCredit -= remainingPayItem;
                continue;
            }
            else
            {
                item.credit = remainingCredit;
                remainingCredit = 0;
                remainingPayItem -= item.credit;
                if(remainingPayItem <= remainingTransfer)
                {
                    item.transfer = remainingPayItem;
                    remainingTransfer -= remainingPayItem;
                    continue;
                }
            }
        }
    }
}

- (void) addEditPostCustomer:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger receiptID = button.tag;
    _selectedPostCustomer = [self getPostCustomerFromReceiptID:receiptID];
    _selectedReceiptProductItemList = [[self getReceiptProductItemList:receiptID] mutableCopy];
    [self performSegueWithIdentifier:@"segPostCustomer" sender:self];
}

-(PostCustomer *)getPostCustomerFromReceiptID:(NSInteger)receiptID
{
    NSArray *receiptProductItemList = [self getReceiptProductItemList:receiptID];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:item.receiptProductItemID];
        if(itemTrackingNo.postCustomerID > 0)
        {
            PostCustomer *postCustomer = [self getPostCustomer:itemTrackingNo.postCustomerID];
            return postCustomer;
        }
    }
    
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segPostCustomer"])
    {
        AddEditPostCustomerViewController *vc = segue.destinationViewController;
        vc.paid = YES;
        vc.telephoneNoSearch = _selectedPostCustomer?_selectedPostCustomer.telephone:@"";
        vc.receiptProductItemList = _selectedReceiptProductItemList;
        vc.selectedPostCustomer = _selectedPostCustomer;        
        vc.pageIndex = 1;
    }
}

- (IBAction)searchReceipt:(id)sender
{
    [self loadingOverlayView];
    NSString *searchText = [Utility trimString:txtSearchText.text];
    NSString *searchBy = [NSString stringWithFormat:@"%ld",segConSearchBy.selectedSegmentIndex];
    [self.homeModel downloadItems:dbReceiptSearch condition:@[searchText,searchBy]];
}

-(void)showActionList:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger receiptProductItemID = button.tag;
    ReceiptProductItem *receiptProductItem = [self getReceiptProductItem:receiptProductItemID];
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
           
    
    //I=Inventory,C=Custom made,A=change I,B=change C,P=preorder,D=change P,S=post preorder,R=post CM,E=change R,F=change S
    if([receiptProductItem.productType isEqualToString:@"I"]
    || [receiptProductItem.productType isEqualToString:@"C"]
    || [receiptProductItem.productType isEqualToString:@"P"]
    || [receiptProductItem.productType isEqualToString:@"S"]
    || [receiptProductItem.productType isEqualToString:@"R"]
    )
    {
        [alert addAction:
        [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Change Product"]
                                 style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action)
                               {
                                   [self changeProduct:receiptProductItemID];
                               }]];
    }
    
    //delete product
    [alert addAction:
    [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete Product"]
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction *action)
                           {
                               [self deleteProduct:receiptProductItemID];
                           }]];
    
    
    //replace product
    if([receiptProductItem.productType isEqualToString:@"A"]
    || [receiptProductItem.productType isEqualToString:@"B"]
    || [receiptProductItem.productType isEqualToString:@"D"]
    || [receiptProductItem.productType isEqualToString:@"E"]
    || [receiptProductItem.productType isEqualToString:@"F"]
    )
    {
        [alert addAction:
        [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Order Replace-Product"]
                                 style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action)
                               {
                                   [self orderReplaceProduct:receiptProductItem];
                               }]];
    }
    
    
   
   [alert addAction:
    [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Add/Edit Post"]
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction *action)
   {
        NSMutableArray *receiptProductItemList = [[NSMutableArray alloc]init];
        [receiptProductItemList addObject:receiptProductItem];
        
       _selectedReceiptProductItemList = receiptProductItemList;
       ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:receiptProductItem.receiptProductItemID];
       _selectedPostCustomer = [self getPostCustomer:itemTrackingNo.postCustomerID];
       [self performSegueWithIdentifier:@"segPostCustomer" sender:self];
   }]];
                            
                            
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];

    //////////////ipad
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        CGRect frame = button.imageView.bounds;
        frame.origin.y = frame.origin.y-15;
        popPresenter.sourceView = button.imageView;
        popPresenter.sourceRect = frame;
    }
    ///////////////
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void) changeProduct:(NSInteger)receiptProductItemID
{
    ReceiptProductItem *receiptProductItem = [self getReceiptProductItem:receiptProductItemID];
    
    if([receiptProductItem.productType isEqualToString:@"U"] || [receiptProductItem.productType isEqualToString:@"V"])
    {
        UIAlertController* alert = [UIAlertController
            alertControllerWithTitle:@"Cannnot change product"
            message:@"Product is unidentified"
            preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action)
            {}];
        
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                            preferredStyle:UIAlertControllerStyleActionSheet];
                            
                            
    [alert addAction:
     [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Change product (No.%@)",receiptProductItem.row]
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                //update receiptproductitem producttype=xx,productID=customMadeEdit
                                //update product status = 'I'
                                //update customMade productIDPost = ''
                                //customerreceipt trackingno คงไว้
                                
                                NSMutableArray *arrProduct = [[NSMutableArray alloc]init];
                                NSMutableArray *arrCustomMade = [[NSMutableArray alloc]init];;
                                NSMutableArray *arrReceiptProductItem = [[NSMutableArray alloc]init];;
                                if([receiptProductItem.productType isEqualToString:@"I"] || [receiptProductItem.productType isEqualToString:@"P"] || [receiptProductItem.productType isEqualToString:@"R"] || [receiptProductItem.productType isEqualToString:@"S"])
                                {
//                                    Product *product = [self getProduct:receiptProductItem.productID];
                                    Product *product = [[Product alloc]init];
                                    product.productID = receiptProductItem.productID;
                                    product.status = @"I";
                                    product.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                    product.modifiedUser = [Utility modifiedUser];
                                    [arrProduct addObject:product];
                                }
                                ReceiptProductItem *receiptProductItemUpdate = [[ReceiptProductItem alloc]init];
                                receiptProductItemUpdate.receiptProductItemID = receiptProductItem.receiptProductItemID;
                                receiptProductItemUpdate.productID = receiptProductItem.productID;
                                if([receiptProductItem.productType isEqualToString:@"I"])
                                {
                                    receiptProductItemUpdate.productType = @"A";
                                }
                                else if([receiptProductItem.productType isEqualToString:@"C"])
                                {
                                    receiptProductItemUpdate.productType = @"B";
                                }
                                else if([receiptProductItem.productType isEqualToString:@"P"])
                                {
                                    receiptProductItemUpdate.productType = @"D";
                                }
                                else if([receiptProductItem.productType isEqualToString:@"R"])
                                {
                                    if(receiptProductItem.isPreOrder2)
                                    {
                                        receiptProductItemUpdate.productID = @"";
                                        receiptProductItemUpdate.productType = @"E";
                                    }
                                    else
                                    {
                                        CustomMade *customMade = [[CustomMade alloc]init];
                                        NSString *strCustomMadeID = [NSString stringWithFormat:@"%ld",customMade.customMadeID];
                                        customMade.productIDPost = @"";
                                        customMade.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                        customMade.modifiedUser = [Utility modifiedUser];
                                        [arrCustomMade addObject:customMade];
                                        
                                        receiptProductItemUpdate.productID = strCustomMadeID;
                                        receiptProductItemUpdate.productType = @"E";
                                    }
                                }
                                else if([receiptProductItem.productType isEqualToString:@"S"])
                                {
                                    receiptProductItemUpdate.productType = @"F";
                                }
                                receiptProductItemUpdate.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                receiptProductItemUpdate.modifiedUser = [Utility modifiedUser];
                                [arrReceiptProductItem addObject:receiptProductItemUpdate];
                                
                                
                                
                                NSArray *arrData = @[arrProduct,arrCustomMade,arrReceiptProductItem];
                                [self loadingOverlayView];
                                [self.homeModel updateItems:dbReceiptProductItemAndProductUpdate withData:arrData];
                                
//                                [self fetchData];
                            }]];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) deleteProduct:(NSInteger)receiptProductItemID
{
    ReceiptProductItem *receiptProductItem = [self getReceiptProductItem:receiptProductItemID];
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                            preferredStyle:UIAlertControllerStyleActionSheet];
                            
                            
    [alert addAction:
     [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete product (No.%@)",receiptProductItem.row]
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                //update receiptproductitem producttype=xx,productID=customMadeEdit
                                //update product status = 'I'
                                    //customerreceipt trackingno คงไว้
                                
                                NSMutableArray *arrProduct = [[NSMutableArray alloc]init];
                                NSMutableArray *arrCustomMade = [[NSMutableArray alloc]init];;
                                NSMutableArray *arrReceiptProductItem = [[NSMutableArray alloc]init];;
                                if([receiptProductItem.productType isEqualToString:@"I"] || [receiptProductItem.productType isEqualToString:@"P"] || [receiptProductItem.productType isEqualToString:@"R"] || [receiptProductItem.productType isEqualToString:@"S"])
                                {
                                    Product *product = [[Product alloc]init];
                                    product.productID = receiptProductItem.productID;
                                    product.status = @"I";
                                    product.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                    product.modifiedUser = [Utility modifiedUser];
                                    [arrProduct addObject:product];
                                }
                                ReceiptProductItem *receiptProductItemUpdate = [[ReceiptProductItem alloc]init];
                                receiptProductItemUpdate.receiptProductItemID = receiptProductItem.receiptProductItemID;
                                receiptProductItemUpdate.productID = receiptProductItem.productID;
                               
        if([receiptProductItem.productType isEqualToString:@"C"] || [receiptProductItem.productType isEqualToString:@"B"] || [receiptProductItem.productType isEqualToString:@"E"])
        {
            CustomMade *customMade = [self getCustomMade:[receiptProductItem.productID integerValue]];
            [arrCustomMade addObject:customMade];
        }
        
                                if([receiptProductItem.productType isEqualToString:@"R"])
                                {
                                    if(!receiptProductItem.isPreOrder2)
                                    {
                                        CustomMade *customMade = [self getCustomMadeFromProductIDPost:receiptProductItem.productID];
                                        [arrCustomMade addObject:customMade];
                                    }
                                }
                                    
        
                                receiptProductItemUpdate.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                receiptProductItemUpdate.modifiedUser = [Utility modifiedUser];
                                [arrReceiptProductItem addObject:receiptProductItemUpdate];
                                
                                
                                
                                NSArray *arrData = @[arrProduct,arrCustomMade,arrReceiptProductItem];
                                [self loadingOverlayView];
                                [self.homeModel updateItems:dbReceiptProductItemDelete withData:arrData];
                                
//                                [self fetchData];
                            }]];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)itemsUpdatedWithReturnData:(NSArray *)data
{
    if(self.homeModel.propCurrentDB == dbReceiptProductItemAndProductUpdate)
    {
        [self removeOverlayViews];
        NSMutableArray *returnProductList = data[0];
        NSMutableArray *returnCustomMadeList = data[1];
        NSMutableArray *returnReceiptProductItemList = data[2];
        if([returnProductList count]>0)
        {
            Product *returnProduct = returnProductList[0];
            Product *updateProduct = [self getProduct:returnProduct.productID];
            updateProduct.status = returnProduct.status;
        }
        if([returnCustomMadeList count] > 0)
        {
            CustomMade *returnCustomMade = returnCustomMadeList[0];
            CustomMade *updateCustomMade = [self getCustomMade:returnCustomMade.customMadeID];
            updateCustomMade.productIDPost = @"";
        }
        ReceiptProductItem *returnReceiptProductItem = returnReceiptProductItemList[0];
        ReceiptProductItem *updateReceiptProductItem = [self getReceiptProductItem:returnReceiptProductItem.receiptProductItemID];
        updateReceiptProductItem.productType = returnReceiptProductItem.productType;
        updateReceiptProductItem.productID = returnReceiptProductItem.productID;
        [self setData];
    }
    else if(self.homeModel.propCurrentDB == dbReceiptProductItemDelete)
    {
        [self removeOverlayViews];
        NSMutableArray *returnProductList = data[0];
        NSMutableArray *returnCustomMadeList = data[1];
        NSMutableArray *returnReceiptProductItemList = data[2];
        NSMutableArray *returnReceiptList = data[3];
        NSArray *messageList = data[4];
        InAppMessage *message = messageList[0];
                
        if(![Utility isStringEmpty:message.message])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                   message:message.message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;;
        }
        
        if([returnProductList count]>0)
        {
            Product *returnProduct = returnProductList[0];
            Product *updateProduct = [self getProduct:returnProduct.productID];
            updateProduct.status = returnProduct.status;
        }
        if([returnCustomMadeList count] > 0)
        {
            CustomMade *returnCustomMade = returnCustomMadeList[0];
            CustomMade *updateCustomMade = [self getCustomMade:returnCustomMade.customMadeID];
            updateCustomMade.productIDPost = @"";
        }
        Receipt *returnReceipt = returnReceiptList[0];
        Receipt *updateReceipt = [self getReceipt:returnReceipt.receiptID];
        updateReceipt.payPrice = returnReceipt.payPrice;
        updateReceipt.cashAmount = returnReceipt.cashAmount;
        updateReceipt.creditAmount = returnReceipt.creditAmount;
        updateReceipt.transferAmount = returnReceipt.transferAmount;
        updateReceipt.total = returnReceipt.total;
        
        
        ReceiptProductItem *returnReceiptProductItem = returnReceiptProductItemList[0];
        ReceiptProductItem *updateReceiptProductItem = [self getReceiptProductItem:returnReceiptProductItem.receiptProductItemID];
        [self removeReceiptProductItem:updateReceiptProductItem];
        [self setData];
        
    }
}

-(void)orderReplaceProduct:(ReceiptProductItem *)receiptProductItem
{
    [[SharedProductBuy sharedProductBuy].productBuyList removeAllObjects];
    [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
    [SharedReplaceReceiptProductItem sharedReplaceReceiptProductItem].replaceReceiptProductItem = [[ReceiptProductItem alloc]init];
    
    
    ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:receiptProductItem.receiptProductItemID];
    PostCustomer *postCustomer = [self getPostCustomer:itemTrackingNo.postCustomerID];
    if(postCustomer)
    {
        [[SharedPostBuy sharedPostBuy].postBuyList addObject:postCustomer];
    }
    
    Receipt *receipt = [self getReceipt:receiptProductItem.receiptID];
    receiptProductItem.eventID = receipt.eventID;
    [SharedReplaceReceiptProductItem sharedReplaceReceiptProductItem].replaceReceiptProductItem = receiptProductItem;
    [self performSegueWithIdentifier:@"segProductDetail" sender:self];
}

-(void)deleteReceiptTapped:(id)sender
{
    UIButton *deleteButton = (UIButton *)sender;
    NSInteger receiptID = deleteButton.tag;

    
    
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                    preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:
         [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete sales"]
                                  style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    //delete Receipt
                                    //delete customerreceipt
                                    //delete receiptproductitem
                                    //delete custommade
                                    //update product set status = I
                                    //postcustomer คงไว้ เป็นฐานรายชื่อลูกค้า แต่เราลบตัว link postcustomer ใน customerreceipt ไปแล้ว
                                    _selectedReceiptID = [NSString stringWithFormat:@"%ld", receiptID];
                                    Receipt *receipt = [self getReceipt:receiptID];
                                    NSArray *arrItemTrackingNo = [self getItemTrackingNoList:receiptID];
                                    NSArray *arrReceiptProductItem = [self getReceiptProductItemList:receiptID];
                                    NSArray *arrCustomMade = [self getCustomMadeList:arrReceiptProductItem];
                                    NSArray *arrProduct = [self getProductList:arrReceiptProductItem];
                                    NSMutableArray *arrRewardPoint = [RewardPoint getRewardPointWithReceiptID:receiptID];
                                    [[SharedRewardPoint sharedRewardPoint].rewardPointList removeObjectsInArray:arrRewardPoint];
                                    

                                    NSMutableArray *updateProductList = [[NSMutableArray alloc]init];
                                    for(Product *item in arrProduct)
                                    {
                                        Product *updateProduct = [[Product alloc]init];
                                        updateProduct.productID = item.productID;
                                        updateProduct.status = @"I";
                                        updateProduct.remark = @"";
                                        updateProduct.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                        updateProduct.modifiedUser = [Utility modifiedUser];
                                        [updateProductList addObject:updateProduct];
                                    }
                                    {
                                        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptProductItemID" ascending:YES];
                                        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                        NSArray *sortArray = [arrReceiptProductItem sortedArrayUsingDescriptors:sortDescriptors];
                                        arrReceiptProductItem = sortArray;
                                    }
                                    {
                                        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_customMadeID" ascending:YES];
                                        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                        NSArray *sortArray = [arrCustomMade sortedArrayUsingDescriptors:sortDescriptors];
                                        arrCustomMade = sortArray;
                                    }
                                    {
                                        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
                                        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                        NSArray *sortArray = [updateProductList sortedArrayUsingDescriptors:sortDescriptors];
                                        updateProductList = [sortArray mutableCopy];
                                    }
                                    
                                    NSArray *arrData = @[receipt,arrItemTrackingNo,arrReceiptProductItem,arrCustomMade,updateProductList];
                                    [self loadingOverlayView];
                                    [self.homeModel deleteItems:dbReceiptAndReceiptProductItemDelete withData:arrData];
                                                                        
                                }]];
        [alert addAction:
         [UIAlertAction actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction *action) {}]];
        
        //////////////ipad
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [alert setModalPresentationStyle:UIModalPresentationPopover];
            
            UIPopoverPresentationController *popPresenter = [alert
                                                             popoverPresentationController];
            CGRect frame = deleteButton.imageView.bounds;
            frame.origin.y = frame.origin.y-15;
            popPresenter.sourceView = deleteButton.imageView;
            popPresenter.sourceRect = frame;
            //        popPresenter.barButtonItem = _barButtonIpad;
        }
        ///////////////
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)itemsDeletedWithReturnData:(NSArray *)data
{
    [self removeOverlayViews];
    if(self.homeModel.propCurrentDB == dbReceiptAndReceiptProductItemDelete)
    {
        NSInteger receiptID = [_selectedReceiptID integerValue];
        Receipt *receipt = [self getReceipt:receiptID];
        NSArray *arrItemTrackingNo = [self getItemTrackingNoList:receiptID];
        NSArray *arrReceiptProductItem = [self getReceiptProductItemList:receiptID];
        NSArray *arrCustomMade = [self getCustomMadeList:arrReceiptProductItem];
        NSArray *arrProduct = [self getProductList:arrReceiptProductItem];
       
       
        
        [_receiptListForDate removeObject:receipt];
        [_itemTrackingNoListForDate removeObjectsInArray:arrItemTrackingNo];
        [_receiptProductItemListForDate removeObjectsInArray:arrReceiptProductItem];
        [_customMadeListForDate removeObjectsInArray:arrCustomMade];
        for(Product *item in arrProduct)
        {
            item.status = @"I";
            item.remark = @"";
            item.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            item.modifiedUser = [Utility modifiedUser];
        }
        
        [self setData];
        
        
        NSArray *messageList = data[0];
        InAppMessage *message = messageList[0];
        NSString *strMessage = message.message;
        if(![Utility isStringEmpty:message.message])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                   message:strMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}


-(void)removeReceiptProductItem:(ReceiptProductItem *)receiptProductItem
{
    [_receiptProductItemListForDate removeObject:receiptProductItem];
}
@end
