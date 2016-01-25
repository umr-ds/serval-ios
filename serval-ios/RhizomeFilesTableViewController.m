//
//  RhizomeFilesTableViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 17.12.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#import "RhizomeFilesTableViewController.h"
#import "RhizomeFileDetailViewController.h"
#import "ServalManager.h"
#import <UNIRest.h>
@import MobileCoreServices;
@import Photos;


@interface RhizomeFilesTableViewController ()

@end

@implementation RhizomeFilesTableViewController

NSArray* header;
NSArray* rows;
NSString* servalUser = @"ios";
NSString* servalPassword = @"password";
NSTimer* refreshTimer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(pulledToRefresh) forControlEvents:UIControlEventValueChanged];
    
    [self refreshBundlelist];
    [self.tableView reloadData];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while(true){
            [NSThread sleepForTimeInterval: 1];
            if (self.isViewLoaded && self.view.window) {
                // viewController is visible
                [self refreshBundlelist];
                dispatch_async(dispatch_get_main_queue(), ^{[self.tableView reloadData];});
            }
        }
    });
}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
}

- (void)viewDidDisappear:(BOOL)animated{
    
    NSLog(@"viewDidDisappear");
}

- (void)pulledToRefresh{
    [self refreshBundlelist];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)refreshBundlelist{
    ServalManager *m = [ServalManager sharedManager];
    [m refreshSidProperties];
    
    NSDictionary* bundlelist = [ServalManager jsonDictForApiPath:@"/rhizome/bundlelist.json"];
    
    if(bundlelist != nil){
        header = [bundlelist objectForKey:@"header"];
        
        NSInteger serviceIndex = [self indexOfField:@"service"];
        NSInteger senderIndex = [self indexOfField:@"sender"];
        NSInteger recipientIndex = [self indexOfField:@"recipient"];
        
        NSMutableArray *fileRows = [[NSMutableArray alloc] init];
        NSArray* bundleListRows = [bundlelist objectForKey:@"rows"];
        
        for(NSArray* row in bundleListRows){
            // checks if this entry is a file
            if (! [[row objectAtIndex:serviceIndex] isEqualToString:@"file"]) {
                // NSLog(@"not a file");
                continue;
            }
            
            // if the file is sent by us, we can decrypt it.
            if ( [[row objectAtIndex:senderIndex] isKindOfClass:[NSString class]] && [[row objectAtIndex:senderIndex] isEqualToString:m.sid] ) {
                [fileRows addObject:row];
                // NSLog(@"sent by us");
                continue;
            }
            // if the file is recieved by us, we can decrypt it.
            if ( [[row objectAtIndex:recipientIndex] isKindOfClass:[NSString class]] && [[row objectAtIndex:recipientIndex] isEqualToString:m.sid] ) {
                [fileRows addObject:row];
                // NSLog(@"recieved by us");
                continue;
            }

            // if the file has no reciever, its public and we can decrypt it
            if ( [[row objectAtIndex:recipientIndex] isKindOfClass:[NSNull class]] ) {
                [fileRows addObject:row];
                // NSLog(@"public file");
                continue;
            }
        }
        
        rows = [fileRows copy];
    }
    
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

- (id) valueForField:(NSString*) field inRow:(NSInteger) rowNo{
    NSInteger index = [self indexOfField:field];
    if (index == -1) return [[NSNull alloc] init];

    NSArray* row = [rows objectAtIndex:rowNo];
    NSString* value = [row objectAtIndex:index];
    return value;
}

- (id) valueForIndex:(NSInteger) index inRow:(NSInteger) rowNo{
    NSArray* row = [rows objectAtIndex:rowNo];
    NSString* value = [row objectAtIndex:index];
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

    // set filename
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    [nameLabel setText:[self valueForField:@"name" inRow:indexPath.row]];
    
    // compute & set date
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
    NSTimeInterval epochTimeInterval = [[self valueForField:@"date" inRow:indexPath.row] doubleValue] / 1000;
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:epochTimeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    [dateLabel setText:[dateFormatter stringFromDate:epochNSDate]];
    
    // set sender information
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:102];
    NSString *sender = [self valueForField:@"sender" inRow:indexPath.row];
    if([sender isKindOfClass:[NSNull class]]) [detailLabel setText:@"Public File"];
    else [detailLabel setText:[NSString stringWithFormat:@"%@", [self valueForField:@"sender" inRow:indexPath.row]]];
    
    return cell;
}

#pragma mark - Image picker methods

- (IBAction)addButtonPressed:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
//    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if(![info objectForKey:UIImagePickerControllerOriginalImage]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // Get the image name from PhotoKit
    NSURL *pickedImageUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    NSMutableString *pickedImageName = [[NSMutableString alloc] init];
    NSMutableData *pickedImageData = [[NSMutableData alloc] init];
    
    PHAsset *pickedImageAsset = [[PHAsset fetchAssetsWithALAssetURLs:@[pickedImageUrl] options:nil] firstObject];
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    [imageRequestOptions setSynchronous:YES];
    [[PHImageManager defaultManager]
        requestImageDataForAsset:pickedImageAsset
                         options:imageRequestOptions
                   resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                       NSURL *pickedImagePath = [info objectForKey:@"PHImageFileURLKey"];
                       [pickedImageName appendString:[pickedImagePath lastPathComponent]];
                       [pickedImageData appendData:imageData];
                   }];
    

    ServalManager *m = [ServalManager sharedManager];
    
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    
    NSMutableData *body = [NSMutableData data];
    // add filename
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"manifest\"; filename=\"%@\"\r\n", pickedImageName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: rhizome/manifest\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    // add binary data
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"payload\"; filename=\"%@\"\r\n", pickedImageName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:pickedImageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setHeaders:@{@"Content-Type": contentType}];
        [request setUrl:@"http://localhost:4110/restful/rhizome/insert"];
        [request setUsername:[m restUser]];
        [request setPassword:[m restPassword]];
        [request setBody:body];
    }] asJson:&error];
    
    if(error){
        NSLog(@"Rhizome upload failed: %@", error.localizedDescription);
        return;
    }
    
    NSLog(@"Rhizome upload sucessful for image: %@", pickedImageName);

    [picker dismissViewControllerAnimated:YES completion:nil];
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
        
        // create request
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", servalUser, servalPassword];
        NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
        
        NSString* restfulUrl = [NSString stringWithFormat:@"http://localhost:4110/restful/rhizome/%@/decrypted.bin", [self valueForField:@"id" inRow:indexPath.row]];
        NSURL *url = [NSURL URLWithString: restfulUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];

        viewController.request = request;
        viewController.keys = header;
        viewController.values = [rows objectAtIndex:indexPath.row];
    }
}


@end
