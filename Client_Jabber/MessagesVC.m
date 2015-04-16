//
//  MessagesVC.m
//  Client_Jabber
//
//  Created by Mathieu Tan on 4/12/15.
//  Copyright (c) 2015 mataejoon. All rights reserved.
//

#import "MessagesVC.h"
#import "KeyboardBarView.h"

#import "XMPPMessageArchivingCoreDataStorage.h"

#import "SessionStore.h"

@interface MessagesVC () <NSFetchedResultsControllerDelegate, UITextFieldDelegate> {
    NSFetchedResultsController *_fetchedRC;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) KeyboardBarView *keyboardBar;

@end

@implementation MessagesVC

- (void)loadView {
    [super loadView];
    
    self.tableView.allowsSelection = false;
    [self.view becomeFirstResponder];
    
    // Add a TapGestureRecognizer to dismiss the keyboard when the view is tapped
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:recognizer];
}


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
    [self.view becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSInteger nbRows = [self.tableView numberOfRowsInSection:0];
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:nbRows -1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}


#pragma mark - TextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.keyboardBar resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        [textField resignFirstResponder];
        
        [[SessionStore sharedInstance] sendMessage:textField.text to:self.userID];
        
        textField.text = @"";
    }
    return NO;
}

#pragma mark - Keyboard management
- (UIView*)inputAccessoryView
{
    if (self.keyboardBar == nil) {
        self.keyboardBar = [[KeyboardBarView alloc] initWithDelegate:self];
    }
    
    return self.keyboardBar;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)hideKeyboard
{
    [self.keyboardBar dismissKeyboard];
}


-(void)keyboardWillChange:(NSNotification *)notification
{
    // Retrieve the keyboard begin / end frame values
    CGRect beginFrame = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame =  [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat delta = (endFrame.origin.y - beginFrame.origin.y);
    NSLog(@"Keyboard YDelta %f -> B: %@, E: %@", delta, NSStringFromCGRect(beginFrame), NSStringFromCGRect(endFrame));
    
    // Lets only maintain the scroll position if we are already scrolled at the bottom
    // or if there is a change to the keyboard position
    if([self scrolledToBottom] && fabs(delta) > 0.0) {
        
        // Construct the animation details
        NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            
            // Make the tableview scroll opposite the change in keyboard offset.
            // This causes the scroll position to match the change in table size 1 for 1
            // since the animation is the same as the keyboard expansion
            self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y - delta);
            
        } completion:nil];
    }
}

// Returns true if the table is currently scrolled to the bottom
- (bool) scrolledToBottom
{
    return self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height);
}


// Scrolls the UITableView to the bottom of the last row
- (void)scrollToBottom:(BOOL)animated
{
    NSInteger lastSection = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView] - 1;
    NSInteger rowIndex = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:lastSection] - 1;
    
    if(rowIndex >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:lastSection];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MessageCell"];
    }
    
    XMPPMessageArchiving_Message_CoreDataObject *message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([message.composing isEqualToNumber:@1])
        cell.textLabel.text = @"...";
    else {
        cell.textLabel.text = message.body;
        if ([message.outgoing isEqualToNumber:@0]) {
            cell.detailTextLabel.text = message.bareJidStr;
        } else {
            cell.detailTextLabel.text = @"";
        }
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
//            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [self insertRowAndScrollToIndexPath:newIndexPath];
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

- (void)insertRowAndScrollToIndexPath:(NSIndexPath *)newIndexPath {
    [CATransaction begin];
    
    
    [CATransaction setCompletionBlock: ^{
        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                          withRowAnimation: UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [CATransaction commit];
}
@end
