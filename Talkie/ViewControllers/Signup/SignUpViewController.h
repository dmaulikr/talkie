//
//  SignUpWithEmailViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 30/10/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
// gotta add url in this

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    bool emailCheck;
    bool passwordCheck;
    bool passwordMatchFlag;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordVerificationInput;
@property (weak, nonatomic) IBOutlet UIButton *btnCreateAccount;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
