//
//  NSArray+Enumerable.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Enumerable)

- (NSArray *)mappedArrayWithBlock:(id(^)(id obj))block;

@end
