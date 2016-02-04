//
//  MeshMSConversation.m
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "MeshMSConversation.h"
#import "ServalIdentity.h"

@implementation MeshMSConversation

-(id) initWithMySid:(NSString*) my_sid theirSid:(NSString*) their_sid{
    if(!(self = [super init]))
        return nil;
    
    self.my_sid = my_sid;
    self.their_sid = their_sid;
    self.read_offset = 0;
    self.last_message = 0;
    self.latest_ack_offset = 0;
    self.messages = [[NSMutableArray alloc] init];
    
    return self;
}

-(id) initWithConvListDict:(NSDictionary*) convDict {
    if(!(self = [super init]))
        return nil;
    
    self.my_sid = [convDict objectForKey:@"my_sid"];
    self.their_sid = [convDict objectForKey:@"their_sid"];
    self.last_message = [[convDict objectForKey:@"last_message"] longValue];
    self.messages = [[NSMutableArray alloc] init];
    
    return self;
}

- (BOOL) isEqualToMeshMSConversation:(MeshMSConversation*) conv {
    if (self == conv) return YES;
    
    if (!conv) return NO;
    if (![self.my_sid isEqualToString:conv.my_sid]) return NO;
    if (![self.their_sid isEqualToString:conv.their_sid]) return NO;
    if (self.last_message != conv.last_message) return NO;
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MeshMS Conv: %@ -> %@ | %lu Bytes ",
            [ServalIdentity readableNameForSid:self.my_sid],
            [ServalIdentity readableNameForSid:self.their_sid],
            self.last_message];
}

- (void) updateWithConversation:(MeshMSConversation*) conv {
    
    self.my_sid = conv.my_sid;
    self.their_sid = conv.their_sid;
    self.read_offset = conv.read_offset;
    self.last_message = conv.last_message;
    self.latest_ack_offset = conv.latest_ack_offset;
    self.messages = conv.messages;
}

@end
