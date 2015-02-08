//
// DNChatService_NSURLSessionRequest.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//
#import "DNChatService_NSURLSessionRequest.h"

#import "NSHTTPURLResponse+ChatExtensions.h"

@interface DNChatService_NSURLSessionRequest ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSString *requestIdentifier;

@end

@implementation DNChatService_NSURLSessionRequest

- (instancetype)initWithRequest:(NSURLRequest *)request
                   usingSession:(NSURLSession *)session
                 expectedStatus:(NSInteger)expectedStatus
                        success:(DNChatServiceSuccess)success
                        failure:(DNChatServiceFailure)failure
                       delegate:(id<DNChatService_NSURLSessionRequestDelegate>)delegate
{
    if ((self = [super init])) {
        self.URLRequest = request;
        self.session = session;
        self.expectedStatus = expectedStatus;
        self.successBlock = success;
        self.failureBlock = failure;
        self.delegate = delegate;

        self.requestIdentifier = [[NSUUID UUID] UUIDString];
        self.task = [self createDataTask];
        [self.task resume];
    }
    
    return self;
}

- (void)cancel
{
    [self.task cancel];
    self.task = nil;
}

- (void)restart
{
    [self cancel];
    self.task = [self createDataTask];
    [self.task resume];
}

#pragma mark - Private helpers

- (NSURLSessionDataTask *)createDataTask
{
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:self.URLRequest
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
                                                     NSMutableURLRequest *mutableRequest = (NSMutableURLRequest *)weakSelf.URLRequest;

                                                     if (HTTPResponse.statusCode == weakSelf.expectedStatus) {
                                                         NSLog(@"%@ %@ %li SUCCESS", [mutableRequest HTTPMethod], [mutableRequest URL], (long)weakSelf.expectedStatus);

                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             weakSelf.successBlock(data);
                                                             [weakSelf.delegate sessionRequestDidComplete:weakSelf];
                                                         });
                                                     }
                                                     else if (HTTPResponse.statusCode == 401) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [weakSelf.delegate sessionRequestRequiresAuthentication:weakSelf];
                                                         });
                                                     }
                                                     else {
                                                         NSLog(@"%@ %@ %li INVALID STATUS CODE", [mutableRequest HTTPMethod], [mutableRequest URL], (long)HTTPResponse.statusCode);
                                                         
                                                         NSString *message = [HTTPResponse errorMessageWithData:data];
                                                         NSError *error = [NSError errorWithDomain:@"ChatcaveService"
                                                                                              code:HTTPResponse.statusCode
                                                                                          userInfo:@{ NSLocalizedDescriptionKey: message }];

                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             weakSelf.failureBlock(error);
                                                             [weakSelf.delegate sessionRequestFailed:weakSelf error:error];
                                                         });
                                                     }
                                                 }];
    
    return task;
}

@end
