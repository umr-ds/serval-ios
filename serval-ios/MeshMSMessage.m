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

- (id) initWithRestfulRow:(NSArray*) row forHeader:(NSArray*) header{
    if(!(self = [super init]))
        return nil;
    
    for (int i = 0; i < [header count]; i++){
        if ([[header objectAtIndex:i] isEqualToString:@"type"]){
            if ([[header objectAtIndex:i] isEqualToString:@"<"])
                self.sentByMe = false;
            if ([[header objectAtIndex:i] isEqualToString:@">"])
                self.sentByMe = true;
        }
        else if ([[header objectAtIndex:i] isEqualToString:@"my_sid"])
            self.my_sid = [row objectAtIndex:i];
        else if ([[header objectAtIndex:i] isEqualToString:@"their_sid"])
            self.their_sid = [row objectAtIndex:i];
        if ([[header objectAtIndex:i] isEqualToString:@"text"])
            self.text = [row objectAtIndex:i];
        else if ([[header objectAtIndex:i] isEqualToString:@"delivered"])
            self.delivered = [row objectAtIndex:i];
        else if ([[header objectAtIndex:i] isEqualToString:@"read"])
            self.read = [row objectAtIndex:i];
        
        else if ([[header objectAtIndex:i] isEqualToString:@"timestamp"]) {
            NSTimeInterval epochTimeInterval = [[row objectAtIndex:i] doubleValue];
            self.timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:epochTimeInterval]; }

    }
    
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
    return [self.timestamp timeIntervalSince1970];
}


- (NSString *)text{
    return _text;
}

@end