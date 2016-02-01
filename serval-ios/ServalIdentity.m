//
//  ServalIdentity.m
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "ServalIdentity.h"

@implementation ServalIdentity

- (id) initWithSid:(NSString*) sid{
    if (! (self = [super init]))
        return nil;
    
    self.sid = sid;

    return self;
}

//- (id) initWithRestfulRow:(NSArray*) row forHeader:(NSArray*) header{
//    
//    if ( self = [super init] ){
//        NSLog(@"stub implementation");
//    }
//    
//    #warning this is a stub implementation!
//    return self;
//}

- (NSString*) readableName{
    if (self.name)
        return self.name;
    else if (self.did)
        return [NSString stringWithFormat:@"DID %zd", self.did];
    
    return [ServalIdentity readableNameForSid:self.sid];
}

+ (NSString*) readableNameForSid:(NSString*) sid{
    return [NSString stringWithFormat:@"sid:%@*", [sid substringToIndex:12]];
}

@end
