//
//  CustomView.m
//  Talkie
//
//  Created by sajjad mahmood on 12/12/2014.
//  Copyright (c) 2014 Muhammad Jabbar. All rights reserved.
//

#import "CustomView.h"
@implementation CustomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)btnOkTapped:(id)sender
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:GROUP_SHOUT_OUT_AUTHORIZED object:nil];
    /*if (self.delegate != nil && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        
    }*/
    
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:_delegate
                                   selector:@selector(shoutOutAuthorized) userInfo:nil repeats:NO];
    [self removeFromSuperview];
    
}


- (IBAction)btnCancelTapped:(id)sender
{
    [self removeFromSuperview];
    
}
@end
