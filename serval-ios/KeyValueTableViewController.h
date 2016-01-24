//
//  KeyValueTableViewController.h
//  serval-ios
//
//  Created by Jonas Höchst on 24.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyValueTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSArray *values;

+ (void) presentTableViewForKeys:(NSArray*) keys values:(NSArray*) values fromView:(UIViewController*) root withTitle:(NSString*) title;

@end
