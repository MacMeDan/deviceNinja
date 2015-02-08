//
//  DNSerializable.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DNSerializable <NSObject>

/**
 * Initialize a new instance based on the properties and structure
 * of the given dictionary
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 * Return a dictionary representing the data and structure of this
 * object. This is effectively the inverse of -initWithDictionary
 */
- (NSDictionary *)dictionaryRepresentation;

@end
