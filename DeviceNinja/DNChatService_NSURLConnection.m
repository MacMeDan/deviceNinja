//
//  DNChatService_NSURLConnection.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//
#import "DNChatService_NSURLConnection.h"

#import "DNChatService_SubclassMethods.h"
#import "DNChatroom.h"
#import "DNChatter.h"
#import "DNMessage.h"
#import "DNChatService_NSURLConnectionRequest.h"
#import "NSArray+Enumerable.h"

@interface DNChatService_NSURLConnection () <DNChatService_NSURLConnectionRequestDelegate>

@property (nonatomic, strong) NSMutableArray *requestsPendingAuthentication;

@end

@implementation DNChatService_NSURLConnection

- (id)init
{
    if ((self = [super init]))
    {
        self.requestsPendingAuthentication = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Subclass methods

- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(DNChatServiceSuccess)success
                           failure:(DNChatServiceFailure)failure
{
    NSMutableURLRequest *request = [self requestForURL:URL method:httpMethod bodyDict:bodyDict];
    
    DNChatService_NSURLConnectionRequest *connectionRequest;
    connectionRequest = [[DNChatService_NSURLConnectionRequest alloc] initWithRequest:request
                                                                        expectedStatusCode:expectedStatus
                                                                                   success:success
                                                                                   failure:failure
                                                                                  delegate:self];
    
    NSString *connectionID = [connectionRequest uniqueIdentifier];
    [self.requests setObject:connectionRequest forKey:connectionID];
    return connectionID;
}

- (void)resendRequestsPendingAuthentication
{
    for (DNChatService_NSURLConnectionRequest *request in self.requestsPendingAuthentication) {
        [request restart];
    }
    
    [self.requestsPendingAuthentication removeAllObjects];
}

- (void)cancelRequestWithIdentifier:(NSString *)identifier
{
    DNChatService_NSURLConnectionRequest *request = [self.requests objectForKey:identifier];
    if (request) {
        [request cancel];
        [self.requests removeObjectForKey:identifier];
    }
}

#pragma mark - DNChatcaveService_NSURLConnectionRequestDelegate

- (void)requestDidComplete:(DNChatService_NSURLConnectionRequest *)request
{
    [self.requests removeObjectForKey:[request uniqueIdentifier]];
    [self.requestsPendingAuthentication removeObject:request];
}

- (void)requestRequiresAuthentication:(DNChatService_NSURLConnectionRequest *)request
{
    [self.requestsPendingAuthentication addObject:request];
    [[NSNotificationCenter defaultCenter] postNotificationName:DNChatcaveServiceAuthRequiredNotification object:nil];
}

@end
