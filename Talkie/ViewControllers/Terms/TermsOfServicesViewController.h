//
//  TermsOfServicesViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 10/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

@interface TermsOfServicesViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *termsOfServicesWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property BOOL loadCustomUrl;
@property NSString *customUrl;
@end
