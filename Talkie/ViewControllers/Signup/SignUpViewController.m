//
//  SignUpWithEmailViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 30/10/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "SignUpViewController.h"
#import "UsernameViewController.h"
#import "TermsOfServicesViewController.h"
#import "PrivacyPolicyViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface SignUpViewController () <UITextFieldDelegate>
{

    __weak IBOutlet TPKeyboardAvoidingScrollView *scrollView;
}

@end

@implementation SignUpViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void) viewDidLayoutSubviews
{
    if(self.view.frame.size.height<568)
    {
        NSLog(@"Frame: %f",self.view.frame.size.height);
        CGSize contentSize = CGSizeMake(320, 655);
        self.scroller.bounces = NO;
        self.scroller.backgroundColor = [UIColor clearColor];
        NSLog(@"Content Frame: %f",contentSize.height);
        [self.scroller setContentSize:contentSize];
    }
    
}


-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     // Do any additional setup after loading the view from its nib.
    emailCheck = NO;
    passwordCheck = NO;
    passwordMatchFlag = NO;
    [scrollView contentSizeToFit];
    [self.view addSubview:scrollView];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = YES;
    self.btnCreateAccount.enabled = NO;
    self.emailInput.delegate = self;
    self.passwordInput.delegate = self;
    self.passwordVerificationInput.delegate = self;
    self.passwordVerificationInput.returnKeyType = UIReturnKeyDone;
    self.passwordVerificationInput.enablesReturnKeyAutomatically = YES;
   [self.emailInput addTarget:self action:@selector(formValidation) forControlEvents:UIControlEventAllEditingEvents];
   [self.passwordInput addTarget:self action:@selector(formValidation) forControlEvents:UIControlEventAllEditingEvents];
  [self.passwordVerificationInput addTarget:self action:@selector(formValidation) forControlEvents:UIControlEventAllEditingEvents];
    self.emailInput.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordInput.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordVerificationInput.autocorrectionType = UITextAutocorrectionTypeNo;
    self.btnCreateAccount.enabled = NO;
   
    UIColor *color = [UIColor whiteColor];
    NSString * emailPlaceHolder = @"EMAIL";
    self.emailInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString: emailPlaceHolder attributes:@{NSForegroundColorAttributeName: color}];
    
    NSString * passwordPlaceHolder = @"PASSWORD";
    self.passwordInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString: passwordPlaceHolder attributes:@{NSForegroundColorAttributeName: color}];
    
    NSString * confirmPasswordPlaceHolder = @"CONFIRM PASSWORD";
    self.passwordVerificationInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString: confirmPasswordPlaceHolder attributes:@{NSForegroundColorAttributeName: color}];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)btnBackTapped:(id)sender
{
    
    LoginViewController * loginVC = [self.navigationController.viewControllers objectAtIndex:0];
    loginVC.emojiImageView.image = [UIImage imageNamed:@"talkie.png"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnCreateAccountTapped:(id)sender
{
    NSString * dummyUsername = [self randomStringWithLength:8];
    self.btnCreateAccount.enabled = NO;
    DataManager.sharedInstance.user.username = dummyUsername;
    
    NSString *trimmedEmailAddress = [self.emailInput.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    DataManager.sharedInstance.user.email =trimmedEmailAddress;
    
    DataManager.sharedInstance.user.email = [DataManager.sharedInstance.user.email lowercaseString];
    DataManager.sharedInstance.user.password = self.passwordInput.text;
    
    [self startAnimation];
    PFUser *myUser = [PFUser user];
    NSString * lowerEmail = [trimmedEmailAddress lowercaseString];
    [myUser setEmail:lowerEmail];
    [myUser setUsername:dummyUsername];
    [myUser setPassword:self.passwordInput.text];
    
    
    [myUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            DataManager.sharedInstance.objectID = myUser.objectId;
            DataManager.sharedInstance.user = myUser;
            UsernameViewController * usernameSelectionVC = [[UsernameViewController alloc] init];
            
            [self.navigationController pushViewController:usernameSelectionVC animated:YES];
            
            
            
        } else {
            //Something bad has ocurred
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            self.btnCreateAccount.enabled = YES;
            [self stopAnimation];
            [errorAlertView show];
        }
    }];

    
}

-(void) formValidation
{
    NSString * password = self.passwordInput.text;
    NSString * passwordVerificator = self.passwordVerificationInput.text;
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    self.warningLabel.text = @"";
    NSString *trimmedEmailAddress = [self.emailInput.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(self.passwordInput.text.length >7)
    {
        passwordCheck = YES;
    }
    if([emailPredicate evaluateWithObject:trimmedEmailAddress])
    {
        emailCheck = YES;
    }
    if(![emailPredicate evaluateWithObject:trimmedEmailAddress])
    {
        emailCheck = NO;
    }
    if(self.passwordVerificationInput.text.length!=0 && [password isEqualToString:passwordVerificator])
    {
        passwordMatchFlag = YES;
    }
    
    if(self.passwordVerificationInput.text.length!=0 && ![password isEqualToString:passwordVerificator])
    {
        passwordMatchFlag = NO;
    }
    
    if(passwordCheck == YES && emailCheck ==YES)
    {
        if(passwordMatchFlag == YES)
        {
            self.btnCreateAccount.enabled = YES;
            self.warningLabel.text = @" ";
        }
    }
    if(self.passwordInput.text.length<1 || self.passwordVerificationInput.text.length <1 || ![emailPredicate evaluateWithObject:trimmedEmailAddress] ||passwordMatchFlag==NO||emailCheck == NO)
    {
        self.btnCreateAccount.enabled = NO;
    }
}

-(void) warningsGenerator
{
    NSString * password = self.passwordInput.text;
    NSString * passwordVerificator = self.passwordVerificationInput.text;
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSString *trimmedEmailAddress = [self.emailInput.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(self.emailInput.text.length>1)
    {
        
        if(![emailPredicate evaluateWithObject:trimmedEmailAddress])
        {
            self.warningLabel.text = @"Please enter a valid email";
        }
    }
    if(self.passwordInput.text.length >1)
    {
        if(self.passwordInput.text.length >7 && self.passwordVerificationInput.text.length>0)
        {
            if(![password isEqualToString:passwordVerificator])
            {
                self.warningLabel.text = @"Your password doesn't match";
            }

        }
        else if(self.passwordInput.text.length<7 && self.passwordVerificationInput.text.length<1)
        {
            self.warningLabel.text = @"Please enter at least 8 characters password";
        }
    }
    
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
     [self warningsGenerator];
    return YES;
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    self.btnCreateAccount.enabled = NO;
    return YES;
}
-(void) startAnimation
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

-(void) stopAnimation
{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}


-(IBAction)btnTermsOfServicesTapped:(id)sender
{
    TermsOfServicesViewController * termsOfServicesVC = [[TermsOfServicesViewController alloc] init];
    [self.navigationController pushViewController:termsOfServicesVC animated:YES];
}

-(IBAction)btnPrivacyPolicyTapped:(id)sender
{
    PrivacyPolicyViewController * privacyPolicyVC = [[PrivacyPolicyViewController alloc] init];
    [self.navigationController pushViewController:privacyPolicyVC animated:YES];
}

-(NSString *) randomStringWithLength: (int) len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

-(void) dismissKeyboard
{
    [self.emailInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
    [self.passwordVerificationInput resignFirstResponder];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
