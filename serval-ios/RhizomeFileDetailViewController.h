//
//  RhizomeFileDetailViewController.h
//  serval-ios
//
//  Created by Jonas Höchst on 24.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RhizomeFileDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURLRequest *request;

@property (strong, nonatomic) NSArray *keys;
@property (strong, nonatomic) NSArray *values;

@end
