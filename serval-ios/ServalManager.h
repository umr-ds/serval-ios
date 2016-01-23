//
//  ServalManager.h
//  serval-ios
//
//  Created by Jonas Höchst on 17.12.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServalManager : NSObject

@property (nonatomic, retain) NSString *someProperty;
@property (nonatomic, retain) NSFileHandle *logFile;

+ (id)sharedManager;
- (void)startServald;

@end
