//
//  ServalManager+RestfulRhizome.h
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "ServalManager+Restful.h"
#import "RhizomeBundle.h"

@interface ServalManager (RestfulRhizome)

+ (NSArray*) getRhizomeBundles;
+ (NSURLRequest*) requestForRhizomeBundle:(RhizomeBundle*) b;
+ (NSDictionary*) addRhizomeFile:(NSData*) data withName:(NSString*) name error:(NSError*) error;

@end
