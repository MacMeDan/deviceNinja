//
//  DNAuthenticationViewController.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import "DNAuthenticationViewController.h"

#import "DNAppDelegate.h"
#import "DNChatService.h"

@implementation DNAuthenticationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.serverURLField.text = [[[DNChatService sharedInstance] serverRoot] absoluteString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)didTapSignIn:(id)sender
{
    self.authenticationLabel.text = @"Signing In…";

    __weak typeof(self) weakSelf = self;
    NSURL *URL = [NSURL URLWithString:self.serverURLField.text];
    
    [self showWaitUI];

    [[DNChatService sharedInstance] signInWithUserName:self.usernameField.text
                                                   password:self.passwordField.text
                                                  serverURL:URL
                                                    success:^(DNChatter *chatter) {
                                                        [weakSelf hideWaitUI];
                                                        [weakSelf.delegate authenticationViewControllerSucceeded:weakSelf];
                                                    }
                                                    failure:^(NSError *error) {
                                                        [weakSelf hideWaitUI];
                                                        
                                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Sign-in"
                                                                                                        message:error.localizedDescription
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                        [alert show];
                                                    }];
}

- (IBAction)didTapSignUp:(id)sender
{
    self.authenticationLabel.text = @"Signing Up…";

    __weak typeof(self) weakSelf = self;
    NSURL *URL = [NSURL URLWithString:self.serverURLField.text];
    
    [self showWaitUI];

    [[DNChatService sharedInstance] registerNewUserWithName:self.usernameField.text
                                                        password:self.passwordField.text
                                                       serverURL:URL
                                                         success:^(DNChatter *chatter) {
                                                             [weakSelf hideWaitUI];
                                                             [weakSelf.delegate authenticationViewControllerSucceeded:weakSelf];
                                                         }
                                                         failure:^(NSError *error) {
                                                             [weakSelf hideWaitUI];
                                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Sign-in"
                                                                                                             message:error.localizedDescription
                                                                                                            delegate:nil
                                                                                                   cancelButtonTitle:@"OK"
                                                                                                   otherButtonTitles:nil];
                                                             [alert show];
                                                         }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self checkTextFieldsForButtonState];
    
    return YES;
}

#pragma mark - Helpers

- (void)showWaitUI
{
    self.signInButton.hidden = YES;
    self.signUpButton.hidden = YES;
    self.waitView.hidden = NO;
}

- (void)hideWaitUI
{
    self.signInButton.hidden = NO;
    self.signUpButton.hidden = NO;
    self.waitView.hidden = YES;
}

- (void)checkTextFieldsForButtonState
{
    BOOL usernameReady = self.usernameField.text.length > 0;
    BOOL passwordReady = self.passwordField.text.length > 0;
    
    NSString *serverURL = self.serverURLField.text;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^http(s)?://"
                                                                            options:0
                                                                              error:nil];
    
    NSRange range = NSMakeRange(0, serverURL.length);
    BOOL serverReady = [regexp firstMatchInString:serverURL options:0 range:range] != nil;
    
    self.signInButton.enabled = usernameReady && passwordReady && serverReady;
    self.signUpButton.enabled = self.signInButton.enabled;
}

@end
