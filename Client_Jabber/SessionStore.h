//
//  SessionStore.h
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/3/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendsViewInterface;

@interface SessionStore : NSObject

+ (instancetype)sharedInstance;


- (BOOL)createUsingUserID:(NSString *)userID andPassword:(NSString *)password;
- (void)destroy;

@property (nonatomic, weak)           id<FriendsViewInterface>            friendDelegate;

@end
