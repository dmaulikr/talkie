//
//  UserNameSettingViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 30/10/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

@interface UsernameViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate,UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate,SWRevealViewControllerDelegate>
{
    UIImage * destImage;
    NSData * imageData;
    bool profilePictureChosen;
    bool validUsername;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureFrame;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnCompleteProfile;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UILabel *variableLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inputSeperatorLine;

@end
