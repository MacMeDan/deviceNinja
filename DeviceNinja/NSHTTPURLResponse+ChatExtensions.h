//
//  NSHTTPURLResponse+ChatExtensions.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (ChatExtensions)

/**
 * Attempt to extract an error message from the given data object
 * (assumes JSON payload), otherwise return default error message.
 */
- (NSString *)errorMessageWithData:(NSData *)data;

@end
