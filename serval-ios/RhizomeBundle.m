//
//  RhizomeBundle.m
//  serval-ios
//
//  Created by Jonas Höchst on 31.01.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "RhizomeBundle.h"

@implementation RhizomeBundle

-(id) initWithRestfulRow:(NSArray*) row forHeader:(NSArray*) header{
    if(!(self = [super init]))
       return nil;
    
    for (int i = 0; i < [header count]; i++){
        if ([[header objectAtIndex:i] isEqualToString:@"service"])
            self.service = [row objectAtIndex:i];
        else if ([[header objectAtIndex:i] isEqualToString:@"id"])
            self.id = [row objectAtIndex:i];
//        else if ([[header objectAtIndex:i] isEqualToString:@"version"])
//            self.version = [row objectAtIndex:i];
        else if ([[header objectAtIndex:i] isEqualToString:@"date"]) {
            NSTimeInterval epochTimeInterval = [[row objectAtIndex:i] doubleValue] / 1000;
            self.date = [[NSDate alloc] initWithTimeIntervalSince1970:epochTimeInterval]; }
//        else if ([[header objectAtIndex:i] isEqualToString:@"filesize"])
//            self.filesize = [row objectAtIndex:i];
        else if ([[header objectAtIndex:i] isEqualToString:@"filehash"])
            self.filehash = [row objectAtIndex:i];
        else if ([[header objectAtIndex:i] isEqualToString:@"sender"])
            self.sender = [row objectAtIndex:i];
        else if ([[header objectAtIndex:i] isEqualToString:@"recipient"])
            self.recipient = [row objectAtIndex:i];
        else if ([[header objectAtIndex:i] isEqualToString:@"name"])
            self.name = [row objectAtIndex:i];
    }
    
    return self;
}

@end
