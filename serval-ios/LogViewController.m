//
//  LogViewController.m
//  serval-ios
//
//  Created by Jonas Höchst on 23.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "LogViewController.h"
#import "ServalManager.h"

@interface LogViewController ()

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ServalManager* manager = [ServalManager sharedManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name: NSFileHandleReadCompletionNotification
                                               object: manager.logFile];
    [manager.logFile readInBackgroundAndNotify];
    [self.logTextView setText:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNotification:(NSNotification*) notification {
    ServalManager* manager = [ServalManager sharedManager];
    
    [manager.logFile readInBackgroundAndNotify];
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
