//
//  DNChatcaveService.m
//  
//
//  Created by Alex Vollmer on 3/21/14.
//
//

#import "DNChatService.h"

#import "DNChatroom.h"
#import "DNChatter.h"
#import "NSArray+Enumerable.h"
#import "DNChatService_NSURLConnection.h"
#import "DNChatService_NSURLSession.h"

NSString * const DNChatcaveServiceAuthRequiredNotification = @"DNChatcaveServiceAuthRequiredNotification";

/**
 * The user-defaults key for the URL of the last server the user authenticated
 * with
 */
static NSString * const DNLastServerURLKey = @"LastServerURL";

/**
 * The user-defaults key for the user identifier
 */
static NSString * const DNUserIdentifierKey = @"UserIdentifier";

/**
 * The user-defaults key for the current user
 */
static NSString * const DNCurrentUserKey = @"CurrentUser";

static DNChatService *SharedInstance;

@interface DNChatService ()

@property (nonatomic, strong) DNChatter *currentUser;
@property (nonatomic, strong) NSURL *tempServerRoot;
@property (nonatomic, strong) NSURL *serverRoot;
@property (nonatomic, strong) NSMutableDictionary *requests;

@end

@implementation DNChatService

+ (DNChatService *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[DNChatService_NSURLSession alloc] init];
    });
    
    return SharedInstance;
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.requests = [NSMutableDictionary dictionary];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *serverRootString = [defaults stringForKey:DNLastServerURLKey];
        if (serverRootString) {
            self.serverRoot = [NSURL URLWithString:serverRootString];
        }
        
        NSDictionary *userDict = [defaults objectForKey:DNCurrentUserKey];
        if (userDict) {
            self.currentUser = [[DNChatter alloc] initWithDictionary:userDict];
        }
    }
    return self;
}

#pragma mark - REST API methods

- (NSString *)signInWithUserName:(NSString *)userName
                        password:(NSString *)password
                       serverURL:(NSURL *)serverURL
                         success:(void (^)(DNChatter *chatter))success
                         failure:(DNChatServiceFailure)failure
{
    self.tempServerRoot = serverURL;
    NSDictionary *params = @{
                             @"user[name]": userName,
                             @"user[password]": password
                             };
    
    return [self submitPUTPath:@"/account"
                          body:params
                expectedStatus:201
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                           if (userDict && [userDict isKindOfClass:[NSDictionary class]]) {
                               self.currentUser = [[DNChatter alloc] initWithDictionary:userDict];
                               self.tempServerRoot = nil;
                               self.serverRoot = serverURL;
                               
                               [self persistServerRootAndUserIdentifier];
                               
                               if (success != NULL) {
                                   success(self.currentUser);
                               }
                               
                               [self resendRequestsPendingAuthentication];
                           }
                           else {
                               if (failure != NULL) {
                                   failure(error);
                               }
                           }
                       }
                       failure:^(NSError *error) {
                           self.tempServerRoot = nil;
                           if (failure != NULL) {
                               failure(error);
                           }
                       }];
}

- (NSString *)registerNewUserWithName:(NSString *)userName
                             password:(NSString *)password
                            serverURL:(NSURL *)serverURL
                              success:(void (^)(DNChatter *))success
                              failure:(DNChatServiceFailure)failure
{
    self.tempServerRoot = serverURL;
    
    NSDictionary *params = @{
                             @"user[name]": userName,
                             @"user[password]": password
                             };
    
    return [self submitPOSTPath:@"/users"
                           body:params
                 expectedStatus:201
                        success:^(NSData *data) {
                            self.tempServerRoot = nil;
                            NSError *error = nil;
                            NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                            if (userDict && [userDict isKindOfClass:[NSDictionary class]]) {
                                self.serverRoot = serverURL;
                                self.currentUser = [[DNChatter alloc] initWithDictionary:userDict];
                                
                                [self persistServerRootAndUserIdentifier];
                                
                                if (success != NULL) {
                                    success(self.currentUser);
                                }
                                
                                [self resendRequestsPendingAuthentication];
                            }
                            else {
                                if (failure != NULL) {
                                    failure(error);
                                }
                            }
                        }
                        failure:^(NSError *error) {
                            self.tempServerRoot = nil;
                            if (failure != NULL) {
                                failure(error);
                            }
                        }];
}

- (NSString *)signoutUserWithSuccess:(void (^)())success
                             failure:(DNChatServiceFailure)failure
{
    return [self submitDELETEPath:@"/account"
                          success:^(NSData *data) {
                              self.serverRoot = nil;
                              self.currentUser = nil;
                              
                              [self persistServerRootAndUserIdentifier];
                              
                              if (success != NULL) {
                                  success();
                              }
                          }
                          failure:failure];
}

- (BOOL)isUserSignedIn
{
    return self.serverRoot != nil;
}

#pragma mark - Chatrooms

- (NSString *)fetchChatroomsSuccess:(void (^)(NSArray *))success
                            failure:(DNChatServiceFailure)failure
{
    return [self submitGETPath:@"/rooms"
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSArray *results = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:0
                                                                                error:&error];
                           if (results && [results isKindOfClass:[NSArray class]]) {
                               NSArray *chatrooms = [results mappedArrayWithBlock:^id(id obj) {
                                   return [[DNChatroom alloc] initWithDictionary:obj];
                               }];
                               
                               if (success != NULL) {
                                   success(chatrooms);
                               }
                           }
                           else {
                               if (failure != NULL) {
                                   failure(error);
                               }
                           }
                       }
                       failure:failure];
}

- (NSString *)fetchChatroomWithID:(NSString *)chatroomID
                          success:(void (^)(DNChatroom *))success
                          failure:(DNChatServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@", chatroomID];
    
    return [self submitGETPath:path
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:0
                                                                                  error:&error];
                           
                           if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                               DNChatroom *chatroom = [[DNChatroom alloc] initWithDictionary:dict];
                               
                               if (success != NULL) {
                                   success(chatroom);
                               }
                           }
                           else {
                               if (failure != NULL) {
                                   failure(error);
                               }
                           }
                       }
                       failure:failure];
}

- (NSString *)createChatroomWithName:(NSString *)name
                             success:(void (^)(DNChatroom *))success
                             failure:(DNChatServiceFailure)failure
{
    return [self submitPOSTPath:@"/rooms"
                           body:@{ @"room[name]": name }
                 expectedStatus:201
                        success:^(NSData *data) {
                            NSError *error = nil;
                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                DNChatroom *chatroom = [[DNChatroom alloc] initWithDictionary:dict];
                                
                                if (success != NULL) {
                                    success(chatroom);
                                }
                            }
                            else {
                                if (failure != NULL) {
                                    failure(error);
                                }
                            }
                        }
                        failure:failure];
}

- (NSString *)deleteChatroomWithPublicID:(NSString *)publicID
                                 success:(void (^)())success
                                 failure:(DNChatServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@", publicID];
    return [self submitDELETEPath:path success:success failure:failure];
}

#pragma mark - Chatters

- (NSString *)fetchChattersForChatroomID:(NSString *)chatroomID
                                 success:(void (^)(NSArray *))success
                                 failure:(DNChatServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@", chatroomID];
    
    return [self submitGETPath:path
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                           NSArray *chatters = results[@"chatters"];
                           if (chatters && [chatters isKindOfClass:[NSArray class]]) {
                               NSArray *mappedChatters = [chatters mappedArrayWithBlock:^id(id obj) {
                                   return [[DNChatter alloc] initWithDictionary:obj];
                               }];
                               
                               if (success != NULL) {
                                   success(mappedChatters);
                               }
                           }
                           else {
                               if (failure != NULL) {
                                   NSError *error = [NSError errorWithDomain:@"com.pluralsight.ChatCave"
                                                                        code:0
                                                                    userInfo:@{NSLocalizedDescriptionKey: @"API returned invalid response"}];
                                   failure(error);
                               }
                           }
                       }
                       failure:failure];
}

- (NSString *)joinChatroomWithID:(NSString *)chatroomID
                         success:(void (^)())success
                         failure:(DNChatServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@/chatters/%@", chatroomID, self.currentUser.publicID];
    return [self submitPUTPath:path
                          body:nil
                expectedStatus:201
                       success:^(NSData *data) {
                           if (success != NULL) {
                               success();
                           }
                       }
                       failure:failure];
}

- (NSString *)leaveChatroomWithID:(NSString *)chatroomID
                          success:(void (^)())success
                          failure:(DNChatServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@/chatters/%@", chatroomID, self.currentUser.publicID];
    return [self submitDELETEPath:path
                          success:^(NSData *data) {
                              if (success != NULL) {
                                  success();
                              }
                          }
                          failure:failure];
}

#pragma mark - Messages

- (NSString *)fetchMessagesForChatroom:(NSString *)chatroomID
                               success:(void (^)(NSArray *))success
                               failure:(DNChatServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@/messages", chatroomID];
    return [self submitGETPath:path
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                           if (results && [results isKindOfClass:[NSArray class]]) {
                               NSArray *messages = [results mappedArrayWithBlock:^id(id obj) {
                                   return [[DNMessage alloc] initWithDictionary:obj];
                               }];
                               
                               if (success != NULL) {
                                   success(messages);
                               }
                           }
                           else {
                               if (failure != NULL) {
                                   failure(error);
                               }
                           }
                       }
                       failure:failure];
}

- (NSString *)fetchMessagesForChatroom:(NSString *)chatroomID
                                 since:(NSString *)sentinelMessageID
                               success:(void (^)(NSArray *))success
                               failure:(DNChatServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@/messages?since=%@",
                      chatroomID,
                      [sentinelMessageID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    return [self submitGETPath:path
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                           if (results && [results isKindOfClass:[NSArray class]]) {
                               NSArray *messages = [results mappedArrayWithBlock:^id(id obj) {
                                   return [[DNMessage alloc] initWithDictionary:obj];
                               }];
                               
                               if (success != NULL) {
                                   success(messages);
                               }
                           }
                           else {
                               if (failure != NULL) {
                                   failure(error);
                               }
                           }
                       }
                       failure:failure];
}

- (NSString *)postMessageWithText:(NSString *)text
                       toChatroom:(NSString *)chatroomID
                          success:(void (^)(DNMessage *))success
                          failure:(DNChatServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@/messages", chatroomID];
    
    return [self submitPOSTPath:path
                           body:@{ @"message[text]": text }
                 expectedStatus:201
                        success:^(NSData *data) {
                            NSError *error = nil;
                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                DNMessage *message = [[DNMessage alloc] initWithDictionary:dict];
                                
                                if (success != NULL) {
                                    success(message);
                                }
                            }
                            else {
                                if (failure != NULL) {
                                    failure(error);
                                }
                            }
                        }
                        failure:failure];
}

#pragma mark - Abstract methods

- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(DNChatServiceSuccess)success
                           failure:(DNChatServiceFailure)failure
{
    NSAssert(NO, @"%s must be implemented in a sub-class!", __PRETTY_FUNCTION__);
    return nil;
}

- (void)cancelRequestWithIdentifier:(NSString *)identifier
{
    NSAssert(NO, @"%s must be implemented in a sub-class!", __PRETTY_FUNCTION__);
}

- (void)resendRequestsPendingAuthentication
{
    NSAssert(NO, @"%s must be implemented in a sub-class!", __PRETTY_FUNCTION__);
}

#pragma mark - Request Helpers

- (void)persistServerRootAndUserIdentifier
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.serverRoot.absoluteString forKey:DNLastServerURLKey];
    [defaults setObject:self.currentUser.publicID forKey:DNUserIdentifierKey];
    [defaults setObject:[self.currentUser dictionaryRepresentation] forKey:DNCurrentUserKey];
    [defaults synchronize];
}

- (NSURL *)URLWithPath:(NSString *)path
{
    NSURL *root = self.serverRoot ?: self.tempServerRoot;
    NSAssert(root != nil, @"Cannot make requests if neither serverRoot or tempServerRoot are nil");
    return [NSURL URLWithString:path relativeToURL:root];
}

- (NSString *)submitGETPath:(NSString *)path
                    success:(DNChatServiceSuccess)success
                    failure:(DNChatServiceFailure)failure
{
    NSURL *URL = [self URLWithPath:path];
    return [self submitRequestWithURL:URL
                               method:@"GET"
                                 body:nil
                       expectedStatus:200
                              success:success
                              failure:failure];
}

- (NSString *)submitDELETEPath:(NSString *)path
                       success:(DNChatServiceSuccess)success
                       failure:(DNChatServiceFailure)failure
{
    NSURL *URL = [self URLWithPath:path];
    return [self submitRequestWithURL:URL
                               method:@"DELETE"
                                 body:nil
                       expectedStatus:200
                              success:success
                              failure:failure];
}

- (NSString *)submitPOSTPath:(NSString *)path
                        body:(NSDictionary *)bodyDict
              expectedStatus:(NSInteger)expectedStatus
                     success:(DNChatServiceSuccess)success
                     failure:(DNChatServiceFailure)failure
{
    NSURL *URL = [self URLWithPath:path];
    return [self submitRequestWithURL:URL
                               method:@"POST"
                                 body:bodyDict
                       expectedStatus:expectedStatus
                              success:success
                              failure:failure];
}

- (NSString *)submitPUTPath:(NSString *)path
                       body:(NSDictionary *)bodyDict
             expectedStatus:(NSInteger)expectedStatus
                    success:(DNChatServiceSuccess)success
                    failure:(DNChatServiceFailure)failure
{
    NSURL *URL = [self URLWithPath:path];
    return [self submitRequestWithURL:URL
                               method:@"PUT"
                                 body:bodyDict
                       expectedStatus:expectedStatus
                              success:success
                              failure:failure];
}

- (NSData *)formEncodedParameters:(NSDictionary *)parameters
{
    NSArray *pairs = [parameters.allKeys mappedArrayWithBlock:^id(id obj) {
        return [NSString stringWithFormat:@"%@=%@",
                [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                [parameters[obj] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    NSString *formBody = [pairs componentsJoinedByString:@"&"];
    
    return [formBody dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)URL
                                method:(NSString *)httpMethod
                              bodyDict:(NSDictionary *)bodyDict
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:httpMethod];
    
    // For now, assume body content is always form-urlencoded
    if (bodyDict) {
        [request setHTTPBody:[self formEncodedParameters:bodyDict]];
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

@end
