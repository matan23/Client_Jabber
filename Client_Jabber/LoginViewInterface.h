//
//  LoginViewInterface.h
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/17/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPStream;

@protocol LoginViewInterface <NSObject>

- (void)userDidAuthenticate:(XMPPStream *)sender;
- (void)userDidNotAuthenticate;

@end
