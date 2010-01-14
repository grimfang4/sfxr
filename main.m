//
//  main.m
//  sfxr
//
//  Copyright Christopher Gassib 2009.
//  This file is released under the MIT license as described in readme.txt
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}

