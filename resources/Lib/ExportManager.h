//
//  ExportManager.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 5/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebKit/WebKit.h"


typedef void (^ExportManagerCompletion)(BOOL success, NSData * _Nullable data, NSError *_Nullable);

NS_ASSUME_NONNULL_BEGIN

@interface ExportManager : NSObject<WKNavigationDelegate>
@property (strong, nonatomic) WKWebView *webView;    
@property (strong, nonatomic) ExportManagerCompletion completion;
-(void) exportPDF:(NSString *)html completion:(void (^)(BOOL, NSData *, NSError *))completion;
@end

NS_ASSUME_NONNULL_END
