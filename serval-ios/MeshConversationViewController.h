//
//  MeshConversationViewController.h
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessages.h>
#import "MeshMSConversation.h"
#import "ServalManager+RestfulMeshMS.h"

@interface MeshConversationViewController : JSQMessagesViewController <MeshConversationUpdateDelegate>

@property (nonatomic, strong) MeshMSConversation* conversation;

@end
