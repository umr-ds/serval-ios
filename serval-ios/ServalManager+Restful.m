//
//  ServalManager+Restful.m
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "ServalManager+Restful.h"
#import <UNIRest.h>

@implementation ServalManager (Restful)

# pragma mark - Restful API Helpers

+ (NSDictionary*) jsonDictForApiPath:(NSString*) path {
    return [ServalManager jsonDictForApiPath:path withParameters:nil];
}

+ (NSDictionary*) jsonDictForApiPath:(NSString*) path withParameters:(NSDictionary*) parameters{
    ServalManager *m = [ServalManager sharedManager];
    
    NSError *error = nil;
    NSString *url = [NSString stringWithFormat:@"http://localhost:4110/restful%@", path];
    UNIHTTPJsonResponse *response = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:url];
        [request setUsername:[m restUser]];
        [request setPassword:[m restPassword]];
        if (parameters) [request setParameters:parameters];
    }] asJson:&error];
    
    if(error){
        NSLog(@"Request failed: %@", error.localizedDescription);
        return nil;
    }
    
    //    NSLog(@"Response sucessful for url: %@", url);
    return response.body.object;
}

# pragma mark - User SID / DID / Name Properties

+ (void) refreshIdentity{
    ServalManager *m = [ServalManager sharedManager];
    NSDictionary *sidDict = [ServalManager jsonDictForApiPath:@"/keyring/identities.json"];
    
    // For now, we are just supporting the first (aka. primary) SID
    m.firstSid = [[[sidDict objectForKey:@"rows"] objectAtIndex:0] objectAtIndex:0];
    
    m.firstIdentity = [[ServalIdentity alloc] initWithSid:m.firstSid];
    m.firstIdentity.did = [[[sidDict objectForKey:@"rows"] objectAtIndex:0] objectAtIndex:1];
    m.firstIdentity.name = [[[sidDict objectForKey:@"rows"] objectAtIndex:0] objectAtIndex:2];
}

@end
