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

+ (id) sharedManager;
- (void) startServald;
- (void) stopServald;
- (BOOL) setConfigOption:(NSString*) option toValue:(NSString*) value;

@end
