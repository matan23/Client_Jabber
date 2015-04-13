//
//  FriendsVC.m
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/1/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import "FriendsVC.h"

#import "AppDelegate.h"
#import "SessionStore.h"

#import "FriendsViewInterface.h"

#import "MessagesVC.h"

@interface FriendsVC () <FriendsViewInterface>

@property (nonatomic, strong)           NSMutableArray     *datas;

@end


@implementation FriendsVC

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [SessionStore sharedInstance].friendDelegate = self;
        self.datas = [NSMutableArray array];
    }
    return self;
}

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"friendsToMessagesSegue"])
    {
        // Get reference to the destination view controller
        MessagesVC *vc = [segue destinationViewController];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
//        should not hardcore this / either pull from local database or from the session delegate
        NSString *userID = [NSString stringWithFormat:@"%@@mataejoon.io", _datas[indexPath.row]];
        vc.userID = userID;
    }
}

#pragma mark - TableView DataSource
- (void)loadTableViewDatas {
//    [FriendStore getFriendsListOnComplete:^(BOOL success, NSError *error, NSArray *list) {
//        
//        if (success) {
//            self.datas = list;
//            [self.tableView reloadData];
//        }
//        
//    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    
//    Friend *friend = self.datas[indexPath.row];
//    cell.textLabel.text = friend.name;
    cell.textLabel.text = self.datas[indexPath.row];
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self navigateToMessagesVC];
//}

#pragma mark - FriendViewInterface
- (void)buddyWentOffline:(NSString *)buddyName {
    if ([_datas containsObject:buddyName]) {
        [_datas removeObject:buddyName];
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_datas count]-1 inSection:0]];
        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (void)newBuddyOnline:(NSString *)buddyName {
    if (![_datas containsObject:buddyName]) {
        [_datas addObject:buddyName];
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_datas count]-1 inSection:0]];
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (void)didDisconnect {
    
}

@end
