//
//  SalesProductAndPrice.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/7/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "SalesProductAndPrice.h"

@implementation SalesProductAndPrice

+(void)clearBillingsWithProductNameID:(NSInteger)productNameID salesProductAndPrice:(NSMutableArray *)salesProductAndPriceList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productNameID];
    NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
    
    for(SalesProductAndPrice *item in filterArray)
    {
        item.billings = 0;
    }    
}

+(NSInteger)getCountBillingsWithProductNameID:(NSInteger)productNameID salesProductAndPrice:(NSMutableArray *)salesProductAndPriceList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 1",productNameID];
    NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
    
    return [filterArray count];
}

+(void)addBillings:(NSInteger)count productNameID:(NSInteger)productNameID salesProductAndPrice:(NSMutableArray *)salesProductAndPriceList
{
    // มี 4 step
    // 1.เอา tax=Y และ credit=Y
    // 2.เอา tax=Y และ credit=N
    // 3.เอา tax=N และ credit=Y
    // 4.เอา tax=N และ credit=N
    //random sales ที่มี tax และจ่ายด้วย บัตรเครดิต ไปออกบิลก่อน
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 0 and (NOT _taxCustomerName == \"\") and _isCredit = 1",productNameID];
    NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
    filterArray = [self getSalesProductAndPriceSortByReceiptDate:[filterArray mutableCopy]];
    
    
    NSInteger remainingCount = count;
    if(remainingCount >= [filterArray count])
    {
        for(SalesProductAndPrice *item in filterArray)
        {
            item.billings = 1;
        }
        remainingCount = count-[filterArray count];
        
        
        if(remainingCount > 0)
        {
            //ถัดไปก็ random sales ที่มี tax ไปออกบิล
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 0 and (NOT _taxCustomerName == \"\")",productNameID];
            NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
            filterArray = [self getSalesProductAndPriceSortByReceiptDate:[filterArray mutableCopy]];
            
            
            if(remainingCount >= [filterArray count])
            {
                for(SalesProductAndPrice *item in filterArray)
                {
                    item.billings = 1;
                }
                remainingCount = remainingCount-[filterArray count];
                
                
                if(remainingCount > 0)
                {
                    //ถัดไปก็ random sales ที่จ่ายด้วยบัตรเครดิต ไปออกบิล
                    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 0 and _isCredit = 1",productNameID];
                    NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
                    filterArray = [self getSalesProductAndPriceSortByReceiptDate:[filterArray mutableCopy]];
                    
                    
                    if(remainingCount >= [filterArray count])
                    {
                        for(SalesProductAndPrice *item in filterArray)
                        {
                            item.billings = 1;
                        }
                        remainingCount = remainingCount-[filterArray count];
                        
                        
                        if(remainingCount > 0)
                        {
                            //ถัดไปก็ random sales ที่เหลือ ไปออกบิล
                            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 0",productNameID];
                            NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
                            filterArray = [self getSalesProductAndPriceSortByReceiptDate:[filterArray mutableCopy]];
                            
                            
                            //random
                            NSMutableSet *ranSet = [[NSMutableSet alloc]init];
                            for(;;)
                            {
                                int ran = arc4random() % [filterArray count];
                                [ranSet addObject:[NSString stringWithFormat:@"%d",ran]];
                                
                                if([ranSet count] == remainingCount)
                                {
                                    break;
                                }
                            }
                            
                            
                            for(NSString *item in ranSet)
                            {
                                SalesProductAndPrice *salesProductAndPrice = filterArray[[item integerValue]];
                                salesProductAndPrice.billings = 1;
                            }
                        }
                    }
                    else
                    {
                        //random
                        NSMutableSet *ranSet = [[NSMutableSet alloc]init];
                        for(;;)
                        {
                            int ran = arc4random() % [filterArray count];
                            [ranSet addObject:[NSString stringWithFormat:@"%d",ran]];
                            
                            if([ranSet count] == remainingCount)
                            {
                                break;
                            }
                        }
                        
                        
                        for(NSString *item in ranSet)
                        {
                            SalesProductAndPrice *salesProductAndPrice = filterArray[[item integerValue]];
                            salesProductAndPrice.billings = 1;
                        }
                    }
                }
            }
            else
            {
                //random
                NSMutableSet *ranSet = [[NSMutableSet alloc]init];
                for(;;)
                {
                    int ran = arc4random() % [filterArray count];
                    [ranSet addObject:[NSString stringWithFormat:@"%d",ran]];
                    
                    if([ranSet count] == remainingCount)
                    {
                        break;
                    }
                }
                
                
                for(NSString *item in ranSet)
                {
                    SalesProductAndPrice *salesProductAndPrice = filterArray[[item integerValue]];
                    salesProductAndPrice.billings = 1;
                }
            }
        }
    }
    else
    {
        //random
        NSMutableSet *ranSet = [[NSMutableSet alloc]init];
        for(;;)
        {
            int ran = arc4random() % [filterArray count];
            [ranSet addObject:[NSString stringWithFormat:@"%d",ran]];
            
            if([ranSet count] == remainingCount)
            {
                break;
            }
        }
        
        
        for(NSString *item in ranSet)
        {
            SalesProductAndPrice *salesProductAndPrice = filterArray[[item integerValue]];
            salesProductAndPrice.billings = 1;
        }
    }
}

+(void)removeBillings:(NSInteger)count productNameID:(NSInteger)productNameID salesProductAndPrice:(NSMutableArray *)salesProductAndPriceList
{
    //random sales ที่มีไม่มี tax และจ่ายสด คืนกลับไป
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 1 and (_taxCustomerName == \"\") and _isCredit = 0",productNameID];
    NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
    filterArray = [self getSalesProductAndPriceSortByReceiptDateDesc:[filterArray mutableCopy]];
    
    
    NSInteger remainingCount = count;
    if(remainingCount >= [filterArray count])
    {
        for(SalesProductAndPrice *item in filterArray)
        {
            item.billings = 0;
        }
        remainingCount = count-[filterArray count];
        
        
        if(remainingCount > 0)
        {
            //random sales ที่มีไม่มี tax และจ่ายด้วยบัตรเครดิต คืนกลับไป
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 1 and (_taxCustomerName == \"\") and _isCredit = 1",productNameID];
            NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
            filterArray = [self getSalesProductAndPriceSortByReceiptDateDesc:[filterArray mutableCopy]];
            
            
            if(remainingCount >= [filterArray count])
            {
                for(SalesProductAndPrice *item in filterArray)
                {
                    item.billings = 0;
                }
                remainingCount = count-[filterArray count];
                
                
                if(remainingCount > 0)
                {
                    //random sales ที่มี tax และจ่ายสด คืนกลับไป
                    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 1 and (NOT _taxCustomerName == \"\") and _isCredit = 0",productNameID];
                    NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
                    filterArray = [self getSalesProductAndPriceSortByReceiptDateDesc:[filterArray mutableCopy]];
                    
                    
                    if(remainingCount >= [filterArray count])
                    {
                        for(SalesProductAndPrice *item in filterArray)
                        {
                            item.billings = 0;
                        }
                        remainingCount = count-[filterArray count];
                        
                        
                        if(remainingCount > 0)
                        {
                            //random sales ที่มี tax และจ่ายด้วยบัตรเครดิต คืนกลับไป
                            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 1 and (NOT _taxCustomerName == \"\") and _isCredit = 1",productNameID];
                            NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
                            filterArray = [self getSalesProductAndPriceSortByReceiptDateDesc:[filterArray mutableCopy]];
                            
                            
                            //random
                            NSMutableSet *ranSet = [[NSMutableSet alloc]init];
                            for(;;)
                            {
                                int ran = arc4random() % [filterArray count];
                                [ranSet addObject:[NSString stringWithFormat:@"%d",ran]];
                                
                                if([ranSet count] == remainingCount)
                                {
                                    break;
                                }
                            }
                            
                            
                            for(NSString *item in ranSet)
                            {
                                SalesProductAndPrice *salesProductAndPrice = filterArray[[item integerValue]];
                                salesProductAndPrice.billings = 0;
                            }
                        }
                    }
                    else
                    {
                        //random
                        NSMutableSet *ranSet = [[NSMutableSet alloc]init];
                        for(;;)
                        {
                            int ran = arc4random() % [filterArray count];
                            [ranSet addObject:[NSString stringWithFormat:@"%d",ran]];
                            
                            if([ranSet count] == remainingCount)
                            {
                                break;
                            }
                        }
                        
                        
                        for(NSString *item in ranSet)
                        {
                            SalesProductAndPrice *salesProductAndPrice = filterArray[[item integerValue]];
                            salesProductAndPrice.billings = 0;
                        }
                    }
                }
            }
            else
            {
                //random
                NSMutableSet *ranSet = [[NSMutableSet alloc]init];
                for(;;)
                {
                    int ran = arc4random() % [filterArray count];
                    [ranSet addObject:[NSString stringWithFormat:@"%d",ran]];
                    
                    if([ranSet count] == remainingCount)
                    {
                        break;
                    }
                }
                
                
                for(NSString *item in ranSet)
                {
                    SalesProductAndPrice *salesProductAndPrice = filterArray[[item integerValue]];
                    salesProductAndPrice.billings = 0;
                }
            }
        }
    }
    else
    {
        //random
        NSMutableSet *ranSet = [[NSMutableSet alloc]init];
        for(;;)
        {
            int ran = arc4random() % [filterArray count];
            [ranSet addObject:[NSString stringWithFormat:@"%d",ran]];
            
            if([ranSet count] == remainingCount)
            {
                break;
            }
        }
        
        
        for(NSString *item in ranSet)
        {
            SalesProductAndPrice *salesProductAndPrice = filterArray[[item integerValue]];
            salesProductAndPrice.billings = 0;
        }
    }
}
//+(void)addBillings:(NSInteger)count productNameID:(NSInteger)productNameID salesProductAndPrice:(NSMutableArray *)salesProductAndPriceList
//{
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 0",productNameID];
//    NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
//
//
//    filterArray = [self getSalesProductAndPriceSortByReceiptDate:[filterArray mutableCopy]];
//
//
//    //random
//    NSMutableSet *ranSet = [[NSMutableSet alloc]init];
//    for(;;)
//    {
//        int ran = arc4random() % [filterArray count];
//        [ranSet addObject:[NSString stringWithFormat:@"%d",ran]];
//
//        if([ranSet count] == count)
//        {
//            break;
//        }
//    }
//
//
//    for(NSString *item in ranSet)
//    {
//        SalesProductAndPrice *salesProductAndPrice = filterArray[[item integerValue]];
//        salesProductAndPrice.billings = 1;
//    }
//}

//+(void)removeBillings:(NSInteger)count productNameID:(NSInteger)productNameID salesProductAndPrice:(NSMutableArray *)salesProductAndPriceList
//{
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _billings = 1",productNameID];
//    NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
//    
//    
//    filterArray = [self getSalesProductAndPriceSortByReceiptDateDesc:[filterArray mutableCopy]];
//    
//    
//    //random
//    NSMutableSet *ranSet = [[NSMutableSet alloc]init];
//    for(;;)
//    {
//        int ran = arc4random() % [filterArray count];
//        [ranSet addObject:[NSString stringWithFormat:@"%d",ran]];
//        
//        if([ranSet count] == count)
//        {
//            break;
//        }
//    }
//    
//    
//    for(NSString *item in ranSet)
//    {
//        SalesProductAndPrice *salesProductAndPrice = filterArray[[item integerValue]];
//        salesProductAndPrice.billings = 0;
//    }
//}

+(NSMutableArray *)getSalesProductAndPriceSortByReceiptDate:(NSMutableArray *)salesProductAndPriceList
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptDate" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_receiptID" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
    NSArray *sortArray = [salesProductAndPriceList sortedArrayUsingDescriptors:sortDescriptors];
    salesProductAndPriceList = [sortArray mutableCopy];
    return salesProductAndPriceList;
}

+(NSMutableArray *)getSalesProductAndPriceSortByReceiptDateDesc:(NSMutableArray *)salesProductAndPriceList
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptDate" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_receiptID" ascending:NO];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
    NSArray *sortArray = [salesProductAndPriceList sortedArrayUsingDescriptors:sortDescriptors];
    salesProductAndPriceList = [sortArray mutableCopy];
    return salesProductAndPriceList;
}

+(void)hilightEveryOtherReceipt:(NSMutableArray *)salesProductAndPriceList
{
    NSInteger previousReceiptID = 0;
    BOOL hilight = YES;
    for(SalesProductAndPrice *item in salesProductAndPriceList)
    {
        if(item.receiptID != previousReceiptID)
        {
            hilight = !hilight;
            previousReceiptID = item.receiptID;
        }
        item.hilight = hilight;
    }
}

+(float)getTotalSalesSelected:(NSMutableArray *)salesProductAndPriceList
{
    float totalSalesSelected = 0;
    for(SalesProductAndPrice *item in salesProductAndPriceList)
    {
        if(item.billings == 1)
        {
            totalSalesSelected += item.priceSales;
        }
    }
    return totalSalesSelected;
}

+(float)getTotalPairsSelected:(NSMutableArray *)salesProductAndPriceList
{
    NSInteger totalPairsSelected = 0;
    for(SalesProductAndPrice *item in salesProductAndPriceList)
    {
        if(item.billings == 1)
        {
            totalPairsSelected++;
        }
    }
    return totalPairsSelected;
}

+(NSMutableArray *)getSalesProductAndPriceBillingsOnly:(NSMutableArray *)salesProductAndPriceList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_billings = 1"];
    NSArray *filterArray = [salesProductAndPriceList filteredArrayUsingPredicate:predicate1];
    
    return [filterArray mutableCopy];
}

+(NSInteger)getCountSalesProductAndPriceBillingsOnly:(NSMutableArray *)salesProductAndPriceList
{
    NSMutableArray *filterArray = [self getSalesProductAndPriceBillingsOnly:salesProductAndPriceList];
    return [filterArray count];
}

- (id)copyWithZone:(NSZone *)zone
{
    // Copying code here.
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setProductName:[self.productName copyWithZone:zone]];
        [copy setReceiptDate:[self.receiptDate copyWithZone:zone]];
        
        
        ((SalesProductAndPrice *)copy).productNameID = self.productNameID;
        ((SalesProductAndPrice *)copy).priceSales = self.priceSales;
        ((SalesProductAndPrice *)copy).billings = self.billings;
        ((SalesProductAndPrice *)copy).receiptID = self.receiptID;
        ((SalesProductAndPrice *)copy).receiptDiscount = self.receiptDiscount;
        ((SalesProductAndPrice *)copy).hilight = self.hilight;
        ((SalesProductAndPrice *)copy).quantity = self.quantity;
        ((SalesProductAndPrice *)copy).amountPerUnit = self.amountPerUnit;
        
    }
    
    return copy;
}

+(SalesProductAndPrice *)getSalesProductAndPriceWithReceiptID:(NSInteger)receiptID salesProductAndPriceList:(NSMutableArray *)salesProductAndPriceBillingsOnlySumQuantityList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [salesProductAndPriceBillingsOnlySumQuantityList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}
@end
