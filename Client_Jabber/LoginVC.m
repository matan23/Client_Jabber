//
//  ViewController.m
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/1/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import "LoginVC.h"

#import "AppDelegate.h"

#import "SessionStore.h"

#import "LoginViewInterface.h"

#import "XMPPStream.h"

@interface LoginVC () <LoginViewInterface>

@property (weak, nonatomic) IBOutlet UITextField *loginTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)navigateToHomeVC {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UIViewController *vc = [delegate.mainStoryboard instantiateViewControllerWithIdentifier:@"homeVC"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
}

#pragma mark - UI Events

- (IBAction)loginBtnTapped:(id)sender {
    
    [self connectUsingUser:self.loginTF.text andPassword:self.passwordTF.text];
}

#pragma mark - Helpers To Be Moved?
- (void)connectUsingUser:(NSString *)user andPassword:(NSString *)password {
    [[SessionStore sharedInstance] createUsingUserID:user andPassword:password];
    [SessionStore sharedInstance].loginDelegate = self;
}

#pragma mark - LoginViewInterface
- (void)userDidAuthenticate:(XMPPStream *)sender {
    [self persistLogin:sender];
    [self navigateToHomeVC];
}

- (void)persistLogin:(XMPPStream *)sender {
    NSArray *strings = [self.loginTF.text componentsSeparatedByString:@"@"];
    NSString *userID = [strings firstObject];
    NSString *domain = [strings objectAtIndex:1];
    NSString *pwd = self.passwordTF.text;
    
    [[NSUserDefaults standardUserDefaults] setValue:self.loginTF.text forKey:@"jid"];
    [[NSUserDefaults standardUserDefaults] setValue:sender.hostName forKey:@"hostname"];
    [[NSUserDefaults standardUserDefaults] setValue:userID forKey:@"userid"];
    [[NSUserDefaults standardUserDefaults] setValue:domain forKey:@"domain"];
    [[NSUserDefaults standardUserDefaults] setValue:self.passwordTF.text forKey:@"pwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)userDidNotAuthenticate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Please check login or password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
