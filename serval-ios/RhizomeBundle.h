//
//  RhizomeBundle.h
//  serval-ios
//
//  Created by Jonas Höchst on 31.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RhizomeBundle : NSObject

@property (nonatomic) NSString *service;
@property (nonatomic) NSString *id;
@property (nonatomic) NSInteger *version;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSInteger *filesize;
@property (nonatomic) NSString *filehash;
@property (nonatomic) NSString *sender;
@property (nonatomic) NSString *recipient;
@property (nonatomic) NSString *name;

- (id) initWithRestfulRow:(NSArray*) row forHeader:(NSArray*) header;


@end
