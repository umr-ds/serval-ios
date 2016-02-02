//
//  MeshMSConversation.h
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeshMSConversation : NSObject

@property (nonatomic, retain) NSMutableArray* messages;
@property (nonatomic, strong) NSString *my_sid;
@property (nonatomic, strong) NSString *their_sid;
@property (nonatomic, assign) NSInteger last_message;
@property (nonatomic, assign) NSInteger read_offset;

@end
