//
//  LogViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 23.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "LogViewController.h"

@interface LogViewController ()

@end

@implementation LogViewController
NSFileHandle* logfileHandle;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *homePath = NSHomeDirectory();
    logfileHandle = [NSFileHandle fileHandleForReadingAtPath:[homePath stringByAppendingPathComponent:@"Library/serval.log"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name: NSFileHandleReadCompletionNotification
                                               object: logfileHandle];
    [logfileHandle readInBackgroundAndNotify];
    [self.logTextView setText:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNotification:(NSNotification*) notification {
    [logfileHandle readInBackgroundAndNotify];
    NSString *str = [[NSString alloc] initWithData:[[notification userInfo] objectForKey: NSFileHandleNotificationDataItem]
                                          encoding: NSASCIIStringEncoding];
    
    [self.logTextView setText:[self.logTextView.text stringByAppendingString:str]];
//    [self.logTextView     scrollRangeToVisible:NSMakeRange([self.logTextView.text length], 0)];

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
