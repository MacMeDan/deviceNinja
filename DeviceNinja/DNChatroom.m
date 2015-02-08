//
//  DNChatroom.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import "DNChatroom.h"

#import "DNChatter.h"
#import "NSArray+Enumerable.h"

NSString * const DNChatroomPublicIDKey = @"id";
NSString * const DNChatroomNameKey = @"name";
NSString * const DNChatroomChattersKey = @"chatters";

@interface DNChatroom ()

@property (nonatomic, copy, readwrite) NSString *publicID;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSArray *chatters;

@end

@implementation DNChatroom

- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name chatters:(NSArray *)chatters
{
    if ((self = [super init])) {
        self.publicID = publicID;
        self.name = name;
        self.chatters = chatters;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    NSArray *chattersFromDict = [dictionary[DNChatroomChattersKey] mappedArrayWithBlock:^id(id obj) {
        return [[DNChatter alloc] initWithDictionary:obj];
    }];

    return [self initWithPublicID:dictionary[DNChatroomPublicIDKey]
                             name:dictionary[DNChatroomNameKey]
                         chatters:chattersFromDict];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSArray *chatterDicts = [self.chatters mappedArrayWithBlock:^id(id obj) {
        return [(DNChatter *)obj dictionaryRepresentation];
    }];

    return @{
        DNChatroomPublicIDKey: self.publicID,
        DNChatroomNameKey: self.name,
        DNChatroomChattersKey: chatterDicts
    };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<0x%x %@ publicID=%@ name=%@>",
            (unsigned int)self,
            NSStringFromClass([self class]),
            self.publicID,
            self.name];
}

@end
