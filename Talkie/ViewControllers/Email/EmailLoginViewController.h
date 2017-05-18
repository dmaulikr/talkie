//
//  LoginWithEmailViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 30/10/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//


@interface EmailLoginViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>
{
    BOOL validUserName;
    BOOL userFound;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UITextField *usernameOrEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnResetPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginWithEmail;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
