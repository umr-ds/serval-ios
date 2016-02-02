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

@interface ServalManager (RestfulMeshMS)

+ (NSMutableArray*) getMeshConversationList;
+ (BOOL) updateMeshConversationList:(NSMutableArray*) conversationList;

+ (MeshMSConversation*) getMeshConversationForRestfulRow:(NSArray*) convRow withHeader:(NSArray*) convHeader;
+ (void) addText:(NSString*) text toConversation:(MeshMSConversation*) conversation error:(NSError*) error;
+ (NSUInteger) updateMeshConversation:(MeshMSConversation*) conv;

@end
