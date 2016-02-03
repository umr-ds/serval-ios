//
//  MeshMSConversation.h
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeshMSMessage.h"

@interface MeshMSConversation : NSObject

@property (nonatomic, retain) NSMutableArray* messages;
@property (nonatomic, strong) NSString *my_sid;
@property (nonatomic, strong) NSString *their_sid;
@property (nonatomic, assign) NSUInteger last_message;
@property (nonatomic, assign) NSUInteger read_offset;
@property (nonatomic, assign) NSUInteger latest_ack_offset;

-(id) initWithMySid:(NSString*) my_sid theirSid:(NSString*) their_sid;
-(id) initWithConvListDict:(NSDictionary*) convDict;

- (BOOL) isEqualToMeshMSConversation:(MeshMSConversation*) conv;

@end
