//
//  ServalStatusViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 24.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "ServalStatusViewController.h"

@interface ServalStatusViewController ()

@end

@implementation ServalStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.request == nil){
        NSString *webStatusUrl = @"http://localhost:4110";
        NSURL *url = [NSURL URLWithString: webStatusUrl];
        self.request = [NSURLRequest requestWithURL:url];
    }
    [[self webView] loadRequest:self.request];
    [self.webView setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ServalStatusViewController *nextViewController = [storyboard instantiateViewControllerWithIdentifier:@"ServalStatusViewController"];

        nextViewController.request=request;
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        [[self navigationItem] setBackBarButtonItem:backButton];
        
        [self.navigationController pushViewController:nextViewController animated:YES];
        
        return NO;
    }
    return YES;
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
