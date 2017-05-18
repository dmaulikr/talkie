//
//  DropDownMenuView.m
//  Talkie
//
//  Created by sajjad mahmood on 16/12/2014.
//  Copyright (c) 2014 Muhammad Jabbar. All rights reserved.
//

#import "ThemeTableViewCell.h"
@implementation DropDownMenuView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
    // Initialization code
    //ORIGINAL 82
    _themeTableView.delegate = self;
    _themeTableView.dataSource = self;
   // _themeTableView.clipsToBounds = YES;
    [self setUpTheme];
}

-(IBAction) btnTalkieTapped:(id)sender
{
    //[self removeFromSuperview];
    /*CATransition *transition = [CATransition animation];
    transition.duration = 0.7;
    transition.type = kCATransitionFromBottom; //choose your animation
    [self.layer addAnimation:transition forKey:nil];*/
    //[self removeFromSuperview];
    
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:_delegate
                                   selector:@selector(hideDropDownMenu) userInfo:nil repeats:NO];
    //[self removeFromSuperview];


}
-(IBAction)btnBackTapped:(id)sender
{
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:_delegate
                                   selector:@selector(navigateBack) userInfo:nil repeats:NO];
    [self removeFromSuperview];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    //UITableViewCell *cell =  [_themeTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
   ThemeTableViewCell *cell = (ThemeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.delegate themeSelected:indexPath];
    
    
}

-(void) selectionMade: (UITapGestureRecognizer *)recognizer
{
    CGPoint p = [recognizer locationInView:_themeTableView];
    NSIndexPath *indexPath = [_themeTableView indexPathForRowAtPoint:p];
    [_delegate themeSelected:indexPath];
    [self setUpTheme];
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
    [_btnTalkie setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
}

-(NSString*) generateTitleString: (NSString*) key
{
    NSString *titleString;
    titleString = [[DataManager sharedInstance].themeInfo objectForKey:key];
    return titleString;
}

@end
