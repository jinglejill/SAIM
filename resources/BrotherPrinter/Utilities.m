//
//  Utilities.m
//  SDK_Sample
//
//  Created by Sha Peng on 5/15/14.
//
//

#import "Utilities.h"

#define kBROTHERPJ673   @"Brother PJ-673"
#define kPrinterCapabilitiesKey     @"Capabilities"
#define kPrinterPaperSizeKey        @"PaperSize"

#define kFuncDensity                @"FuncDensity"
#define kFuncCustomPaper            @"FuncCustomPaper"
#define kFuncAutoCut                @"FuncAutoCut"
#define kFuncChainPrint             @"FuncChainPrint"
#define kFuncHalfCut                @"FuncHalfCut"
#define kFuncSpecialTape            @"FuncSpecialTape"
#define kFuncCopies                 @"FuncCopies"
#define kFuncCarbonPrint            @"FuncCarbonPrint"
#define kFuncDashPrint              @"FuncDashPrint"
#define kFuncFeedMode               @"FuncFeedMode"
@implementation Utilities

BOOL isFuncAvailable(NSString *func , NSString *printerName)
{
    BOOL ret = FALSE;
    
    NSString *	path = [[NSBundle mainBundle] pathForResource:@"PrinterList" ofType:@"plist"];
    if( path )
    {
        NSDictionary *printerDict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSDictionary *printerInfo = [printerDict valueForKey:printerName];
        NSDictionary *capabilities = [printerInfo valueForKey:kPrinterCapabilitiesKey];
        
        ret = [[capabilities valueForKey:func] boolValue];
    }
    else{
        NSLog(@"Path is not existed !");
    }
    
    return ret;
}

NSDictionary* supportedFuncForPrinter(NSString *printerName)
{
    NSDictionary *supportedFuncs;
    
    NSString *	path = [[NSBundle mainBundle] pathForResource:@"PrinterList" ofType:@"plist"];
    if( [[NSFileManager defaultManager] fileExistsAtPath:path] )
    {
        NSDictionary *printerDict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSDictionary *printerInfo = [printerDict valueForKey:printerName];
        NSDictionary *capabilities = [printerInfo valueForKey:kPrinterCapabilitiesKey];
        
        supportedFuncs = [NSDictionary dictionaryWithDictionary:capabilities];
    }
    else{
        NSLog(@"Path is not existed !");
        supportedFuncs = nil;
    }
    
    
    return supportedFuncs;
}

NSArray* supportedPaperSizeForPrinter(NSString *printerName)
{
    NSArray *paperSize;
    
    NSString *	path = [[NSBundle mainBundle] pathForResource:@"PrinterList" ofType:@"plist"];
    if( [[NSFileManager defaultManager] fileExistsAtPath:path] )
    {
        NSDictionary *printerDict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSDictionary *printerInfo = [printerDict valueForKey:printerName];
        
        paperSize = [NSArray arrayWithArray:[printerInfo valueForKey:kPrinterPaperSizeKey]];

    }
    else{
        NSLog(@"Paper Size Array is not existed !");
        paperSize = nil;
    }
    
    
    return paperSize;
}

NSArray* customizedPapers(NSString *printerName)
{
	NSArray *customizedPapers = nil;
	
	if( !([printerName rangeOfString:@"QL-"].location == NSNotFound) ){
		customizedPapers = [[NSArray alloc] initWithObjects:@"51_20_700",@"58_0_700",nil];
    }
    else if (!([printerName rangeOfString:@"RJ-"].location == NSNotFound) ){
		customizedPapers = [[NSArray alloc] initWithObjects:@"58_0_4000",@"102_50_4000",nil];
    }
	else if (!([printerName rangeOfString:@"Brother TD-2130N"].location == NSNotFound) ){
		customizedPapers = [[NSArray alloc] initWithObjects:@"51_20_2000",@"58_0_2000",nil];
    }
	else if (!([printerName rangeOfString:@"Brother TD-2120N"].location == NSNotFound) ){
		customizedPapers = [[NSArray alloc] initWithObjects:@"58_0_2120",nil];
    }
    else{
        NSLog(@"No supported customized paper!");
    }
	
	return customizedPapers;
}

NSString* defaultCustomizedPaper(NSString *printerName)
{
	NSString *customizedPaper = customizedPapers(printerName).firstObject;
	
	if ( !customizedPaper ) {
		NSLog(@"No supported customized paper!");
	}
	
	return customizedPaper;
}

BOOL isAvailableDensity(NSString *printerName, NSInteger density)
{
	BOOL availableValue = FALSE;
	if ([printerName isEqualToString:kBROTHERPJ673]) {
		if ( (density>=0) && (density<=10) ) {
			availableValue = TRUE;
		}
	}
	else{
		if ( (density >= -5) && (density<=5) ) {
			availableValue = TRUE;
		}
	}
	return availableValue;
}

NSString* sharedDocumentRootPath(void)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *sharedDocumentsPath = [paths objectAtIndex:0];
	
    return sharedDocumentsPath;
}

@end
