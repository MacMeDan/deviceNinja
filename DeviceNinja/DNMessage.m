//
//  DNMessage.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/3/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "DNMessage.h"

NSString * const DNMessagePublicIDKey = @"id";
NSString * const DNMessageTypeKey = @"type";
NSString * const DNMessageTextKey = @"text";
NSString * const DNMessageAuthorKey = @"author";
NSString * const DNMessageTimestampKey = @"timestamp";

@interface DNMessage ()

@property (nonatomic, copy, readwrite) NSString *publicID;
@property (nonatomic, copy, readwrite) NSString *text;
@property (nonatomic, copy, readwrite) NSString *author;
@property (nonatomic, assign, readwrite) DNMessageType type;
@property (nonatomic, strong, readwrite) NSDate *timestamp;

@end

@implementation DNMessage

- (instancetype)initWithPublicID:(NSString *)publicID
                            type:(DNMessageType)type
                            text:(NSString *)text
                          author:(NSString *)author
                       timestamp:(NSDate *)timestamp
{
    if ((self = [super init])) {
        self.publicID = publicID;
        self.type = type;
        self.text = text;
        self.author = author;
        self.timestamp = timestamp;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithPublicID:dictionary[DNMessagePublicIDKey]
                             type:[self typeFromString:dictionary[DNMessageTypeKey]]
                             text:dictionary[DNMessageTextKey]
                           author:dictionary[DNMessageAuthorKey]
                        timestamp:[[self class] dateFromString:dictionary[DNMessageTimestampKey]]];
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{
        DNMessagePublicIDKey: self.publicID,
        DNMessageTypeKey: @(self.type),
        DNMessageAuthorKey: self.author,
        DNMessageTextKey: self.text,
        DNMessageTimestampKey: [[self class] stringFromDate:self.timestamp]
    };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: 0x%x publicID=%@ text=%@ author=%@ type=%@ timestamp=%@>",
            NSStringFromClass([self class]),
            (unsigned int)self,
            self.publicID,
            self.text,
            self.author,
            [self typeAsString],
            self.timestamp];
}

- (NSString *)typeAsString
{
    if (self.type == DNMessageTypeLeave) {
        return @"leave";
    }
    else if (self.type == DNMessageTypeJoin) {
        return @"join";
    }
    else if (self.type == DNMessageTypeChat) {
        return @"chat";
    }
    return @"unknown";
}

- (DNMessageType)typeFromString:(NSString *)string
{
    if ([[string lowercaseString] isEqualToString:@"join"]) {
        return DNMessageTypeJoin;
    }
    else if ([[string lowercaseString] isEqualToString:@"leave"]) {
        return DNMessageTypeLeave;
    }
    else if ([[string lowercaseString] isEqualToString:@"chat"]) {
        return DNMessageTypeChat;
    }
    return DNMessageTypeUnknown;
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    });

    return dateFormatter;
}

+ (NSDate *)dateFromString:(NSString *)string
{
    return [[self dateFormatter] dateFromString:string];
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    return [[self dateFormatter] stringFromDate:date];
}

@end
