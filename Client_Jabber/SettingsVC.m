//
//  SettingsVC.m
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/1/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import "SettingsVC.h"

#import "AppDelegate.h"

#import "SessionStore.h"

@interface SettingsVC ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *domainTF;
@property (weak, nonatomic) IBOutlet UITextField *hostNameTF;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userid"];
    NSString *domain = [[NSUserDefaults standardUserDefaults] stringForKey:@"domain"];
    NSString *hostName = [[NSUserDefaults standardUserDefaults] stringForKey:@"hostname"];
    self.userNameTF.text = userName;
    self.domainTF.text = domain;
    self.hostNameTF.text = hostName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logOutBtnPressed:(id)sender {
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginVC"];
    [[SessionStore sharedInstance] destroy];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
