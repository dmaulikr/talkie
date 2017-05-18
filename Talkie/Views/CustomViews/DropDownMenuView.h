//
//  DropDownMenuView.h
//  Talkie
//
//  Created by sajjad mahmood on 16/12/2014.
//  Copyright (c) 2014 Muhammad Jabbar. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DropDownMenuViewDelegate
@required
-(void) navigateBack;
-(void) hideDropDownMenu;
@optional
-(void) themeSelected:(NSIndexPath *) indexPath;
@end

@interface DropDownMenuView : UIView<UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate>
{
    id<DropDownMenuViewDelegate> _delegate;
    
    //TESTING
    NSArray * titles;
    UITapGestureRecognizer *tap;
}
@property (weak, nonatomic) IBOutlet UIImageView *navbar1;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnTalkie;
@property (weak, nonatomic) IBOutlet UITableView *themeTableView;
@property (weak, nonatomic) IBOutlet UIImageView *navbar2;
@property (nonatomic,strong) id delegate;
@end
