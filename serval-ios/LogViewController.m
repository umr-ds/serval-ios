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
    
    NSString *str = [[NSString alloc] initWithData: [manager.logFile readDataToEndOfFile]
                                          encoding: NSASCIIStringEncoding];
    [self.logTextView setText:str];
    [self.logTextView scrollRangeToVisible:NSMakeRange(0, self.logTextView.contentSize.height)];
    
    [manager.logFile readInBackgroundAndNotify];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNotification:(NSNotification*) notification {
    ServalManager* manager = [ServalManager sharedManager];
    
    NSData *data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
    
    [self.logTextView setText:[self.logTextView.text stringByAppendingString:str]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // sleep on a secondary thread
        [NSThread sleepForTimeInterval: 1];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // read on main thread
            [manager.logFile readInBackgroundAndNotify];
        });
    });

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
