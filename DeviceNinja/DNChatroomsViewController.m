//
//  DNChatroomsViewController.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import "DNChatroomsViewController.h"

#import "DNAppDelegate.h"
#import "DNChatService.h"
#import "DNChatroom.h"
#import "DNChatroomMessagesViewController.h"

@interface DNChatroomsViewController ()

@property (nonatomic, strong) NSArray *chatrooms;

@end

@implementation DNChatroomsViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authenticationRequired:)
                                                 name:DNChatcaveServiceAuthRequiredNotification
                                               object:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    [self.refreshControl addTarget:self action:@selector(didPullRefresh:) forControlEvents:UIControlEventValueChanged];
    
    [self fetchChatrooms];
}

#pragma mark - Notifications

- (void)authenticationRequired:(NSNotification *)notification
{
    if (self.presentedViewController == nil) {
        [self performSegueWithIdentifier:@"AuthenticationSegue" sender:nil];
    }
}

#pragma mark - DNAuthenticationViewControllerDelegate

- (void)authenticationViewControllerSucceeded:(DNAuthenticationViewController *)authVC
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self fetchChatrooms];
}

#pragma mark - Properties

- (NSArray *)chatrooms
{
    if (_chatrooms == nil) {
        _chatrooms = [[NSArray alloc] init];
    }
    
    return _chatrooms;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.chatrooms count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatroomCell"];
    
    DNChatroom *chatroom = self.chatrooms[indexPath.row];
    cell.textLabel.text = chatroom.name;
    
    NSUInteger chatterCount = [chatroom.chatters count];
    if (chatterCount == 1) {
        cell.detailTextLabel.text = @"1 chatter";
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu chatters", (unsigned long)chatterCount];
    }

    return cell;
}

#pragma mark - Segues

- (IBAction)unwindToChatroomsScene:(UIStoryboardSegue *)segue
{
    [self fetchChatrooms];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AuthenticationSegue"]) {
        DNAuthenticationViewController *authVC = (DNAuthenticationViewController *)segue.destinationViewController;
        authVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"JoinChatroom"]) {
        NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
        DNChatroom *chatroom = self.chatrooms[selectedPath.row];
        
        DNChatroomMessagesViewController *vc = (DNChatroomMessagesViewController *)segue.destinationViewController;
        vc.chatroom = chatroom;
    }
}

#pragma mark - Actions

- (void)didPullRefresh:(id)sender
{
    [self fetchChatrooms];
}

- (IBAction)didTapSignOut:(id)sender
{
    __weak typeof(self) weakSelf = self;

    DNChatService *service = [DNChatService sharedInstance];

    [service signoutUserWithSuccess:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        DNAuthenticationViewController *authVC = (DNAuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AuthenticationScene"];
        authVC.delegate = weakSelf;
        [weakSelf presentViewController:authVC animated:YES completion:NULL];
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to sign out"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - Private helpers

- (void)fetchChatrooms
{
    __weak typeof(self) weakSelf = self;

    DNChatService *service = [DNChatService sharedInstance];

    if (service.serverRoot) {
        [service fetchChatroomsSuccess:^(NSArray *chatrooms) {
            [weakSelf.refreshControl endRefreshing];
            weakSelf.chatrooms = chatrooms;
            [weakSelf.tableView reloadData];
        } failure:^(NSError *error) {
            [weakSelf.refreshControl endRefreshing];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
    else {
        [self performSegueWithIdentifier:@"AuthenticationSegue" sender:nil];
    }
}

@end
