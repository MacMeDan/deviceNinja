//
//  DNChatter.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNSerializable.h"

/**
 * A constant defining the JSON key to access the public ID of the chatter
 */
extern NSString * const DNChatterPublicIDKey;

/**
 * A constant defining the JSON key to access the 'name' of the chatter
 */
extern NSString * const DNChatterNameKey;

@interface DNChatter : NSObject <DNSerializable>

/**
 * The unique identifier of the chatter, used to communicate with the server
 */
@property (nonatomic, copy, readonly) NSString *publicID;

/**
 * The name of the chatter
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * Create a new instance from constituent bits
 */
- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name;

/**
 * Create a new instance from a dictionary using the DNChatterPublicIDKey
 * and DNChatterNameKey keys
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 * Returns a dictionary representation of a chatter suitable
 * for JSON serialization
 */
- (NSDictionary *)dictionaryRepresentation;

@end
