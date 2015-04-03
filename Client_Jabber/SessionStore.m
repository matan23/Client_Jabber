//
//  SessionStore.m
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/3/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import "SessionStore.h"

#import "XMPPFramework.h"


NSString *const kXMPPUserID = @"kXMPPUserID";
NSString *const kXMPPPassword = @"kXMPPPassword";


@interface SessionStore()
{
    XMPPStream          *_stream;
    XMPPReconnect       *_reconnect;
    
    XMPPRosterCoreDataStorage   *_rosterStorage;
    XMPPRoster          *_roster;
    
    BOOL                _isXmppConnected;
    
    NSString            *_password;
}

@end


@implementation SessionStore

+ (instancetype)sharedInstance {
    static SessionStore *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Setup

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupStream];
    }
    return self;
}

- (void)setupStream {
    NSAssert(_stream == nil, @"Method setupStream invoked multiple times");
    
    _stream = [XMPPStream new];
    _reconnect = [XMPPReconnect new];
    
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    _roster.autoFetchRoster = YES;
    _roster.autoAcceptKnownPresenceSubscriptionRequests = YES;

    
    [self enableModules:YES];
    [self enableListeners:YES];
    
    [self setupConnectionInfos];
}

- (void)enableModules:(BOOL)flag {
    if (flag == YES) {
        [_reconnect activate:_stream];
        [_roster activate:_stream];
    } else {
        [_reconnect deactivate];
        [_roster deactivate];
    }
}

- (void)enableListeners:(BOOL)flag {
    if (flag == YES) {
        [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    } else {
        [_stream removeDelegate:self];
        [_roster removeDelegate:self];
    }
}

- (void)setupConnectionInfos {
    #if TARGET_IPHONE_SIMULATOR
    [_stream setHostName:@"localhost"];
    #endif
//    [_stream setHostPort:5222];
}

- (void)dealloc {
    [self tearDownStream];
}

- (void)tearDownStream {
    [self enableListeners:NO];
    
    [self enableModules:NO];
    
    [_stream disconnect];
    
    _stream = nil;
    _reconnect = nil;
    
    _rosterStorage = nil;
    _roster = nil;
}

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [_stream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [_stream sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [_stream sendElement:presence];
}





#pragma mark - Public API

- (BOOL)createUsingUserID:(NSString *)userID andPassword:(NSString *)password {
    if (![_stream isDisconnected]) {
        return YES;
    }

    if (userID == nil || password == nil) {
        return NO;
    }
    
    [_stream setMyJID:[XMPPJID jidWithString:userID]];
    _password = password;
    
    NSError *error = nil;
    if (![_stream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        DDLogError(@"Error connecting: %@", error);
        return NO;
    }
    return YES;
}


- (void)destroy {
    [self goOffline];
    [_stream disconnect];
}




#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [_rosterStorage mainThreadManagedObjectContext];
}


#pragma mark - XMPSStream Delegate
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *expectedCertName = [_stream.myJID domain];
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
//    if (customCertEvaluation)
//    {
//        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
//    }
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    _isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![_stream authenticateWithPassword:_password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // A simple example of inbound message handling.
    
    if ([message isChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [_rosterStorage userForJID:[message from]
                                                                 xmppStream:_stream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                                message:body
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            // We are not active, so use a local notification instead
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!_isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}


//#pragma mark XMPPRosterDelegate
//
//- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
//                                                             xmppStream:_stream
//                                                   managedObjectContext:[self managedObjectContext_roster]];
//    
//    NSString *displayName = [user displayName];
//    NSString *jidStrBare = [presence fromStr];
//    NSString *body = nil;
//    
//    if (![displayName isEqualToString:jidStrBare])
//    {
//        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
//    }
//    else
//    {
//        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
//    }
//    
//    
//    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
//                                                            message:body
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Not implemented"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//    else
//    {
//        // We are not active, so use a local notification instead
//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        localNotification.alertAction = @"Not implemented";
//        localNotification.alertBody = body;
//        
//        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
//    }
//    
//}

@end
