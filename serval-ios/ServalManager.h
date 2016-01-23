//
//  ServalManager.h
//  serval-ios
//
//  Created by Jonas Höchst on 17.12.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServalManager : NSObject {
    NSString *someProperty;
//    keyring_file *keyring;
    
}

@property (nonatomic, retain) NSString *someProperty;

+ (id)sharedManager;

@end
