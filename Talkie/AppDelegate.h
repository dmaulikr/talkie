//
//  AppDelegate.h
//  Talkie
// THE SYNCHRONUS VERSION: Jabbar 
//  Created by sajjad mahmood on 29/10/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *navController;
    BOOL userFound;
    BOOL didSendNotificationAlready;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, retain) UINavigationController * navController;

@end

