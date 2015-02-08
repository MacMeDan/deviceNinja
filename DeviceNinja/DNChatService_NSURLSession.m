//
//  DNChatService_NSURLSession.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import "DNChatService_NSURLSession.h"

#import "DNChatService_NSURLSessionRequest.h"
#import "DNChatService_SubclassMethods.h"
#import "NSArray+Enumerable.h"

@interface DNChatService_NSURLSession () <DNChatService_NSURLSessionRequestDelegate>

@property (nonatomic, strong) NSMutableDictionary *requests;
@property (nonatomic, strong) NSMutableArray *requestsPendingAuthentication;

@end

@implementation DNChatService_NSURLSession

- (id)init
{
    if ((self = [super init])) {
        self.requests = [NSMutableDictionary dictionary];
        self.requestsPendingAuthentication = [NSMutableArray array];
    }
    
    return self;
}

# pragma mark - Subclass methods


- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(DNChatServiceSuccess)success
                           failure:(DNChatServiceFailure)failure
{
    NSMutableURLRequest *request = [self requestForURL:URL
                                                method:httpMethod
                                              bodyDict:bodyDict];

    DNChatService_NSURLSessionRequest *sessionRequest;
    sessionRequest = [[DNChatService_NSURLSessionRequest alloc] initWithRequest:request
                                                                        usingSession:[NSURLSession sharedSession]
                                                                      expectedStatus:expectedStatus
                                                                             success:success
                                                                             failure:failure
                                                                            delegate:self];
    
    self.requests[sessionRequest.requestIdentifier] = sessionRequest;
    return sessionRequest.requestIdentifier;
}

- (void)cancelRequestWithIdentifier:(NSString *)identifier
{
    DNChatService_NSURLSessionRequest *request = self.requests[identifier];
    if (request) {
        [request cancel];
        [self.requests removeObjectForKey:identifier];
    }
}

- (void)resendRequestsPendingAuthentication
{
    for (DNChatService_NSURLSessionRequest *request in self.requestsPendingAuthentication) {
        [request restart];
    }
}

#pragma mark - DNChatcaveService_NSURLSessionRequestDelegate

- (void)sessionRequestDidComplete:(DNChatService_NSURLSessionRequest *)request
{
    [self.requests removeObjectForKey:request.requestIdentifier];
    [self.requestsPendingAuthentication removeObject:request];
}

- (void)sessionRequestFailed:(DNChatService_NSURLSessionRequest *)request error:(NSError *)error
{
    [self.requests removeObjectForKey:request.requestIdentifier];
    [self.requestsPendingAuthentication removeObject:request];
}

- (void)sessionRequestRequiresAuthentication:(DNChatService_NSURLSessionRequest *)request
{
    [self.requestsPendingAuthentication addObject:request];
    [[NSNotificationCenter defaultCenter] postNotificationName:DNChatcaveServiceAuthRequiredNotification object:nil];
}

@end
