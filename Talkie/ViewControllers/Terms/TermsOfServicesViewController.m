//
//  TermsOfServicesViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 10/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "TermsOfServicesViewController.h"
#import "SignUpViewController.h"
@interface TermsOfServicesViewController ()

@end

@implementation TermsOfServicesViewController

-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

-(void) viewWillDisappear:(BOOL)animated
{
    _loadCustomUrl = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.termsOfServicesWebView.delegate = self;
    
    if(_loadCustomUrl)
    {
        [self.termsOfServicesWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_customUrl]]];
    }
    else
    {
        [self.termsOfServicesWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:TALKIE_TERMS_URL_STRING]]];
    }
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



@end
