//
//  MeshConversationViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "MeshConversationViewController.h"
#import "ServalIdentity.h"
#import "MeshMSMessage.h"

#define SHOW_TIMESTAMP_MINUTES 10

@interface MeshConversationViewController ()

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end

@implementation MeshConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [ServalIdentity readableNameForSid:self.conversation.their_sid];
    
    // don't show avatars
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    // don't allow attachments
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while(true){
            [NSThread sleepForTimeInterval: 1];
            if (self.isViewLoaded && self.view.window) {
                // viewController is visible
                [ServalManager updateMeshConversation:self.conversation delegate:self];
//                
//                NSInteger newMessages = [ServalManager updateMeshConversation:self.conversation];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    // There are new messages: show!
//                    if (newMessages > 0) {
//                        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
//                        [self finishReceivingMessageAnimated:YES];
//                    } else if (newMessages == 0){
//                        // some messages were updated: reload
//                        [self.collectionView reloadData];
//                    } else {
//                        // Nothing changed: continue...
//                    }
//                });
            }
        }
    });
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {

    NSError *error;
    [ServalManager addText:text toConversation:self.conversation error:error];
#warning if self is the delegate, a received sound would be played, as new messages were added; for now: set nil delegate.
    [ServalManager updateMeshConversation:self.conversation delegate:nil];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessageAnimated:YES];
}


# pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.conversation.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    MeshMSMessage *msg = [self.conversation.messages objectAtIndex:indexPath.row];

    if ([msg isSentByMe]) cell.textView.textColor = [UIColor blackColor];
    else cell.textView.textColor = [UIColor whiteColor];
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}


# pragma mark - JSQMessagesCollectionView DataSource required methods

- (NSString *)senderDisplayName{
    return [ServalIdentity readableNameForSid:self.conversation.my_sid];
}

- (NSString *)senderId{
    return self.conversation.my_sid;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.conversation.messages objectAtIndex:indexPath.row];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Cell at index %li should be deleted.", (long)indexPath.row);
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MeshMSMessage *msg = [self.conversation.messages objectAtIndex:indexPath.row];
    
    if (msg.isSentByMe) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

# pragma mark - JSQMessagesCollectionView DataSource optional methods

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    MeshMSMessage *message = [self.conversation.messages objectAtIndex:indexPath.item];
    
    if (indexPath.item == 0){
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    MeshMSMessage *prevMessage = [self.conversation.messages objectAtIndex:indexPath.item-1];
    NSTimeInterval secondsBetween = [message.timestamp timeIntervalSinceDate:prevMessage.timestamp];
    
    // more than 5 minutes between messages
    if (secondsBetween > SHOW_TIMESTAMP_MINUTES * 60){
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    MeshMSMessage *msg = [self.conversation.messages objectAtIndex:indexPath.item];
    
    if (!msg.isSentByMe) return nil;
    
    if (msg.offset == self.conversation.read_offset)
        return [[NSAttributedString alloc] initWithString:@"Read" attributes:nil];
    
    if (msg.offset == self.conversation.latest_ack_offset)
        return [[NSAttributedString alloc] initWithString:@"Delivered" attributes:nil];
    
    return nil;
}

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    MeshMSMessage *message = [self.conversation.messages objectAtIndex:indexPath.item];
    
    if (indexPath.item == 0){
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    MeshMSMessage *prevMessage = [self.conversation.messages objectAtIndex:indexPath.item-1];
    NSTimeInterval secondsBetween = [message.timestamp timeIntervalSinceDate:prevMessage.timestamp];
    
    // more than 5 minutes between messages
    if (secondsBetween > SHOW_TIMESTAMP_MINUTES * 60){
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    MeshMSMessage *msg = [self.conversation.messages objectAtIndex:indexPath.item];
    
    if (!msg.isSentByMe) return 0.0f;
    
    if (msg.offset == self.conversation.read_offset)
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    
    if (msg.offset == self.conversation.latest_ack_offset)
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    
    return 0.0f;

}

#pragma mark - MeshConversationUpdate Delegate

-(void) didUpdateConversationOffsets{
    NSLog(@"didUpdateConversationOffsets");
    [self.collectionView reloadData];
}

-(void) didAddMessagesToConversation{
    NSLog(@"didAddMessagesToConversation");
    [self finishReceivingMessageAnimated:YES];
}



@end
