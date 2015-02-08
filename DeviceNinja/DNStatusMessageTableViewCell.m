//
//  DNStatusMessageTableViewCell.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import "DNStatusMessageTableViewCell.h"

#import "DNMessage.h"

CGFloat const DNStatusMessageTableViewCellHeight = 20;

@implementation DNStatusMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    self.textLabel.textColor = [UIColor darkGrayColor];
}

#pragma mark - Properties

- (void)setMessage:(DNMessage *)message
{
    if (message != _message) {
        NSAssert(message.type == DNMessageTypeJoin || message.type == DNMessageTypeLeave,
                 @"Invalid message type: %i", message.type);
        
        _message = message;
        
        UIFont *lightFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        UIFont *mediumFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
        NSMutableAttributedString *statusStr = [[NSMutableAttributedString alloc] init];
        NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:message.author
                                                                      attributes:@{NSFontAttributeName:lightFont}];
        [statusStr appendAttributedString:nameStr];
        
        NSString *suffixStr = [NSString stringWithFormat:@" has %@", message.type == DNMessageTypeLeave ? @"left" : @"joined"];
        [statusStr appendAttributedString:[[NSAttributedString alloc] initWithString:suffixStr
                                                                          attributes:@{NSFontAttributeName:mediumFont}]];
        
        self.statusLabel.attributedText = statusStr;
    }
}

@end
