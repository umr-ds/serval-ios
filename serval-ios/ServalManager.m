//
//  ServalManager.m
//  serval-ios
//
//  Created by Jonas Höchst on 17.12.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#import "ServalManager.h"

@implementation ServalManager
@synthesize someProperty;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static ServalManager *sharedServalManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServalManager = [[self alloc] init];
//        rhizome_opendb();
    });
    return sharedServalManager;
}

- (id)init {
    if (self = [super init]) {
        someProperty = @"Default Property Value";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end
