//
//  PrivacyPolicyViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 10/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

@interface PrivacyPolicyViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *privacyPolicyWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
