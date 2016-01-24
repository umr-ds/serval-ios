//
//  ServalStatusViewController.h
//  serval-ios
//
//  Created by Jonas Höchst on 24.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServalStatusViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURLRequest* request;

@end
