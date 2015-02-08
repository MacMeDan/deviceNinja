//
//  DNChatService_NSURLConnectionRequest.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNChatService.h"

@protocol DNChatService_NSURLConnectionRequestDelegate;

/**
 * A class that wraps NSURLConnection for easier use and state-tracking
 */
@interface DNChatService_NSURLConnectionRequest : NSObject
<NSURLConnectionDelegate, NSURLConnectionDataDelegate>


/**
 * Initialize a new instance
 * @param request A NSURLRequest for the underlying connection to execute
 * @param statusCode The expected HTTP status code signaling successful execution
 * @param success The callback block to execute upon successful completion
 * @param failure The failure block to execute if the connection fails for any reason
 */
- (instancetype)initWithRequest:(NSURLRequest *)request
             expectedStatusCode:(NSInteger)statusCode
                        success:(DNChatServiceSuccess)success
                        failure:(DNChatServiceFailure)failure
                       delegate:(id<DNChatService_NSURLConnectionRequestDelegate>)delegate;

/**
 * Cancel the underlying connection
 */
- (void)cancel;

/**
 * Restarts the request
 */
- (void)restart;

/**
 * The unique identifier for the request, used to track instances separately
 */
- (NSString *)uniqueIdentifier;

@end

@protocol DNChatService_NSURLConnectionRequestDelegate <NSObject>

- (void)requestDidComplete:(DNChatService_NSURLConnectionRequest *)request;

- (void)requestRequiresAuthentication:(DNChatService_NSURLConnectionRequest *)request;

@end


