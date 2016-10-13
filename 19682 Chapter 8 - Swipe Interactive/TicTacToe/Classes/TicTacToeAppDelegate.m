//
//  TicTacToeAppDelegate.m
//  TicTacToe
//
//  Created by Swipe Interactive on 3/10/09.
//  Copyright Swipe Interactive 2009. All rights reserved.
//

#import "TicTacToeAppDelegate.h"
#import "TicTacToeViewController.h"

@implementation TicTacToeAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
