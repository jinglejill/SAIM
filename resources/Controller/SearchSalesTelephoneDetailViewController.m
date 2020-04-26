//
//  SearchSalesTelephoneDetailViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "SearchSalesTelephoneDetailViewController.h"
#import "AddEditPostCustomerViewController.h"
#import "CustomTableViewCellReceipt.h"
#import "CustomTableViewCellReceiptProductItem.h"
#import "ItemTrackingNo.h"

@interface SearchSalesTelephoneDetailViewController ()
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
}
@end
static NSString * const reuseIdentifierReceipt = @"CustomTableViewCellReceipt";
static NSString * const reuseIdentifierReceiptProductItem = @"CustomTableViewCellReceiptProductItem";
@implementation SearchSalesTelephoneDetailViewController
@synthesize tbvData;
@synthesize postCustomer;

- (IBAction)unwindToSearchSalesTelephoneDetail:(UIStoryboardSegue *)segue
{
    [self setData];
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
    
    [self loadingOverlayView];
    [self.homeModel downloadItems:dbSearchSalesTelephoneDetail condition:postCustomer];
}

-(void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    
    if(self.homeModel.propCurrentDB == dbSearchSalesTelephoneDetail)
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
        NSString *receiptTime = [Utility formatDate:receipt.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd HH:mm"];
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
        cell.txtRemark.enabled = NO;
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
        cell.btnDeleteWidth.constant = 0;
        cell.btnDeteteTrailing.constant = 0;
    //    cell.btnDelete.tag = receipt.receiptID;
    //    [cell.btnDelete addTarget:self action:@selector(deleteReceiptTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        
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
        
        cell.btnProduct.enabled = NO;


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
        vc.readOnly = YES;
        vc.pageIndex = 2;
    }
}

@end

