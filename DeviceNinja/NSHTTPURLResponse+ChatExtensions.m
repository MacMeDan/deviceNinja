//
//  NSHTTPURLResponse+ChatExtensions.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//
#import "NSHTTPURLResponse+ChatExtensions.h"

@implementation NSHTTPURLResponse (ChatExtensions)

- (NSString *)errorMessageWithData:(NSData *)data
{
    NSString *message = [NSString stringWithFormat:@"Unexpected response code: %li", (long)self.statusCode];
    
    if (data) {
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            NSString *errorMessage = [(NSDictionary *)json valueForKey:@"error"];
            if (errorMessage) {
                message = errorMessage;
            }
        }
    }
    
    return message;
}

@end
