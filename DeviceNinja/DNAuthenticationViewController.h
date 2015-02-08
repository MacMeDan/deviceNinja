//
//  DNAuthenticationViewController.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DNAuthenticationViewControllerDelegate;

@interface DNAuthenticationViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *serverURLField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *authenticationLabel;
@property (weak, nonatomic) IBOutlet UIView *waitView;
@property (nonatomic, weak) id<DNAuthenticationViewControllerDelegate> delegate;

- (IBAction)didTapSignIn:(id)sender;
- (IBAction)didTapSignUp:(id)sender;

@end

@protocol DNAuthenticationViewControllerDelegate

- (void)authenticationViewControllerSucceeded:(DNAuthenticationViewController *)authVC;

@end