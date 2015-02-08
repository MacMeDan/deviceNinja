//
//  DNCreateChatroomViewControllmer.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//
#import "DNCreateChatroomViewController.h"

#import "DNAppDelegate.h"
#import "DNChatService.h"
#import "DNChatroom.h"
#import "DNChatroomMessagesViewController.h"

@interface DNCreateChatroomViewController ()

@property (nonatomic, strong) DNChatroom *chatroom;
@property (nonatomic, strong) NSString *createRoomRequestID;

@end

@implementation DNCreateChatroomViewController

- (void)dealloc
{
    if (self.createRoomRequestID) {
        [[DNChatService sharedInstance] cancelRequestWithIdentifier:self.createRoomRequestID];
    }
}

#pragma mark - Actions

- (IBAction)didTapCreateRoom:(id)sender
{
    [self showWaitUI];

    __weak typeof(self) weakSelf = self;
    DNChatService *service = [DNChatService sharedInstance];
    self.createRoomRequestID = [service createChatroomWithName:self.roomNameField.text
                                                       success:^(DNChatroom *chatroom) {
                                                           weakSelf.createRoomRequestID = nil;
                                                           weakSelf.chatroom = chatroom;
                                                           [weakSelf joinChatroom];
                                                       }
                                                       failure:^(NSError *error) {
                                                           weakSelf.createRoomRequestID = nil;
                                                           [weakSelf hideWaitUI];
                                                           
                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                           message:error.localizedDescription
                                                                                                          delegate:nil
                                                                                                 cancelButtonTitle:@"OK"
                                                                                                 otherButtonTitles:nil];
                                                           [alert show];
                                                       }];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"JoinChatroom"]) {
        DNChatroomMessagesViewController *chatVC = (DNChatroomMessagesViewController *)segue.destinationViewController;
        chatVC.chatroom = self.chatroom;
    }
}

#pragma mark - Private helpers

- (void)showWaitUI
{
    self.waitView.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.waitView.alpha = 1;
                         self.createRoomButton.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         self.createRoomButton.hidden = YES;
                     }];
}

- (void)hideWaitUI
{
    self.createRoomButton.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.waitView.alpha = 0;
                         self.createRoomButton.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         self.waitView.hidden = YES;
                     }];
}

- (void)joinChatroom
{
    [self performSegueWithIdentifier:@"JoinChatroom" sender:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.createRoomButton.enabled = ([textField.text length] > 0);
    return YES;
}

@end
