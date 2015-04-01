//
//  FriendsVC.m
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/1/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import "FriendsVC.h"

#import "FriendStore.h"
#import "Friend.h"

#import "AppDelegate.h"

@interface FriendsVC ()

@property (nonatomic, strong)           NSArray     *datas;

@end



@implementation FriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadTableViewDatas];
}

#pragma mark - UI Events


#pragma mark - Navigation
- (void)navigateToMessagesVC {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UIViewController *vc = [delegate instantiateViewControllerWithIdentifier:@"messagesVC"];
    
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - TableView DataSource
- (void)loadTableViewDatas {
    [FriendStore getFriendsListOnComplete:^(BOOL success, NSError *error, NSArray *list) {
        
        if (success) {
            self.datas = list;
            [self.tableView reloadData];
        }
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    
    Friend *friend = self.datas[indexPath.row];
    cell.textLabel.text = friend.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self navigateToMessagesVC];
}

@end
