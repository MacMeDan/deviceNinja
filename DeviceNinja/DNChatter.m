//
//  DNChatter.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import "DNChatter.h"

NSString * const DNChatterPublicIDKey = @"id";
NSString * const DNChatterNameKey = @"name";


@interface DNChatter ()

@property (nonatomic, copy, readwrite) NSString *publicID;
@property (nonatomic, copy, readwrite) NSString *name;

@end

@implementation DNChatter

- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name
{
    if ((self = [super init])) {
        self.publicID = publicID;
        self.name = name;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    return [self initWithPublicID:dict[DNChatterPublicIDKey]
                             name:dict[DNChatterNameKey]];
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{
        DNChatterPublicIDKey: self.publicID,
        DNChatterNameKey: self.name
     };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: 0x%x publicID=%@ name=%@>",
            NSStringFromClass([self class]),
            (unsigned int)self,
            self.publicID,
            self.name];
}

@end
