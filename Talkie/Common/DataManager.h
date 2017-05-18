//
//  sharedClass.h
//  Mazeltov
//
//  Created by sajjad mahmood on 23/10/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

@interface DataManager : NSObject
{
    
}

// Bools
@property (nonatomic, assign) BOOL userDidReadTheNotification;
@property (nonatomic, assign) BOOL groupShoutOutAuthorized;
@property (nonatomic, assign) BOOL addRequestReceived;
@property (nonatomic, assign) BOOL isFirstFbLogin;
@property (nonatomic, assign) BOOL isFbUser;

//Integers
@property (nonatomic, assign) int selectedAudioIndex;
@property (nonatomic, assign) int requestBadge;

// String
@property (nonatomic, strong) NSString *selectedGroupShoutOut;
@property (nonatomic, strong) NSString *selectedTheme;
@property (nonatomic, strong) NSString *objectID;
@property (nonatomic, strong) NSString *myName;

//Images
@property (nonatomic, strong) UIImage *profilePicture;
@property (nonatomic, strong) UIImage *blurredImage;

//Arrays
@property (nonatomic, strong) NSMutableArray *retrievedFriends;
@property (nonatomic, strong) NSArray *suggestedFbFriends;
@property (nonatomic, strong) NSArray *foundUsers;

@property (nonatomic, strong) NSMutableArray *suggestedFriendsProfilePics;
@property (nonatomic, strong) NSMutableArray *suggestedFriendsUsernames;
@property (nonatomic, strong) NSMutableArray *reqSenderProfilePictures;
@property (nonatomic, strong) NSMutableArray *suggestedFriendsEmails;
@property (nonatomic, strong) NSMutableArray *friendsProfilePictures;
@property (nonatomic, strong) NSMutableArray *suggestedHideBtnFlags;
@property (nonatomic, strong) NSMutableArray *pendingFriendRequests;
@property (nonatomic, strong) NSMutableArray *friendsEmailAdresses;
@property (nonatomic, strong) NSMutableArray *friendsUsernames;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSMutableArray *reqSenderEmails;
@property (nonatomic, strong) NSMutableArray *blockedContacts;
@property (nonatomic, strong) NSMutableArray *blockedPictures;
@property (nonatomic, strong) NSMutableArray *reqSenderNames;
@property (nonatomic, strong) NSMutableArray *blockedEmails;
@property (nonatomic, strong) NSMutableArray *blockedNames;
@property (nonatomic, strong) NSMutableArray *themeAudios;
@property (nonatomic, strong) NSMutableArray *sentRequests;
@property (nonatomic, strong) NSMutableArray *themeSpecs;
@property (nonatomic, strong) NSMutableArray *fbFriends;
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic,strong) NSString * pushMessage;
//Dictionary
@property (nonatomic, strong) NSDictionary *themeInfo;

//Custom Objects
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSUserDefaults *defaults;

+ (DataManager *)sharedInstance;
+(void)sendPushNotification:(NSString*)receiverID withMessage:(NSString*)message andAudio:(NSString*)selectedAudio;
+(void)sendAddRequestNotification: (NSString*)senderID totalRequests:(NSUInteger)totalRequests andReceiverID:(NSString *) receiverID;
+(void) sendRequestAcceptedNotification:(NSString*)senderID andReceiverID:(NSString*)receiverID;
+(void)sendGroupPushNotification:(NSString*)message withAudio:(NSString*)selectedAudio;


@end
