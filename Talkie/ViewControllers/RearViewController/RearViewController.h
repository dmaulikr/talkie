//
//  RearViewController.h
//  Talkie
//
//  Created by Muhammad Jabbar on 11/26/14.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

@interface RearViewController : UIViewController
{
    NSMutableDictionary * myDictionary;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UILabel * badge;
@property UIImageView * badgeBackground;
@property UIImageView * myImageView;
-(void) setUpTheme;
@end
