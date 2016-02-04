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
@property (nonatomic, strong) NSTimer* refreshTimer;

@end

@implementation MeshMSTableViewController

# pragma mark - uiview lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(pulledToRefresh) forControlEvents:UIControlEventValueChanged];
    
    self.meshConversations = [[NSMutableArray alloc] init];
    [ServalManager updateMeshConversationList:self.meshConversations delegate:nil async:NO];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self startAutoRefresh];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopAutoRefresh];
}

# pragma mark - refresh helper methods

- (void)pulledToRefresh{
    [ServalManager updateMeshConversationList:self.meshConversations delegate:nil async:NO];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)startAutoRefresh {
    if ([self.refreshTimer isValid]) [self.refreshTimer invalidate];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshMeshConversationsAsync) userInfo:nil repeats:YES];
}

- (void)stopAutoRefresh {
    [self.refreshTimer invalidate];
}

- (void)refreshMeshConversationsAsync{
    NSLog(@"Refreshing async...");
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
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
