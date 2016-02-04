//
//  ServalManager+RestfulMeshMS.m
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "ServalManager+RestfulMeshMS.h"
#import <UNIRest.h>

@implementation ServalManager (RestfulMeshMS)

#pragma mark - MeshMS conversation list methods

+ (void) updateMeshConversationList:(NSMutableArray*) convList delegate:(id<MeshConversationListUpdateDelegate>) delegate async:(BOOL) async{
    if (async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [ServalManager updateMeshConversationList:convList delegate:delegate];
        });
    } else {
        [ServalManager updateMeshConversationList:convList delegate:delegate];
    }
}

//+ (NSMutableArray*) getMeshConversationList{
//    [ServalManager refreshIdentity];
//    ServalManager *m = [ServalManager sharedManager];
//    NSMutableArray* convList = [[NSMutableArray alloc] init];
//    
//    NSDictionary* bundleDict = [ServalManager jsonDictForApiPath:[NSString stringWithFormat:@"/meshms/%@/conversationlist.json", m.firstSid]];
//    NSArray *header = [bundleDict objectForKey:@"header"];
//    
//    for(NSArray* row in [bundleDict objectForKey:@"rows"]){
//        NSDictionary *convListDict = [[NSDictionary alloc] initWithObjects:row forKeys:header];
//        MeshMSConversation *conv = [ServalManager getMeshConversationWithMySid:[convListDict objectForKey:@"my_sid"] theirSid:[convListDict objectForKey:@"their_sid"]];
//        [convList addObject:conv];
//    }
//    
//    return convList;
//}

+ (MeshMSConversation*) conversationWithTheirSid:(NSString*) their_sid fromConversationList:(NSArray*) conversationList{
    for(MeshMSConversation* conv in conversationList){
        if ([conv.their_sid isEqualToString:their_sid]) {
            return conv;
        }
    }
    return nil;
}

+ (void) updateMeshConversationList:(NSMutableArray*) convList delegate:(id<MeshConversationListUpdateDelegate>) delegate{
    NSMutableArray *newConvList = [[NSMutableArray alloc] initWithCapacity:[convList count]];
    BOOL addedConversation = NO;
    BOOL updatedConversation = NO;
    // BOOL changedConversationOrder = NO; // can only change, if a conversation changes!
    
    [ServalManager refreshIdentity];
    ServalManager *m = [ServalManager sharedManager];
    
    NSDictionary* bundleDict = [ServalManager jsonDictForApiPath:[NSString stringWithFormat:@"/meshms/%@/conversationlist.json", m.firstSid]];
    NSArray *header = [bundleDict objectForKey:@"header"];
    
    for(NSArray* row in [bundleDict objectForKey:@"rows"]){
        
        NSDictionary *convListDict = [[NSDictionary alloc] initWithObjects:row forKeys:header];
        MeshMSConversation *stubConv = [[MeshMSConversation alloc] initWithConvListDict:convListDict];
        MeshMSConversation *conv = [ServalManager conversationWithTheirSid:stubConv.their_sid fromConversationList:convList];
        
        // if this conversation didn't exist: create full conversation
        if (!conv){
            conv = [ServalManager getMeshConversationWithMySid:stubConv.my_sid theirSid:stubConv.their_sid];
            addedConversation = YES;
        }
        
        // if the conversations aren't equal: update conversation (aka. stub is newer)
        if (![conv isEqualToMeshMSConversation:stubConv]){
            NSLog(@"Conversation updated!\n    old: %@ \n   stub: %@",conv, stubConv);
            [ServalManager updateMeshConversation:conv delegate:nil];
            updatedConversation = YES;
        }
        
        [newConvList addObject: conv];
    }
    
    if (addedConversation ||  updatedConversation){
        [convList replaceObjectsInRange:NSMakeRange(0, [convList count]) withObjectsFromArray:newConvList];
        if (!delegate) return;
        
        // delegate methods should always be executed on the main thread
        if (addedConversation) {
            dispatch_async(dispatch_get_main_queue(), ^{ [delegate didAddConversationToList]; });
            return;
        }
        if (updatedConversation) {
            dispatch_async(dispatch_get_main_queue(), ^{ [delegate didUpdateConversationInList]; });
            return;
        }
    }
}


#pragma mark - MeshMS conversation methods

+ (MeshMSConversation*) getMeshConversationWithMySid:(NSString*) my_sid theirSid:(NSString*) their_sid{
    MeshMSConversation *conv = [[MeshMSConversation alloc] initWithMySid:my_sid theirSid:their_sid];

    NSDictionary* messageListDict = [ServalManager jsonDictForApiPath:[NSString stringWithFormat:@"/meshms/%@/%@/messagelist.json", my_sid, their_sid]];
    NSArray *header = [messageListDict objectForKey:@"header"];

    for(NSArray* row in [[messageListDict objectForKey:@"rows"] reverseObjectEnumerator]){
        NSDictionary* messageDict = [[NSDictionary alloc] initWithObjects:row forKeys:header];
        MeshMSMessage *msg = [[MeshMSMessage alloc] initWithRestfulDict:messageDict];
        if (msg) {
            [conv.messages addObject:msg];
            if (!msg.isSentByMe) conv.last_message = msg.offset;
        }
    }
    
    conv.read_offset = [[messageListDict objectForKey:@"read_offset"] longValue];
    conv.latest_ack_offset = [[messageListDict objectForKey:@"latest_ack_offset"] longValue];
    return conv;
}

+ (void) updateMeshConversation:(MeshMSConversation*) conv delegate:(id<MeshConversationUpdateDelegate>) delegate async:(BOOL) async{
    if (async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [ServalManager updateMeshConversation:conv delegate:delegate];
            
        });
    } else {
        [ServalManager updateMeshConversation:conv delegate:delegate];
    }
}

+ (void) updateMeshConversation:(MeshMSConversation*) conv delegate:(id<MeshConversationUpdateDelegate>) delegate{
    MeshMSConversation *newConv = [ServalManager getMeshConversationWithMySid:conv.my_sid theirSid:conv.their_sid];

    // if there are new messages: call delegate
    if ([newConv.messages count] > [conv.messages count]) {
        [conv updateWithConversation:newConv];
        if (delegate) dispatch_async(dispatch_get_main_queue(), ^{ [delegate didAddMessagesToConversation]; });
        return;
    }
    
    // if read_offset changed: call delegate
    if (newConv.read_offset != conv.read_offset){
        [conv updateWithConversation:newConv];
        if (delegate) dispatch_async(dispatch_get_main_queue(), ^{ [delegate didUpdateConversationOffsets]; });
        return;
    }
    
    // if last_message changed: call delegate
    if (newConv.last_message != conv.last_message) {
        [conv updateWithConversation:newConv];
        if (delegate) dispatch_async(dispatch_get_main_queue(), ^{ [delegate didUpdateConversationOffsets]; });
        return;
    }
    
    // if latest_ack_offset changed: call delegate
    if (newConv.latest_ack_offset != conv.latest_ack_offset) {
        [conv updateWithConversation:newConv];
        if (delegate) dispatch_async(dispatch_get_main_queue(), ^{ [delegate didUpdateConversationOffsets]; });
        return;
    }
}

+ (void) addText:(NSString*) text toConversation:(MeshMSConversation*) conversation error:(NSError*) error{
    ServalManager *m = [ServalManager sharedManager];
    
    // POST /restful/meshms/SENDERSID/RECIPIENTSID/sendmessage
    NSString *urlString = [NSString stringWithFormat:@"http://localhost:4110/restful/meshms/%@/%@/sendmessage", conversation.my_sid, conversation.their_sid];
    
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    
    NSMutableData *body = [NSMutableData data];
    // add first boundary
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"message\"; filename=\"none\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: text/plain; charset=utf-8\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add last boundary
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setHeaders:@{@"Content-Type": contentType}];
        [request setUrl:urlString];
        [request setUsername: m.restUser];
        [request setPassword: m.restPassword];
        [request setBody:body];
    }] asJson:&error];
    
    return;
}

@end
