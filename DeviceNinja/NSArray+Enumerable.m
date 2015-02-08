//
//  NSArray+Enumerable.m
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import "NSArray+Enumerable.h"

@implementation NSArray (Enumerable)

- (NSArray *)mappedArrayWithBlock:(id (^)(id))block
{
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        [temp addObject:block(obj)];
    }
    
    return temp;
}

@end
