//
//  RhizomeFileDetailViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 24.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "RhizomeFileDetailViewController.h"
#import "KeyValueTableViewController.h"

@interface RhizomeFileDetailViewController ()

@end

@implementation RhizomeFileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(presentInfoView:)];
                            
    self.navigationItem.rightBarButtonItem = infoButton;
    
    [[self webView] loadRequest:[self request]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presentInfoView:(id)sender {
    [KeyValueTableViewController presentTableViewForKeys:self.keys values:self.values fromView:self withTitle:@"Rhizome File Details"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
