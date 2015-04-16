//
//  SessionStore.h
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/3/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPPresence;

@protocol FriendsViewInterface;
@protocol LoginViewInterface;

@interface SessionStore : NSObject

+ (instancetype)sharedInstance;


- (void)acceptBuddyRequest:(XMPPPresence *)buddyID;
- (void)rejectBuddyRequest:(XMPPPresence *)buddyID;

- (void)sendMessage:(NSString *)message to:(NSString *)user;

- (BOOL)createUsingUserID:(NSString *)userID andPassword:(NSString *)password;
- (void)destroy;

@property (nonatomic, weak)           id<FriendsViewInterface>            friendDelegate;
@property (nonatomic, weak)           id<LoginViewInterface>                loginDelegate;

@end
