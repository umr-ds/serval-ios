//
//  ServalManager+RestfulMeshMS.h
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "ServalManager+Restful.h"
#import "MeshMSConversation.h"
#import "MeshMSMessage.h"

@protocol MeshConversationUpdateDelegate <NSObject>
- (void) didAddMessagesToConversation;
- (void) didUpdateConversationOffsets;
@end

@protocol MeshConversationListUpdateDelegate <NSObject>
- (void) didAddConversationToList;
- (void) didUpdateConversationInList;
@end

@interface ServalManager (RestfulMeshMS)

//+ (NSMutableArray*) getMeshConversationList;
+ (void) updateMeshConversationList:(NSMutableArray*) convList delegate:(id<MeshConversationListUpdateDelegate>) delegate async:(BOOL) async;

+ (MeshMSConversation*) getMeshConversationWithMySid:(NSString*) my_sid theirSid:(NSString*) their_sid;
+ (void) updateMeshConversation:(MeshMSConversation*) conv delegate:(id<MeshConversationUpdateDelegate>) delegate;

+ (void) addText:(NSString*) text toConversation:(MeshMSConversation*) conversation error:(NSError*) error;


@end
