//
//  DNChatroomsViewController.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DNAuthenticationViewController.h"
#import "DNCreateChatroomViewController.h"

/**
 * A view-controller that displays the currently-available chatrooms
 */
@interface DNChatroomsViewController : UITableViewController <DNAuthenticationViewControllerDelegate>

- (IBAction)didTapSignOut:(id)sender;

@end
