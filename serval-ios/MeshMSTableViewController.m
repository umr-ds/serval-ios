//
//  MeshMSTableViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 31.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "MeshMSTableViewController.h"
#import "ServalManager+RestfulMeshMS.h"
#import "MeshConversationViewController.h"

@interface MeshMSTableViewController ()

@property (nonatomic, strong) NSArray *meshConversations;

@end

@implementation MeshMSTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(pulledToRefresh) forControlEvents:UIControlEventValueChanged];
    

    [self refreshMeshConversations];
    [self.tableView reloadData];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while(true){
            [NSThread sleepForTimeInterval: 1];
            if (self.isViewLoaded && self.view.window) {
                // viewController is visible
                [self refreshMeshConversations];
                dispatch_async(dispatch_get_main_queue(), ^{[self.tableView reloadData];});
            }
        }
    });
}


- (void)pulledToRefresh{
    [self refreshMeshConversations];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)refreshMeshConversations{
    self.meshConversations = [ServalManager getMeshConversationList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    MeshMSMessage *latestMessage = [conv.messages firstObject];
    
    [cell.textLabel setText:[them readableName]];
    [cell.detailTextLabel setText:latestMessage.text];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MeshConversationViewController *vc = [MeshConversationViewController messagesViewController];
    vc.conversation = [self.meshConversations objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
