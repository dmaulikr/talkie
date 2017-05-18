//
//  CustomView.h
//  Talkie
//
//  Created by sajjad mahmood on 12/12/2014.
//  Copyright (c) 2014 Muhammad Jabbar. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class CustomView;
@protocol CustomViewDelegate
@required
-(void) shoutOutAuthorized;
//- (void)alertView:(CustomView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
@interface CustomView : UIView
{
    id<CustomViewDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;
-(IBAction)btnOkTapped:(id)sender;
@end
