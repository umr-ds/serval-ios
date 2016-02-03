//
//  MeshMSTableViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 31.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "MeshMSTableViewController.h"
#import "MeshConversationViewController.h"

@interface MeshMSTableViewController ()

@property (nonatomic, strong) NSMutableArray *meshConversations;

@end

@implementation MeshMSTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(pulledToRefresh) forControlEvents:UIControlEventValueChanged];
    
    self.meshConversations = [[NSMutableArray alloc] init];
    [ServalManager updateMeshConversationList:self.meshConversations delegate:nil async:NO];
    [self.tableView reloadData];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshMeshConversationsAsync) userInfo:nil repeats:YES];
}

- (void)pulledToRefresh{
    [ServalManager updateMeshConversationList:self.meshConversations delegate:nil async:NO];
    [self.refreshControl endRefreshing];
}

- (void)refreshMeshConversationsAsync{
    [ServalManager updateMeshConversationList:self.meshConversations delegate:self async:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.meshConversations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationListCell" forIndexPath:indexPath];
    
    MeshMSConversation *conv = [self.meshConversations objectAtIndex:indexPath.row];
    
    ServalIdentity *them = [[ServalIdentity alloc] initWithSid:conv.their_sid];
    MeshMSMessage *latestMessage = [conv.messages lastObject];
    
    [cell.textLabel setText:[them readableName]];
    [cell.detailTextLabel setText:latestMessage.text];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MeshConversationViewController *vc = [MeshConversationViewController messagesViewController];
    vc.conversation = [self.meshConversations objectAtIndex:indexPath.row];
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}


#pragma mark - MeshConversationListUpdate Delegate

- (void) didUpdateConversationInList{
    NSLog(@"didUpdateConversationInList");
    [self.tableView reloadData];
}

- (void) didAddConversationToList{
    NSLog(@"didAddConversationToList");
    [self.tableView reloadData];
}


@end
