//
//  ThemeTableViewCell.m
//  Talkie
//
//  Created by sajjad mahmood on 16/12/2014.
//  Copyright (c) 2014 Muhammad Jabbar. All rights reserved.
//

#import "ThemeTableViewCell.h"

@implementation ThemeTableViewCell

- (void)awakeFromNib {
    // Initialization code
    //ORIGINAL 82
    self.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
