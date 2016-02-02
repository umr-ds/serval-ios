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

    for(NSArray* row in [[messageDict objectForKey:@"rows"] reverseObjectEnumerator]){
        MeshMSMessage *msg = [[MeshMSMessage alloc] initWithRestfulRow:row forHeader:header];
        if (msg) [conv.messages addObject:msg];
    }
    
    return conv;
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
    
    return; // response.body.object;
    
}

@end
