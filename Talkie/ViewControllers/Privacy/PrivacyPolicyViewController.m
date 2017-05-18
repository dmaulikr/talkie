//
//  PrivacyPolicyViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 10/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "PrivacyPolicyViewController.h"

@interface PrivacyPolicyViewController ()

@end

@implementation PrivacyPolicyViewController
-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.privacyPolicyWebView.delegate = self;
    [self.privacyPolicyWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:TALKIE_PRIVACY_URL_STRING]]];
    self.activityIndicator.hidden = YES;
    
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    NSString * errorString = [NSString stringWithFormat:@"%@", error];
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [errorAlertView show];
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
