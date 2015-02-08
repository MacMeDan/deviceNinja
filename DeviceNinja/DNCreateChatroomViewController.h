//
//  DNCreateChatroomViewControllmer.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol DNCreateChatroomViewControllerDelegate;

/**
 * A view-controller from which to add a new chatroom
 */
@interface DNCreateChatroomViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *roomNameField;
@property (weak, nonatomic) IBOutlet UIButton *createRoomButton;
@property (weak, nonatomic) IBOutlet UIView *waitView;

- (IBAction)didTapCreateRoom:(id)sender;

@end
