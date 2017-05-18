//
//  MenuView.m
//  NotificationView
//
//  Created by Le Abid on 06/03/2015.
//  Copyright (c) 2015 Coeus Solutions GmbH. All rights reserved.
//

#import "MenuView.h"

#define BOTTOM_BAR_HEIGHT 20
#define MENU_BUTTON_HEIGHT 44
#define TOP_VIEW_HEIGHT 64.0
#import "ThemeTableViewCell.h"
@implementation MenuView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.startingYAxis = 0;
    self.numberOfCells = 3;
    self.singleCellHeight = 100;
    self.tableView.rowHeight = self.singleCellHeight;
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.bottomSlider addGestureRecognizer:panGestureRecognizer];
    [_btnBack addTarget:self action:@selector(btnBackTapped) forControlEvents:UIControlEventTouchUpInside];
    [self setUpTheme];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}


- (void)adjustHeightWithSingleCellHeight:(CGFloat)_height
                           numberOfCells:(NSUInteger)cellCount {
    
    CGRect availableRect = self.superview.bounds;
    CGRect currentFrame = self.frame;
    currentFrame.size.width = availableRect.size.width;
    CGFloat mandatoryHeight = TOP_VIEW_HEIGHT + (BOTTOM_BAR_HEIGHT/2.0) + MENU_BUTTON_HEIGHT;
    
    self.numberOfCells = cellCount;
    self.singleCellHeight = _height;
    self.tableView.rowHeight = _height;
    
    CGFloat tableNeededHeight = self.numberOfCells * self.singleCellHeight;
    CGFloat availableTableHeight = 0;
    
    if ((mandatoryHeight+tableNeededHeight)>availableRect.size.height) {
        currentFrame.size.height = availableRect.size.height;
        availableTableHeight = currentFrame.size.height - mandatoryHeight;
        self.tableView.scrollEnabled = YES;
    }
    else {
        currentFrame.size.height = mandatoryHeight+tableNeededHeight;
        availableTableHeight = tableNeededHeight;
        self.tableView.scrollEnabled = NO;
    }
    self.frame = currentFrame;
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = availableTableHeight;
    self.tableView.frame = tableFrame;
    
    self.bottomSlider.frame = CGRectMake(0, tableFrame.origin.y+tableFrame.size.height, currentFrame.size.width, BOTTOM_BAR_HEIGHT);
    self.hideButton.center = CGPointMake(currentFrame.size.width/2.0, (currentFrame.size.height - MENU_BUTTON_HEIGHT/2.0));
    
    [self.tableView reloadData];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)dragView:(UIPanGestureRecognizer*)sender {
    
    // TO DOs:
    // 1. Check with the help of self.startingYAxis and self.maxAllowedYAxis to return if user scrolls further down
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _previousLocation = [sender translationInView:self.superview];
        direction = 0; // Up
    } else if ([sender state] == UIGestureRecognizerStateChanged)
    {
        CGPoint gesturePosition = [sender translationInView:self.superview];
        
        if (_previousLocation.y > gesturePosition.y) {
            NSLog(@"Up");
            direction = 0;
        } else {
            NSLog(@"down");
            direction = 1;
        }
        
        _previousLocation = gesturePosition;
        
        CGPoint newPosition = gesturePosition;
        
        newPosition.x = self.frame.size.width / 2;
        
        if (self.open)
        {
            if (newPosition.y < 0)
            {
                newPosition.y += ((self.frame.size.height / 2));
                [self setCenter:newPosition];
            }
        }
        else
        {
            newPosition.y += -((self.frame.size.height / 2));
            
            if (newPosition.y <= ((self.frame.size.height / 2)))
            {
                [self setCenter:newPosition];
            }
        }
    }
    else if ([sender state] == UIGestureRecognizerStateEnded)
    {
        if (direction==0) {
            [self.hideButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        else {
            // Get it down again
            __block CGRect currentFrame = self.frame;
            currentFrame.origin.y  = 0;
            
            [UIView animateWithDuration:0.1
                             animations:^{
                                 self.frame = currentFrame;
                             }];
        }
        
    }
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfCells;
}

// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThemeTableViewCell *cell = (ThemeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    titles = [[NSArray alloc] initWithObjects:@"Jungle",@"Australia", @"Irish", nil];
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        NSArray *cellView = [[NSBundle mainBundle] loadNibNamed:@"ThemeTableViewCell" owner:nil options:nil];
        cell = (ThemeTableViewCell *)[cellView objectAtIndex:0];
        cell.themeName.text = [titles objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor clearColor];
        cell.themePreview.userInteractionEnabled = NO;
        cell.contentView.gestureRecognizers = nil;
        
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectionMade:)];
        [cell addGestureRecognizer:tap];
        tap.delegate = self;
    }
    NSUInteger i = (indexPath.row+1);
    cell.tag = indexPath.row;
    NSString *titleString = [NSString stringWithFormat:@"theme%lu_preview",i];
    cell.themePreview.image = [UIImage imageNamed:titleString];
    return cell;
}

-(void) selectionMade: (UITapGestureRecognizer *)recognizer
{
    CGPoint p = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
   // NSUInteger x = indexPath.row;
    [_delegate themeSelected:indexPath];
    [self setUpTheme];
}
#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.hideButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    [_delegate themeSelected:indexPath];
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void) setUpTheme
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *themeNumber = [defaults objectForKey:@"themeId"];
    NSString *themeId = [NSString stringWithFormat:@"theme%@",themeNumber];
    NSString *titleString;
    if(themeNumber==nil)
    {
        themeId = @"theme1";
    }
    NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
    
    [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
    titleString = [self generateTitleString:DROP_DOWN_BTN_BACK];
    [_btnBack setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:DROP_DOWN_NAV_BAR1];
    _navbar1.image = [UIImage imageNamed:titleString];
    
    
    titleString = [self generateTitleString:DROP_DOWN_NAV_BAR2];
    _navbar2.image = [UIImage imageNamed:titleString];
    
    titleString = [self generateTitleString:BTN_PULLDOWN];
    [_hideButton setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
}

-(NSString*) generateTitleString: (NSString*) key
{
    NSString *titleString;
    titleString = [[DataManager sharedInstance].themeInfo objectForKey:key];
    return titleString;
}

-(void) btnBackTapped
{
    [_delegate navigateBack];
}

@end
