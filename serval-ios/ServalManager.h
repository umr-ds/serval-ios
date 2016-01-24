//
//  ServalManager.h
//  serval-ios
//
//  Created by Jonas Höchst on 17.12.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ServalManager : NSObject

@property (retain, nonatomic) NSFileHandle *logFile;
@property (retain, nonatomic) NSString *restUser;
@property (retain, nonatomic) NSString *restPassword;
@property (retain, nonatomic) NSString *sid;
@property (retain, nonatomic) NSString *did;
@property (retain, nonatomic) NSString *name;

+ (id) sharedManager;
- (void) startServald;
- (void) stopServald;
- (BOOL) setConfigOption:(NSString*) option toValue:(NSString*) value;
- (void) wipeRhizomeDB;

+ (NSDictionary*) jsonDictForApiPath:(NSString*) path;
+ (NSDictionary*) jsonDictForApiPath:(NSString*) path withParameters:(NSDictionary*) parameters;
- (void) refreshSidProperties;
- (NSString*) getConfig;

@end
