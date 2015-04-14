//
//  MessagesVC.m
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/12/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import "MessagesVC.h"

#import "XMPPMessageArchivingCoreDataStorage.h"

@interface MessagesVC () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedRC;
}

@end

@implementation MessagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    assert(self.userID);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"error: %@", [error description]);
    }
    [self fetchedResultsController].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

//
//-(void)print:(NSMutableArray*)messages{
//    @autoreleasepool {
//        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
//            NSLog(@"messageStr param is %@",message.messageStr);
//            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
//            NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
//            NSLog(@"NSCore object id param is %@",message.objectID);
//            NSLog(@"bareJid param is %@",message.bareJid);
//            NSLog(@"bareJidStr param is %@",message.bareJidStr);
//            NSLog(@"body param is %@",message.body);
//            NSLog(@"timestamp param is %@",message.timestamp);
//            NSLog(@"outgoing param is %d",[message.outgoing intValue]);
//        }
//    }
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    XMPPMessageArchiving_Message_CoreDataObject *message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([message.composing isEqualToNumber:@1])
        cell.textLabel.text = @"...";
    else {
        cell.textLabel.text = message.body;
        cell.detailTextLabel.text = message.bareJidStr;
    }
    
    return cell;
}


- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@", self.userID];
    [request setPredicate:predicate];
    
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _fetchedRC = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[storage mainThreadManagedObjectContext]  sectionNameKeyPath:nil cacheName:@"MessagesContactListCache"];
    
    return _fetchedRC;
}


#pragma mark - FRC Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
        default:
            break;
    }
}
@end
