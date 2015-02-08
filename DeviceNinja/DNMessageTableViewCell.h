//
//  DNMessageTableViewCell.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNMessage;

extern CGFloat const DNMessageTableViewCellHeight;

/**
 * A custom UITableViewCell for rendering messages for a chatroom
 */
@interface DNMessageTableViewCell : UITableViewCell

/**
 * Setting this property causes the table cell to update its display
 * based on the information in the given message
 */
@property (nonatomic, strong) DNMessage *message;

/**
 * Used to calculate the height of this table cell for its current 'message'
 */
- (CGFloat)currentRowHeight;

@end
