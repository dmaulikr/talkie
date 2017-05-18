//
//  EditProfileViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 13/12/2014.
//  Copyright (c) 2014 Muhammad Jabbar. All rights reserved.
//

#import "EditProfileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface EditProfileViewController ()

@end

@implementation EditProfileViewController
-(void) viewDidLayoutSubviews
{
    if(self.view.frame.size.height<568)
    {
        /*NSLog(@"Frame: %f",self.view.frame.size.height);
        CGSize contentSize = CGSizeMake(320, 655);
        self.scroller.bounces = NO;
        self.scroller.backgroundColor = [UIColor clearColor];
        NSLog(@"Content Frame: %f",contentSize.height);
        [self.scroller setContentSize:contentSize];*/
        CGRect frame = _btnUpdateProfile.frame;
        frame.origin.y = 418;
        _btnUpdateProfile.frame = frame;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    
    self.btnUpdateProfile.enabled = NO;
    //self.profilePicture  = [[UIImageView alloc] initWithFrame:CGRectMake(86, 88, 151, 151)];
    self.profilePicture.layer.cornerRadius = 30.7f;
    self.profilePicture.clipsToBounds = YES;
    self.profilePicture.image = DataManager.sharedInstance.profilePicture;
    [self.view addSubview:self.profilePicture];
}
-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    profilePictureChosen = NO;
}

-(BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    CGSize size = CGSizeMake(150, 150);
    UIImage * thumbNail = img;
    thumbNail = [self scaleImgOld:img convertToSize:size];
    destImage = thumbNail;
    
    self.btnUpdateProfile.enabled = YES;
    
    self.profilePicture.image = destImage;
    self.profilePicture.layer.cornerRadius = 30.7f;
    self.profilePicture.clipsToBounds = YES;
    
    
}

- (UIImage *)scaleImgOld:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    profilePictureChosen = YES;
    return destImage;
}



- (IBAction)btnAddPhotoTapped:(id)sender
{
    UIActionSheet *filterActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Operation"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"Choose from gallery", @"Take Photo", nil];
    
    [filterActionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    switch (buttonIndex) {
        case 0:
            [self presentViewController:imgPicker animated:YES completion:nil];
            profilePictureChosen = YES;
            break;
        case 1:
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeCamera])
            {
                imgPicker.sourceType =
                UIImagePickerControllerSourceTypeCamera;
                imgPicker.mediaTypes = @[(NSString *) kUTTypeImage];
                imgPicker.allowsEditing = YES;
                [self presentViewController:imgPicker
                                   animated:YES completion:nil];
                profilePictureChosen = YES;
            }
            
            break;
        default:
            break;
    }
}
-(void) startAnimation
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

-(void) stopAnimation
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator stopAnimating];
}



- (IBAction)btnUpdateProfileTapped:(id)sender
{
    [self startAnimation];
    PFQuery * query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error)
     {
         if(!error)
         {
             NSData *imageData1 = UIImagePNGRepresentation(destImage);
             PFFile *imageFile = [PFFile fileWithName:@"destImage.png" data:imageData1];
             [object setObject:imageFile forKey:@"profilePicture"];
             [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error)
             {
                 if(!error)
                 {
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Photo updated" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                     [self stopAnimation];
                     
                     DataManager.sharedInstance.profilePicture = destImage;
                     self.profilePicture.image = destImage;
                     self.profilePicture.layer.cornerRadius = 30.7f;
                     self.profilePicture.clipsToBounds = YES;
                     [alertView show];
                     [self.navigationController popViewControllerAnimated:YES];
                 }
             }];
         }
     
     }];
}
- (IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
