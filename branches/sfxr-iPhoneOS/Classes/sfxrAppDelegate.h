//
//  sfxrAppDelegate.h
//  sfxr
//
//  Copyright Christopher Gassib 2009.
//  This file is released under the MIT license as described in readme.txt
//

#import <UIKit/UIKit.h>

class AudioInterface;
class sfxr;

@interface sfxrAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;

	NSTimer* animationTimer;
	NSTimeInterval animationInterval;

    AudioInterface* audioInterface;
    sfxr* mySfxr;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property NSTimeInterval animationInterval;
@property (nonatomic) AudioInterface* audioInterface;
@property (nonatomic) sfxr* mySfxr;

- (void)startAnimation;
- (void)stopAnimation;
- (void)pumpGameLoop;

@end
