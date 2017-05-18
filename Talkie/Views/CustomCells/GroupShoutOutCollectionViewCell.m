//
//  GroupShoutOutCollectionViewCell.m
//  Talkie
//
//  Created by sajjad mahmood on 30/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "GroupShoutOutCollectionViewCell.h"

@implementation GroupShoutOutCollectionViewCell
@synthesize profilePicture;
@synthesize imageFrame;

/*- (id)initWithFrame:(CGRect)frame
{
    self.imageFrame = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.profilePicture = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.imageFrame];
    [self.contentView addSubview:self.profilePicture];
    if (self) {
        // Initialization code
    }
    return self;
*/
- (void)awakeFromNib {
    // Initialization code
    
    NSString *themeId = [[DataManager sharedInstance].themeInfo objectForKey:IMAGE_SHAPE];
    if([themeId length]==0)
    {
        themeId = @"rounded_square";
    }
    if([themeId isEqualToString:@"rounded_square"])
    {
        self.profilePicture.layer.cornerRadius = 8.0f;
        self.profilePicture.clipsToBounds = YES;
    }
    else if([themeId isEqualToString:@"square"])
    {
        self.profilePicture.clipsToBounds = YES;
    }
    else if ([themeId isEqualToString:@"round"])
    {
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = YES;
    }
    else
    {
        self.profilePicture.layer.cornerRadius = 8.0f;
        self.profilePicture.clipsToBounds = YES;
    }
    
}
-(void)setImageFrame:(UIImage *)image :(UIImage *) image2
{
    self.imageFrame.image = image;
    self.profilePicture.image = image2;
}
@end
