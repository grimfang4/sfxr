//
//  FirstViewController.m
//  sfxr
//
//  Copyright Christopher Gassib 2009.
//  This file is released under the MIT license as described in readme.txt
//

#import "FirstViewController.h"
#import "sfxrAppDelegate.h"
#import "LibraryViewController.h"
#include "SampleSourceFunctor.h"
#include "sfxr.h"


@implementation FirstViewController


static sfxr* mySfxr = NULL;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (sfxr*)getSfxr {
    if (NULL == mySfxr)
    {
        UIApplication* app = [UIApplication sharedApplication];
        sfxrAppDelegate* appDelegate = (sfxrAppDelegate*)[app delegate];
        mySfxr = appDelegate.mySfxr;
    }
    return mySfxr;
}

- (void)viewWillAppear:(BOOL)animated {
    // Sync up the controls.
    UISlider* volumeSlider = (UISlider*)[self.view viewWithTag:1];
    volumeSlider.value = [self getSfxr]->GetSoundVolume();
}

- (IBAction)volumeSliderValueChanged:(id)sender {
    float sound_vol = [(UISlider*)sender value];
    [self getSfxr]->SetSoundVolume(sound_vol);
}

- (IBAction)playButtonPressed:(id)sender {
    [self getSfxr]->PlaySample();
}

- (IBAction)pickupCoinButtonPressed:(id)sender {
    [self getSfxr]->PickupCoinButtonPressed();
}

- (IBAction)laserShootButtonPressed:(id)sender {
    [self getSfxr]->LaserShootButtonPressed();
}

- (IBAction)explosionButtonPressed:(id)sender {
    [self getSfxr]->ExplosionButtonPressed();
}

- (IBAction)powerupButtonPressed:(id)sender {
    [self getSfxr]->PowerupButtonPressed();
}

- (IBAction)hitHurtButtonPressed:(id)sender {
    [self getSfxr]->HitHurtButtonPressed();
}

- (IBAction)jumpButtonPressed:(id)sender {
    [self getSfxr]->JumpButtonPressed();
}

- (IBAction)blitSelectButtonPressed:(id)sender {
    [self getSfxr]->BlitSelectButtonPressed();
}

- (IBAction)mutateButtonPressed:(id)sender {
    [self getSfxr]->MutateButtonPressed();
}

- (IBAction)randomizeButtonPressed:(id)sender {
    [self getSfxr]->RandomizeButtonPressed();
}

- (IBAction)saveButtonPressed:(id)sender {
    UIApplication* app = [UIApplication sharedApplication];
    sfxrAppDelegate* appDelegate = (sfxrAppDelegate*)[app delegate];
    [appDelegate tabBarController].selectedIndex = 2;
    UIViewController* viewController = [appDelegate tabBarController].selectedViewController;
    [[(LibraryViewController*)viewController saveTextField] becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
