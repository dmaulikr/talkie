//
//  MenuView.h
//  NotificationView
//
//  Created by Le Abid on 06/03/2015.
//  Copyright (c) 2015 Coeus Solutions GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MenuViewDelegate
@optional
-(void) themeSelected:(NSIndexPath *) indexPath;
-(void) navigateBack;
@end
@interface MenuView : UIView <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate> {
    UIPanGestureRecognizer *panGestureRecognizer;
    NSArray * titles;
    CGPoint _previousLocation;
    NSUInteger direction;  // Replace it with ENUM. FOR now 0 is for up & 1 is for down
    //id<MenuViewDelegate> _delegate;
    UITapGestureRecognizer *tap;
    
}

@property (nonatomic) CGFloat startingYAxis;
@property (nonatomic) CGFloat maxAllowedYAxis;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (nonatomic) NSUInteger numberOfCells;
@property (nonatomic) NSUInteger singleCellHeight;
@property (nonatomic) BOOL open;
@property (weak, nonatomic) IBOutlet UIImageView *navbar1;
@property (weak, nonatomic) IBOutlet UIImageView *navbar2;
@property (nonatomic,strong) id <MenuViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomSlider;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;

- (void)adjustHeightWithSingleCellHeight:(CGFloat)_height
                           numberOfCells:(NSUInteger)cellCount;

@end
