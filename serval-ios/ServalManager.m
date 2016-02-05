//
//  ServalManager.m
//  serval-ios
//
//  Created by Jonas Höchst on 17.12.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#import "ServalManager.h"
#import <UNIRest.h>
#import <libserval/serval.h>
#import <libserval/conf.h>

// copied from serval_main.c
#include <signal.h>

@interface ServalManager ()

@property (nonatomic, strong) NSThread* servaldThread;
@property (nonatomic, strong) NSString* instancePath;
@property (nonatomic, strong) NSString* confPath;

@end

@implementation ServalManager

#pragma mark - Singleton Methods

+ (id)sharedManager {
    static ServalManager *sharedServalManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServalManager = [[self alloc] init];
    });
    return sharedServalManager;
}

- (id) init {
    if(!(self = [super init]))
        return nil;
    
    self.instancePath = [NSString stringWithFormat:@"%@/Library",NSHomeDirectory()];
    setenv("SERVALINSTANCE_PATH", [self.instancePath cStringUsingEncoding:NSASCIIStringEncoding], 1);
    
    self.confPath = [NSString stringWithFormat:@"%@/serval.conf", self.instancePath];
    self.restUser = @"ios";
    self.restPassword = @"password";
    return self;
}

# pragma mark - serval daemon helpers

- (void) testOrCopyConfig {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:self.confPath]){
        NSLog(@"serval.conf is missing, copying default configuration...");
        
        NSString *confPath_bundle = [[NSBundle mainBundle] pathForResource:@"serval.conf" ofType:nil];
        NSError *error;
        
        if (![fm copyItemAtPath:confPath_bundle toPath:self.confPath error:&error]) {
            NSLog(@"Error occured copying config file: %@", error);
        }
    }
}

- (void) overwriteConfig {
    NSLog(@"replacing serval.conf with default configuration...");
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *confPath_bundle = [[NSBundle mainBundle] pathForResource:@"serval.conf" ofType:nil];
    NSError *error;
    
    BOOL success = [fm removeItemAtPath:self.confPath error:&error];
    if (!success) NSLog(@"Error removing config file: %@", error.localizedDescription);
    
    success = [fm copyItemAtPath:confPath_bundle toPath:self.confPath error:&error];
    if (!success) NSLog(@"Error copying config file: %@", error.localizedDescription);
}

- (void) wipeLogs {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString* logFilePath =[NSString stringWithFormat:@"%@/serval.log", self.instancePath];
    NSString* logFolderPath =[NSString stringWithFormat:@"%@/log/", self.instancePath];
    
    NSError *error;
    BOOL success = [fm removeItemAtPath:logFilePath error:&error];
    if (!success) NSLog(@"Error removing log file: %@", error.localizedDescription);
    
    success = [fm removeItemAtPath:logFolderPath error:&error];
    if (!success) NSLog(@"Error removing log folder: %@", error.localizedDescription);
    
}

- (void) wipeRhizomeDB {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString* instancePath = [NSString stringWithFormat:@"%@/rhizome.db", self.instancePath];
    
    NSError *error;
    BOOL success = [fm removeItemAtPath:instancePath error:&error];
    if (!success) NSLog(@"Error removing instance files: %@", error.localizedDescription);
}

#pragma mark - serval configuration

- (BOOL) setConfigOption:(NSString*) option toValue:(NSString*) value{
    if([self.servaldThread isExecuting]){
        [self servaldCommand:@[@"help"]];
//        [self servaldCommand: @[@"config", @"set", option, value]];
        return TRUE;
    }
    return FALSE;
}

+ (NSString*) getConfig{
    ServalManager *m = [ServalManager sharedManager];
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:m.confPath encoding:NSUTF8StringEncoding error:&error];
    return content;
}


#pragma mark - serval daemon start/stops

+ (void)startServald {
    ServalManager *m = [ServalManager sharedManager];
//    [self testOrCopyConfig];
    [m overwriteConfig];
    [m wipeLogs];
//    [m wipeRhizomeDB];
    
    NSLog(@"%@", m.instancePath);
    
    
    if(m.servaldThread == nil || [m.servaldThread isCancelled] || [m.servaldThread isFinished]){
        // start thread
        m.servaldThread = [m dispatchServalCommand:@[@"start",@"foreground"]];
        
        NSString* logFilePath =[NSString stringWithFormat:@"%@/serval.log", m.instancePath];
        int i = 0;
        // busy-wait until file logfile exists
        while (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath] && i < 10){
            [NSThread sleepForTimeInterval:0.1];
        }
        
        m.logFile = [NSFileHandle fileHandleForReadingAtPath:logFilePath];
        [m setConfigOption:@"server.motd" toValue:[[UIDevice currentDevice] name]];

    } else if([m.servaldThread isExecuting]){
        NSLog(@"servald is already running.");
        return;
    } else {
        NSLog(@"Unknow state of servald thread");
    }
}

+ (void)stopServald {
    ServalManager *m = [ServalManager sharedManager];
    
    if(m.servaldThread == nil || [m.servaldThread isCancelled] || [m.servaldThread isFinished]){
        NSLog(@"servald has already stopped.");
        return;
    } else if([m.servaldThread isExecuting]){
        [m.servaldThread cancel];
    } else {
        NSLog(@"Unknow state of servald thread");
    }
}

#pragma mark - serval invoke methods

- (NSThread*) dispatchServalCommand:(NSArray*) ns_argv{
    NSThread* servalThread = [[NSThread alloc] initWithTarget:self selector:@selector(servaldCommand:) object:ns_argv];
    [servalThread start];
    
    [NSThread sleepForTimeInterval:1];
    return servalThread;
}

#pragma mark - servald commandline method

char crash_handler_clue[1024] = "no clue";

- (void) servaldCommand:(NSArray*) ns_argv{
    char* argv[[ns_argv count]+1];
    int argc = 0;
    
    argv[argc++] = "servald"; // stub: name of the binary
    for(NSString* arg in ns_argv){
        argv[argc] = calloc([arg length]+1, 1);
        strncpy(argv[argc], [arg UTF8String], [arg length]);
        argc++;
    }
    
    srandomdev();
    cf_init();
    parseCommandLine(NULL, argv[0], argc - 1, (const char*const*)&argv[1]);
}


@end
