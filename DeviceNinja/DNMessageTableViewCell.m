//
// DNMessageTableViewCell.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import "DNMessageTableViewCell.h"

#import "DNAppDelegate.h"
#import "DNChatService.h"
#import "DNChatter.h"
#import "DNMessage.h"

CGFloat const DNMessageTableViewCellHeight = 135;

static CGFloat const kTextInset = 10;
static CGFloat const kIncomingBubbleLeftMargin = 36;
static CGFloat const kOutgoingLeftMargin = 106;
static CGFloat const kBubbleWidth = 204;
static CGFloat const kBubbleTopMargin = 10;

@interface DNMessageTableViewCell ()

@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *messageTextLabel;
@property (nonatomic, strong) UILabel *messageTimeLabel;
@property (nonatomic, strong) UILabel *messageAuthorLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;


@end

@implementation DNMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle __unused)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
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
    self.bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
    [self.contentView addSubview:self.bubbleView];
    [self.contentView addSubview:self.logoView];
    
    self.messageTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
    self.messageTextLabel.textColor = [UIColor blackColor];
    self.messageTextLabel.numberOfLines = 0;
    self.messageTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageTextLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.messageTextLabel];
    
    self.messageTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    self.messageTimeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.messageTimeLabel];

    self.messageAuthorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageAuthorLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    self.messageAuthorLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.messageAuthorLabel];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
}

#pragma mark - Layout

- (void)dn_layoutSubviewsInternal
{
    // 1. Figure size of the message text
    NSDictionary *textAttrs = @{ NSFontAttributeName: self.messageTextLabel.font };
    CGRect textRect = [self.message.text boundingRectWithSize:CGSizeMake(kBubbleWidth, 10000)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:textAttrs
                                                      context:nil];
    
    // 2. Figure out if this is incoming or outgoing
    CGFloat leftEdge = [self isIncomingMessage:self.message] ? kIncomingBubbleLeftMargin : kOutgoingLeftMargin;
    
    // 3. Size the messageTextLabel according to 1 & 2
    self.messageTextLabel.frame = CGRectMake(leftEdge + kTextInset,
                                             kBubbleTopMargin + kTextInset,
                                             kBubbleWidth - kTextInset - kTextInset,
                                             ceilf(textRect.size.height));
    
    self.logoView.frame = CGRectMake(leftEdge - 40, kBubbleTopMargin, 40.0f, 40.0f);
    
    
    // 4. Resize the background image according to 1 & 2
    self.bubbleView.frame = CGRectMake(leftEdge,
                                       kBubbleTopMargin,
                                       kBubbleWidth,
                                       self.messageTextLabel.frame.size.height + (2 * kTextInset));
    
    // 5. Lay the messageAuthorLabel out based on 4
    [self.messageAuthorLabel sizeToFit];
    self.messageAuthorLabel.frame = CGRectMake(leftEdge + kTextInset,
                                               CGRectGetMaxY(self.bubbleView.frame),
                                               CGRectGetWidth(self.messageAuthorLabel.frame),
                                               15);
    
    // 6. Lay the messageTimeLabel out based on 4
    [self.messageTimeLabel sizeToFit];
    self.messageTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.bubbleView.frame) - CGRectGetWidth(self.messageTimeLabel.frame) - kTextInset,
                                             CGRectGetMaxY(self.bubbleView.frame),
                                             CGRectGetWidth(self.messageTimeLabel.frame),
                                             15);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self dn_layoutSubviewsInternal];
}

#pragma mark - Properties

- (void)setMessage:(DNMessage *)message
{
    if (message != _message) {
        NSAssert(message.type == DNMessageTypeChat,
                 @"%@ only supports messages of 'chat' type", NSStringFromClass([self class]));

        _message = message;
        
        NSString *imageName = ([self isIncomingMessage:message] ? @"incoming-box" : @"outgoing-box");
        self.bubbleView.image = [UIImage imageNamed:imageName];

        self.messageAuthorLabel.text = message.author;
        self.messageAuthorLabel.hidden = ! [self isIncomingMessage:message];
        self.messageTimeLabel.text = [self.dateFormatter stringFromDate:message.timestamp];

        NSString *messageText = message.text;
        if ((id)messageText == (id)[NSNull null]) {
            messageText = @"";
        }
        self.messageTextLabel.text = messageText;
        
        [self setNeedsLayout];
    }
}

#pragma mark - Public methods

- (CGFloat)currentRowHeight
{
    [self dn_layoutSubviewsInternal];
    return CGRectGetMaxY(self.messageAuthorLabel.frame);
}

#pragma mark - Private Helpers

- (BOOL)isIncomingMessage:(DNMessage *)message
{
    return ![message.author isEqualToString:[[DNChatService sharedInstance] currentUser].name];
}

@end
