//
//  sfxrAppDelegate.m
//  sfxr
//
//  Copyright Christopher Gassib 2009.
//  This file is released under the MIT license as described in readme.txt
//

#import "sfxrAppDelegate.h"
#import "FirstViewController.h"
#import "LibraryViewController.h"
#include "SampleSourceFunctor.h"
#include "AudioInterface.h"
#include "sfxr.h"

@interface sfxrAppDelegate()

@property (nonatomic, assign) NSTimer* animationTimer;

- (void)restoreSession;
- (void)saveSession;

@end


@implementation sfxrAppDelegate


@synthesize window;
@synthesize tabBarController;

@synthesize animationTimer;

@synthesize audioInterface;
@synthesize mySfxr;

const unsigned int sessionFileVersion = 1;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    audioInterface = new AudioInterface;
    mySfxr = new sfxr;
    
    application.statusBarStyle = UIStatusBarStyleBlackOpaque;
    
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];

    audioInterface->SetSampleSource(mySfxr);
    
    [self restoreSession];
}

- (void)applicationWillResignActive:(UIApplication*)application
{
    [self stopAnimation];
    [self saveSession];
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    self.animationInterval = 1.0 / 60.0;
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    [self stopAnimation];
    [self saveSession];
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

- (void)dealloc {
    audioInterface->SetSampleSource(NULL);
    delete mySfxr;
    delete audioInterface;

    [tabBarController release];
    [window release];
    [super dealloc];
}

- (void)pumpGameLoop
{
    audioInterface->Update();
}

- (void)startAnimation
{
	self.animationTimer = [NSTimer
                           scheduledTimerWithTimeInterval:animationInterval
                           target:self
                           selector:@selector(pumpGameLoop) // drawView
                           userInfo:nil
                           repeats:YES
                           ];
}

- (void)stopAnimation
{
    [animationTimer invalidate];
	self.animationTimer = nil;
}

- (void)setAnimationTimer:(NSTimer*)newTimer
{
	[animationTimer invalidate];
	animationTimer = newTimer;
}

- (NSTimeInterval)animationInterval
{
    return animationInterval;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	animationInterval = interval;
	if (animationTimer)
    {
		[self stopAnimation];
	}
    [self startAnimation];
}

- (void)restoreSession {
    // NOTE: Tried to use NSCachesDirectory, but it gets blown away like a temp directory between runs.
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* cacheDirectory = [paths objectAtIndex:0];
    NSString* saveFile = [[NSString alloc] initWithString:[cacheDirectory stringByAppendingPathComponent:@"sfxr.session"]];

    // Get a c-string version for std:: stream APIs.
    const char* cstrPath = [saveFile cStringUsingEncoding:NSUTF8StringEncoding];
    
    std::ifstream stream(cstrPath, std::ios_base::binary);
    if (stream.fail())
    {
        return;
    }

    // Check file version.
    unsigned int version = 0;
    stream.read(reinterpret_cast<char*>(&version), sizeof(version));
    if (version > sessionFileVersion)
    {
        return;
    }

    // Attempt to select the last tab in use.
    NSUInteger selectedTabIndex = 0;
    stream.read(reinterpret_cast<char*>(&selectedTabIndex), sizeof(selectedTabIndex));
    [self tabBarController].selectedIndex = selectedTabIndex;

    // Attempt to load up the last soundFX.
    std::streampos soundFXPosition = stream.tellg(); // mark the current stream position.
    mySfxr->LoadSettings(stream);
    if (selectedTabIndex == 2)
    {
        stream.seekg(soundFXPosition); // rewind, and load it again.
        ((LibraryViewController*)[self tabBarController].selectedViewController).currentSoundFX->LoadSettings(stream);
    }
    else
    {
        // Force any other view to reset the synth patch settings.
        [[self tabBarController].selectedViewController viewWillAppear:NO];
    }
}

- (void)saveSession {
    // NOTE: Tried to use NSCachesDirectory, but it gets blown away like a temp directory between runs.
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* cacheDirectory = [paths objectAtIndex:0];
    NSString* saveFile = [[NSString alloc] initWithString:[cacheDirectory stringByAppendingPathComponent:@"sfxr.session"]];

    // Get a c-string version for std:: stream APIs.
    const char* cstrPath = [saveFile cStringUsingEncoding:NSUTF8StringEncoding];

    std::ofstream stream(cstrPath, std::ios_base::binary | std::ios_base::trunc);
    if (stream.fail())
    {
        return;
    }

    // Write the file version.
    const unsigned int version = sessionFileVersion;
    stream.write(reinterpret_cast<const char*>(&version), sizeof(version));

    // Record the current tab in use.
    const NSUInteger selectedTabIndex = [self tabBarController].selectedIndex;
    stream.write(reinterpret_cast<const char*>(&selectedTabIndex), sizeof(selectedTabIndex));

    // Save the current soundFX.
    if (selectedTabIndex != 2)
    {
        mySfxr->SaveSettings(stream);
    }
    else
    {
        ((LibraryViewController*)[self tabBarController].selectedViewController).currentSoundFX->SaveSettings(stream);
    }
}


@end
