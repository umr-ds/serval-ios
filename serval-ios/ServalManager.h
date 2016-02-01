//
//  ServalManager.h
//  serval-ios
//
//  Created by Jonas Höchst on 17.12.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ServalIdentity.h"

@interface ServalManager : NSObject

@property (strong, nonatomic) NSFileHandle *logFile;
@property (strong, nonatomic) NSString *restUser;
@property (strong, nonatomic) NSString *restPassword;
@property (strong, nonatomic) NSString *firstSid;
@property (strong, nonatomic) ServalIdentity *firstIdentity;


+ (id) sharedManager;
+ (void) startServald;
+ (void) stopServald;
+ (NSString*) getConfig;

@end
