//
//  RhizomeFilesTableViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 17.12.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#import "RhizomeFilesTableViewController.h"
#import "RhizomeFileDetailViewController.h"
#import "ServalManager+RestfulRhizome.h"
#import "RhizomeBundle.h"
#import <UNIRest.h>
@import MobileCoreServices;
@import Photos;


@interface RhizomeFilesTableViewController ()

@end

@implementation RhizomeFilesTableViewController

//NSTimer* refreshTimer;
NSArray* rhizomeBundles;

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

//- (void)viewDidAppear:(BOOL)animated{
//    NSLog(@"viewDidAppear");
//}
//
//- (void)viewDidDisappear:(BOOL)animated{
//    
//    NSLog(@"viewDidDisappear");
//}

- (void)pulledToRefresh{
    [self refreshBundlelist];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)refreshBundlelist{
    rhizomeBundles = [ServalManager getRhizomeBundles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - rhizome response access methods

//- (NSInteger) indexOfField:(NSString*) field {
//    for (int i = 0; i < [header count]; i++){
//        if ( [[header objectAtIndex:i] isEqualToString: field] ){
//            return i;
//        }
//    }
//    return -1;
//}
//
//- (NSInteger) rhizomeFileCount{
//    NSInteger serviceIndex = [self indexOfField:@"service"];
//    NSInteger count = 0;
//    for (NSArray* row in rows) {
//        if ([[row objectAtIndex:serviceIndex] isEqualToString:@"file"]) count++;
//    }
//    return count;
//}
//
//- (id) valueForField:(NSString*) field inRow:(NSInteger) rowNo{
//    NSInteger index = [self indexOfField:field];
//    if (index == -1) return [[NSNull alloc] init];
//
//    NSArray* row = [rows objectAtIndex:rowNo];
//    NSString* value = [row objectAtIndex:index];
//    return value;
//}
//
//- (id) valueForIndex:(NSInteger) index inRow:(NSInteger) rowNo{
//    NSArray* row = [rows objectAtIndex:rowNo];
//    NSString* value = [row objectAtIndex:index];
//    return value;
//}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [rhizomeBundles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RhizomeFilesCell" forIndexPath:indexPath];

    RhizomeBundle *b = [rhizomeBundles objectAtIndex:indexPath.row];
    
    // set filename
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    [nameLabel setText: b.name];
    
    // compute & set date
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    [dateLabel setText:[dateFormatter stringFromDate:b.date]];
    
    // set sender information
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:102];
    if([b.sender isKindOfClass:[NSNull class]]) [detailLabel setText:@"Public File"];
    else [detailLabel setText:[NSString stringWithFormat:@"%@", b.sender]];
    
    return cell;
}

#pragma mark - Image picker methods

- (IBAction)addButtonPressed:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // enables videos
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, (NSString *) kUTTypeImage, nil];
    
    // imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
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
    
    NSError *error;
    NSDictionary *response = [ServalManager addRhizomeFile:pickedImageData withName:pickedImageName error:error];
    NSLog(@"Image uploaded: %@", response);
    
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
        RhizomeBundle *b = [rhizomeBundles objectAtIndex:indexPath.row];
        
        RhizomeFileDetailViewController *viewController = segue.destinationViewController;
        viewController.title = b.name;
        
        viewController.request = [ServalManager requestForRhizomeBundle:b];
    }
}


@end
