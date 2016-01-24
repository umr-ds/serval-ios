//
//  RhizomeFilesTableViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 17.12.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#import "RhizomeFilesTableViewController.h"
#import "RhizomeFileDetailViewController.h"
#import <UNIRest.h>


@interface RhizomeFilesTableViewController ()

@end

@implementation RhizomeFilesTableViewController

NSArray* header;
NSArray* rows;
NSString* servalUser = @"ios";
NSString* servalPassword = @"password";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshBundlelist) forControlEvents:UIControlEventValueChanged];
    
    [self refreshBundlelist];
    
    }

- (void)refreshBundlelist{
    NSError *error = nil;
    UNIHTTPJsonResponse *response = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:@"http://localhost:4110/restful/rhizome/bundlelist.json"];
        [request setUsername:servalUser];
        [request setPassword:servalPassword];
    }] asJson:&error];
    
    if(error){
        NSLog(@"Request failed: %@", error.localizedDescription);
    } else {
        //        NSString *responseStr = [[NSString alloc] initWithData:[response rawBody] encoding: NSASCIIStringEncoding];
        //        NSLog(@"Response: %@", responseStr);
        NSLog(@"Response sucessful!");
        header = [response.body.object objectForKey:@"header"];
        
        NSInteger serviceIndex = [self indexOfField:@"service"];
        NSMutableArray *fileRows = [[NSMutableArray alloc] init];
        
        for(NSArray* row in [response.body.object objectForKey:@"rows"]){
            if ([[row objectAtIndex:serviceIndex] isEqualToString:@"file"])
                [fileRows addObject:row];
        }
        
        rows = [fileRows copy];
    }
    [self.refreshControl endRefreshing];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - rhizome response access methods

- (NSInteger) indexOfField:(NSString*) field {
    for (int i = 0; i < [header count]; i++){
        if ( [[header objectAtIndex:i] isEqualToString: field] ){
            return i;
        }
    }
    return -1;
}

- (NSInteger) rhizomeFileCount{
    NSInteger serviceIndex = [self indexOfField:@"service"];
    NSInteger count = 0;
    for (NSArray* row in rows) {
        if ([[row objectAtIndex:serviceIndex] isEqualToString:@"file"]) count++;
    }
    return count;
}

- (NSString*) valueForField:(NSString*) field inRow:(NSInteger) rowNo{
    NSInteger index = [self indexOfField:field];
    if (index == -1) return nil;

    NSArray* row = [rows objectAtIndex:rowNo];
    if (row == nil) return @"Row is nil.";
    NSString* value = [row objectAtIndex:index];
    if(value == nil) return @"Value is nil.";
    if([value class] == [NSNull class]) return @"NSNull value";
    return value;
}

- (NSString*) valueForIndex:(NSInteger) index inRow:(NSInteger) rowNo{
    NSArray* row = [rows objectAtIndex:rowNo];
    if (row == nil) return @"Row is nil.";
    NSString* value = [row objectAtIndex:index];
    if(value == nil) return @"Value is nil.";
    if([value class] == [NSNull class]) return @"NSNull value";
    return value;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [rows count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RhizomeFilesCell" forIndexPath:indexPath];
    
    [cell.textLabel setText:[self valueForField:@"name" inRow:indexPath.row]];
    
    return cell;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRhizomeFileSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RhizomeFileDetailViewController *viewController = segue.destinationViewController;
        viewController.title = [self valueForField:@"name" inRow:indexPath.row];
        //        viewController.dataRow = [rows objectAtIndex:indexPath.row];
        
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", servalUser, servalPassword];
        NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
        
        NSString* restfulUrl = [NSString stringWithFormat:@"http://localhost:4110/restful/rhizome/%@/decrypted.bin", [self valueForField:@"id" inRow:indexPath.row]];
        NSURL *url = [NSURL URLWithString: restfulUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];

        viewController.request = request;
    }
}


@end
