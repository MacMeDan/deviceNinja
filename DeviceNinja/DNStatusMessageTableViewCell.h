//
// DNStatusMessageTableViewCell.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNMessage;

/**
 * The proper height for one of these cells (fixed)
 */
extern CGFloat const DNStatusMessageTableViewCellHeight;

/**
 * A table view cell for rendering a status message of type
 * "join" or "leave"
 */
@interface DNStatusMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

/**
 * Setting this property is ignored if the message isn't of type
 * DNMessageTypeJoin or DNMessageTypeLeave
 */
@property (nonatomic, strong) DNMessage *message;

@end
