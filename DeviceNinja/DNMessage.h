//
//  DNMessage.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNSerializable.h"

/**
 * The key for the publicID property
 */
extern NSString * const DNMessagePublicIDKey;

/**
 * The key for the type property
 */
extern NSString * const DNMessageTypeKey;

/**
 * The key for the text property
 */
extern NSString * const DNMessageTextKey;

/**
 * The key for the author property
 */
extern NSString * const DNMessageAuthorKey;

/**
 * The key for timestamp property
 */
extern NSString * const DNMessageTimestampKey;

/**
 * The possible message types
 */
typedef enum {
    DNMessageTypeUnknown = -1,
    DNMessageTypeChat,
    DNMessageTypeJoin,
    DNMessageTypeLeave
} DNMessageType;

/**
 * Represents a single message
 */
@interface DNMessage : NSObject <DNSerializable>

/**
 * The unique public ID used to communicate with the backend server
 */
@property (nonatomic, copy, readonly) NSString *publicID;

/**
 * The type of message
 */
@property (nonatomic, assign, readonly) DNMessageType type;

/**
 * The text payload of the message
 */
@property (nonatomic, copy, readonly) NSString *text;

/**
 * The user-facing display name of the author or related party
 * in the message
 */
@property (nonatomic, copy, readonly) NSString *author;

/**
 * The timestamp of the message
 */
@property (nonatomic, strong, readonly) NSDate *timestamp;

/**
 * Initialize a new instance with the given parameters
 */
- (instancetype)initWithPublicID:(NSString *)publicID
                            type:(DNMessageType)type
                            text:(NSString *)text
                          author:(NSString *)author
                       timestamp:(NSDate *)date;

/**
 * Initialize a new instance with the values from the given
 * dictionary using the following keys:
 * - DNMessagePublicIDKey (NSString)
 * - DNMessageType (NSNumber)
 * - DNMessageAuthorKey (NSString)
 * - DNMessageTextKey (NSString)
 * - DNMessageTimestampKey
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 * Returns a dictionary representation of this instance with
 * the following keys:
 * - DNMessagePublicIDKey (NSString)
 * - DNMessageType (NSNumber)
 * - DNMessageAuthorKey (NSString)
 * - DNMessageTextKey (NSString)
 * - DNMessageTimestampKey
 */
- (NSDictionary *)dictionaryRepresentation;

@end
