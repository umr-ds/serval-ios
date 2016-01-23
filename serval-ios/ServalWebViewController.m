//
//  ServalWebViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 23.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "ServalWebViewController.h"

@interface ServalWebViewController ()

@end

@implementation ServalWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlAddress = @"http://localhost:4110";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[self webView] loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
