//
//  CollectionViewCellSubClass.m
//  Talkie
//
//  Created by sajjad mahmood on 01/12/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "CollectionViewCellSubClass.h"

@implementation CollectionViewCellSubClass
-(id) init
{
    self = [super init];
    if (self)
    {
        self.imageFrame = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.profilePicture = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.profilePicture.clipsToBounds = YES;
    }
    return self;
}
@end
