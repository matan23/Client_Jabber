//
//  FriendStore.m
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/1/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import "FriendStore.h"

#import "Friend.h"

@implementation FriendStore

+ (void)getFriendsListOnComplete:(GetFriendListBlock)block {
    
    NSMutableArray *friendList = [NSMutableArray array];
    
    Friend *friend = [Friend new];
    friend.name = @"jero";
    
    [friendList addObject:friend];
    
    block(YES, nil, friendList);
}

@end
