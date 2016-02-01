//
//  ServalManager+RestfulRhizome.m
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "ServalManager+RestfulRhizome.h"
#import <UNIRest.h>

@implementation ServalManager (RestfulRhizome)
# pragma mark - Restful Rhizome Methods

+ (NSArray*) getRhizomeBundles{
    ServalManager *m = [ServalManager sharedManager];
    NSMutableArray* bundleArray = [[NSMutableArray alloc] init];
    
    NSDictionary* bundleDict = [ServalManager jsonDictForApiPath:@"/rhizome/bundlelist.json"];
    NSArray *header = [bundleDict objectForKey:@"header"];
    
    for(NSArray* row in [bundleDict objectForKey:@"rows"]){
        RhizomeBundle *b = [[RhizomeBundle alloc] initWithRestfulRow:row forHeader:header];
        
        // not a file?
        if (![b.service isEqualToString:@"file"]) continue;
        // sent by us?
        if ([b.sender isKindOfClass:[NSString class]] && [b.sender isEqualToString:m.firstSid]){
            [bundleArray addObject: b];
            continue;
        }
        // received by us?
        if ([b.recipient isKindOfClass:[NSString class]] && [b.recipient isEqualToString:m.firstSid] ) {
            [bundleArray addObject: b];
            continue;
        }
        // no receiver -> public?
        if ([b.recipient isKindOfClass:[NSNull class]]) {
            [bundleArray addObject:b];
            continue;
        }
    }
    
    return bundleArray;
}

+ (NSURLRequest*) requestForRhizomeBundle:(RhizomeBundle*) b{
    ServalManager *m = [ServalManager sharedManager];
    
    NSString* restfulUrl = [NSString stringWithFormat:@"http://localhost:4110/restful/rhizome/%@/decrypted.bin", b.id];
    NSURL *url = [NSURL URLWithString: restfulUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", m.restUser, m.restPassword];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    return request;
}

+ (NSDictionary*) addRhizomeFile:(NSData*) data withName:(NSString*) name error:(NSError*) error{
    ServalManager *m = [ServalManager sharedManager];
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    
    NSMutableData *body = [NSMutableData data];
    // add filename
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"manifest\"; filename=\"%@\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: rhizome/manifest\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    // add binary data
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"payload\"; filename=\"%@\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setHeaders:@{@"Content-Type": contentType}];
        [request setUrl:@"http://localhost:4110/restful/rhizome/insert"];
        [request setUsername: m.restUser];
        [request setPassword: m.restPassword];
        [request setBody:body];
    }] asJson:&error];
    
    return response.body.object;
}


@end
