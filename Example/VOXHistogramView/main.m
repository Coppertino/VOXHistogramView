//
//  main.m
//  VOXHistogramView
//
//  Created by Nickolay Sheika on 06/27/2015.
//  Copyright (c) 2014 Nickolay Sheika. All rights reserved.
//

@import UIKit;
#import "VOXAppDelegate.h"

static bool isRunningTests()
{
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, isRunningTests() ? nil : NSStringFromClass([VOXAppDelegate class]));
    }
}
