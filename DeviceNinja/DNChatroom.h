//
//  DNChatroom.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNSerializable.h"

/**
 * The dictionary key for the publicID property
 */
extern NSString * const DNChatroomPublicIDKey;

/**
 * The dictionary key for the name property
 */
extern NSString * const DNChatroomNameKey;

/**
 * The dictionary key for the chatters property
 */
extern NSString * const DNChatroomChattersKey;

/**
 * Represents a single chatroom
 */
@interface DNChatroom : NSObject <DNSerializable>

/**
 * The public ID used to communicate with the backend server
 */
@property (nonatomic, copy, readonly) NSString *publicID;

/**
 * The user-facing public name of the chatroom
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The chatters in the chatroom
 */
@property (nonatomic, copy, readonly) NSArray *chatters;

/**
 * Initialize a new instance with the given public ID, name and chatters
 */
- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name chatters:(NSArray *)chatters;

/**
 * Initialize a new instance with a dictionary with keys matching
 * DNChatroomPublicID and DNChatroomName
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 * Returns a dictionary representation of this instance with
 * using the DNChatroomPublicIDKey and DNChatroomNameKey keys
 */
- (NSDictionary *)dictionaryRepresentation;

@end

