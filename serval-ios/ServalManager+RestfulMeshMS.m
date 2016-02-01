//
//  ServalManager+RestfulMeshMS.m
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "ServalManager+RestfulMeshMS.h"

@implementation ServalManager (RestfulMeshMS)

+ (NSArray*) getMeshConversationList{
    [ServalManager refreshIdentity];
    ServalManager *m = [ServalManager sharedManager];
    NSMutableArray* conversationList = [[NSMutableArray alloc] init];
    
    NSDictionary* bundleDict = [ServalManager jsonDictForApiPath:[NSString stringWithFormat:@"/meshms/%@/conversationlist.json", m.firstSid]];
    NSArray *header = [bundleDict objectForKey:@"header"];
    
    for(NSArray* row in [bundleDict objectForKey:@"rows"]){
        [conversationList addObject:[ServalManager getMeshConversationForRestfulRow:row withHeader:header]];
    }
    
    return conversationList;
}

+ (MeshMSConversation*) getMeshConversationForRestfulRow:(NSArray*) convRow withHeader:(NSArray*) convHeader{
    MeshMSConversation *conv = [[MeshMSConversation alloc] init];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:convRow forKeys:convHeader];
    
    conv.my_sid = [dict objectForKey:@"my_sid"];
    conv.their_sid = [dict objectForKey:@"their_sid"];
    
    NSDictionary* messageDict = [ServalManager jsonDictForApiPath:[NSString stringWithFormat:@"/meshms/%@/%@/messagelist.json", conv.my_sid, conv.their_sid]];
    NSArray *header = [messageDict objectForKey:@"header"];
    
    for(NSArray* row in [messageDict objectForKey:@"rows"]){
        
        MeshMSMessage *msg = [[MeshMSMessage alloc] initWithRestfulRow:row forHeader:header];
        [conv.messages addObject:msg];
    }
    
    return conv;
}

@end
