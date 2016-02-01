//
//  ServalIdentity.h
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServalIdentity : NSObject

@property (nonatomic, strong) NSString *sid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *did;

- (id) initWithSid:(NSString*) sid;
- (NSString*) readableName;
+ (NSString*) readableNameForSid:(NSString*) sid;

@end
