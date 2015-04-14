//
//  FriendsViewInterface.h
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/12/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPPresence;

@protocol FriendsViewInterface <NSObject>

- (void)newBuddyRequest:(XMPPPresence *)buddyName;
- (void)newBuddyOnline:(NSString *)buddyName;
- (void)buddyWentOffline:(NSString *)buddyName;
- (void)didDisconnect;

@end
