//
//  EditProfileViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 13/12/2014.
//  Copyright (c) 2014 Muhammad Jabbar. All rights reserved.
//

@interface EditProfileViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    UIImage * destImage;
    BOOL profilePictureChosen;
}

@property (weak, nonatomic) IBOutlet UIImageView *frameImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateProfile;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;


@end
