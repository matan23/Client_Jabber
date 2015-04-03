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

@interface LoginVC ()

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
    
    
    if ([[SessionStore sharedInstance] createUsingUserID:user andPassword:password]) {
        [self connectionSuccess];
    } else {
        [self connectionFailure];
    }
}

- (void)connectionSuccess {
    NSLog(@"connection succeeded!");
    [self navigateToHomeVC];
}

- (void)connectionFailure {
    NSLog(@"failed to connect");
}


@end
