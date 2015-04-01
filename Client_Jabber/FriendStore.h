//
//  FriendStore.h
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/1/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GetFriendListBlock)(BOOL success, NSError *error, NSArray *list);

@interface FriendStore : NSObject

+ (void)getFriendsListOnComplete:(GetFriendListBlock)block;

@end
