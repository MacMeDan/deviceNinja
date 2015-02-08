//
// DNChatroomMessagesViewController.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNChatroom;

@interface DNChatroomMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) DNChatroom *chatroom;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *sendBoxView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendBoxViewBottomConstraint;

- (IBAction)sendMessage:(id)sender;
- (IBAction)didSwipeDown:(id)sender;

@end
