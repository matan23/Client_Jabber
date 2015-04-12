//
//  MessagesVC.m
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/12/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import "MessagesVC.h"

@interface MessagesVC () {
    NSMutableArray  *_messages;
}

@end

@implementation MessagesVC

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _messages = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"didReceiveMessage" object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            NSDictionary *datas = note.userInfo;
            
            [_messages addObject:datas[@"content"]];
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_messages count]-1 inSection:0]];
            [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
        }];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    cell.textLabel.text = _messages[indexPath.row];
    
    return cell;
}

@end
