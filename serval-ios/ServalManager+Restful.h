//
//  ServalManager+Restful.h
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "ServalManager.h"

@interface ServalManager (Restful)

+ (NSDictionary*) jsonDictForApiPath:(NSString*) path;
+ (NSDictionary*) jsonDictForApiPath:(NSString*) path withParameters:(NSDictionary*) parameters;

+ (void) refreshIdentity;

@end
