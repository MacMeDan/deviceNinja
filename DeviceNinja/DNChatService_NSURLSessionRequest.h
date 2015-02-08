//
//  DNChatService_NSURLSessionRequest.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNChatService.h"

@protocol DNChatService_NSURLSessionRequestDelegate;

/**
 * An instance of this class models a request encapsulated in a
 * NSURLSessionDataTask. It also tracks its unique identifier as well
 * as the expected HTTP status codes, and the appropriate dispatch blocks
 * for the success and failure cases.
 */
@interface DNChatService_NSURLSessionRequest : NSObject

@property (nonatomic, weak) id<DNChatService_NSURLSessionRequestDelegate> delegate;
@property (nonatomic, strong) NSURLRequest *URLRequest;
@property (nonatomic, assign) NSInteger expectedStatus;
@property (nonatomic, copy) DNChatServiceSuccess successBlock;
@property (nonatomic, copy) DNChatServiceFailure failureBlock;

/**
 * Initialize a new instance which will immediately schedule the request. Delegate
 * methods will be invoked depending on the final response.
 */
- (instancetype)initWithRequest:(NSURLRequest *)request
                   usingSession:(NSURLSession *)session
                 expectedStatus:(NSInteger)expectedStatus
                        success:(DNChatServiceSuccess)success
                        failure:(DNChatServiceFailure)failure
                       delegate:(id<DNChatService_NSURLSessionRequestDelegate>)delegate;

/**
 * Cancel this request.
 */
- (void)cancel;

/**
 * Restart this request. Delegate methods should be invoked depending on final response
 */
- (void)restart;

/**
 * The unique identifier of the request
 */
- (NSString *)requestIdentifier;

@end

@protocol DNChatService_NSURLSessionRequestDelegate <NSObject>

/**
 * Indicates that the request completed successfully with the response
 * returned the expected status code.
 */
- (void)sessionRequestDidComplete:(DNChatService_NSURLSessionRequest *)request;

/**
 * Indicates that the request failed for some reason, described in the given error
 */
- (void)sessionRequestFailed:(DNChatService_NSURLSessionRequest *)request error:(NSError *)error;

/**
 * Indicates that the request failed authentication (401 response) and requires
 * authentication before proceeding.
 */
- (void)sessionRequestRequiresAuthentication:(DNChatService_NSURLSessionRequest *)request;

@end