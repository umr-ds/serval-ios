//
//  MeshMSMessage.h
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSQMessagesViewController/JSQMessageData.h>

@interface MeshMSMessage : NSObject <JSQMessageData>

@property (nonatomic, assign, getter=isSentByMe) BOOL sentByMe;
@property (nonatomic, strong) NSString *my_sid;
@property (nonatomic, strong) NSString *their_sid;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign, getter=isDelivered) BOOL delivered;
@property (nonatomic, assign, getter=isRead) BOOL read;
@property (nonatomic, strong) NSDate *timestamp;

- (id) initWithRestfulRow:(NSArray*) row forHeader:(NSArray*) header;

@end
