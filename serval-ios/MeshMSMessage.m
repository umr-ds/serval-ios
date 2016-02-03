//
//  MeshMSMessage.m
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "MeshMSMessage.h"
#import "ServalIdentity.h"

@implementation MeshMSMessage

- (id) initWithRestfulDict:(NSDictionary*) restfulMessage{
    // Just ignore ACKs for now...
    if ([[restfulMessage objectForKey:@"type"] isEqualToString:@"ACK"]) return nil;
    
    if(!(self = [super init]))
        return nil;
    
    if ([[restfulMessage objectForKey:@"type"] isEqualToString:@"<"]) _sentByMe = NO;
    else _sentByMe = YES;
    
    self.my_sid = [restfulMessage objectForKey:@"my_sid"];
    self.their_sid = [restfulMessage objectForKey:@"their_sid"];
    self.offset = [[restfulMessage objectForKey:@"offset"] longValue];
    self.token = [restfulMessage objectForKey:@"token"];
    self.text = [restfulMessage objectForKey:@"text"];
    self.delivered = [[restfulMessage objectForKey:@"delivered"] boolValue];
    self.read = [[restfulMessage objectForKey:@"read"] boolValue];
    
    NSTimeInterval epochTimeInterval = [[restfulMessage objectForKey:@"timestamp"] longValue];
    self.timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:epochTimeInterval];
    
    return self;
}

# pragma mark - JSQMessageData Protocol

- (NSString *)senderId {
    if (self.sentByMe)
        return self.my_sid;
    else
        return self.their_sid;
}

- (NSString *)senderDisplayName{
    if (self.sentByMe)
        return [ServalIdentity readableNameForSid:self.my_sid];
    else
        return [ServalIdentity readableNameForSid:self.their_sid];
}

- (NSDate *)date{
    return self.timestamp;
}

- (BOOL)isMediaMessage{
    return NO;
}

/**
 *  @return An integer that can be used as a table address in a hash table structure.
 *
 *  @discussion This value must be unique for each message with distinct contents.
 *  This value is used to cache layout information in the collection view.
 */
- (NSUInteger)messageHash{
#warning this is a stub implementation which will crash sooner or later...
    return [self.timestamp timeIntervalSince1970];
}


- (NSString *)text{
    return _text;
}

@end
