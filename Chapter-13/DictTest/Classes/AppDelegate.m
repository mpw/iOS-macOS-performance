//
//  AppDelegate.m
//  DictTest
//
//  Created by Wagner Truppel on 4/14/09.
//  Copyright Wagner Truppel 2009. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

@synthesize window;
@synthesize viewController;

// ========================================================================= //

- (void) applicationDidFinishLaunching: (UIApplication*) application
{
    // NSLog(@"AppDelegate: -applicationDidFinishLaunching");

    NSLog(@"sizeof long: %lu",sizeof(long));
    [window addSubview: viewController.view];
    [window makeKeyAndVisible];
}

// ========================================================================= //

- (void) dealloc
{
    // NSLog(@"AppDelegate: -dealloc");

    [viewController release];
    [window release];
    [super dealloc];
}

// ========================================================================= //

@end
