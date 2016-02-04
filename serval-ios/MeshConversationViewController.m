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
@property (nonatomic, strong) NSTimer* refreshTimer;

@end

@implementation MeshConversationViewController

#pragma mark - UIView cycle methods

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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self startAutoRefresh];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopAutoRefresh];
}

#pragma mark - Refresh methods

- (void)startAutoRefresh {
    if ([self.refreshTimer isValid]) [self.refreshTimer invalidate];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshMeshConversationAsync) userInfo:nil repeats:YES];
}

- (void)stopAutoRefresh {
    [self.refreshTimer invalidate];
}

- (void) refreshMeshConversationAsync{
    [ServalManager updateMeshConversation:self.conversation delegate:self async:YES];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {

    NSError *error;
    [ServalManager addText:text toConversation:self.conversation error:error];
    [ServalManager updateMeshConversation:self.conversation delegate:nil async:NO];
    
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
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    [self finishReceivingMessageAnimated:YES];
}



@end
