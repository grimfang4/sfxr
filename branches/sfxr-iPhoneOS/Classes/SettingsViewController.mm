//
//  SettingsViewController.m
//  sfxr
//
//  Copyright Christopher Gassib 2009.
//  This file is released under the MIT license as described in readme.txt
//

#import "SettingsViewController.h"
#import "sfxrAppDelegate.h"
#import "LibraryViewController.h"
#include "SampleSourceFunctor.h"
#include "sfxr.h"


@implementation SettingsViewController

static sfxr* mySfxr = NULL;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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
    
    UISegmentedControl* waveSelector = (UISegmentedControl*)[self.view viewWithTag:3];
    const WaveformGenerator waveformGenerator = [self getSfxr]->GetWaveform();
    switch (waveformGenerator) {
        case SquareWave:
            waveSelector.selectedSegmentIndex = 0;
            break;
        case Sawtooth:
            waveSelector.selectedSegmentIndex = 1;
            break;
        case SineWave:
            waveSelector.selectedSegmentIndex = 2;
            break;
        case Noise:
            waveSelector.selectedSegmentIndex = 3;
            break;
        default:
            abort();
    }
    
    UISlider* slider;

    slider = (UISlider*)[self.view viewWithTag:4];
    slider.value = [self getSfxr]->GetAttackTime();

    slider = (UISlider*)[self.view viewWithTag:5];
    slider.value = [self getSfxr]->GetSustainTime();

    slider = (UISlider*)[self.view viewWithTag:6];
    slider.value = [self getSfxr]->GetSustainPunch();

    slider = (UISlider*)[self.view viewWithTag:7];
    slider.value = [self getSfxr]->GetDecayTime();

    slider = (UISlider*)[self.view viewWithTag:8];
    slider.value = [self getSfxr]->GetStartFrequency();

    slider = (UISlider*)[self.view viewWithTag:9];
    slider.value = [self getSfxr]->GetMinimumFrequency();

    slider = (UISlider*)[self.view viewWithTag:10];
    slider.value = [self getSfxr]->GetSlide();

    slider = (UISlider*)[self.view viewWithTag:11];
    slider.value = [self getSfxr]->GetDeltaSlide();

    slider = (UISlider*)[self.view viewWithTag:12];
    slider.value = [self getSfxr]->GetVibratoDepth();

    slider = (UISlider*)[self.view viewWithTag:13];
    slider.value = [self getSfxr]->GetVibratoSpeed();

    slider = (UISlider*)[self.view viewWithTag:14];
    slider.value = [self getSfxr]->GetChangeAmount();

    slider = (UISlider*)[self.view viewWithTag:15];
    slider.value = [self getSfxr]->GetChangeSpeed();

    slider = (UISlider*)[self.view viewWithTag:16];
    slider.value = [self getSfxr]->GetSquareDuty();

    slider = (UISlider*)[self.view viewWithTag:17];
    slider.value = [self getSfxr]->GetDutySweep();

    slider = (UISlider*)[self.view viewWithTag:18];
    slider.value = [self getSfxr]->GetRepeatSpeed();

    slider = (UISlider*)[self.view viewWithTag:19];
    slider.value = [self getSfxr]->GetPhaserOffset();

    slider = (UISlider*)[self.view viewWithTag:20];
    slider.value = [self getSfxr]->GetPhaserSweep();

    slider = (UISlider*)[self.view viewWithTag:21];
    slider.value = [self getSfxr]->GetLowPassFilterCutoff();

    slider = (UISlider*)[self.view viewWithTag:22];
    slider.value = [self getSfxr]->GetLowPassFilterCutoffSweep();

    slider = (UISlider*)[self.view viewWithTag:23];
    slider.value = [self getSfxr]->GetLowPassFilterResonance();

    slider = (UISlider*)[self.view viewWithTag:24];
    slider.value = [self getSfxr]->GetHighPassFilterCutoff();

    slider = (UISlider*)[self.view viewWithTag:25];
    slider.value = [self getSfxr]->GetHighPassFilterCutoffSweep();
}

- (IBAction)volumeSliderValueChangedSettingsView:(id)sender {
    float sound_vol = [(UISlider*)sender value];
    [self getSfxr]->SetSoundVolume(sound_vol);
}

- (IBAction)playButtonPressedSettingsView:(id)sender {
    [self getSfxr]->PlaySample();
}

- (IBAction)waveSelectorChanged:(id)sender {
    UISegmentedControl* waveformSelector = (UISegmentedControl*)sender;
    const NSInteger waveform = waveformSelector.selectedSegmentIndex;
    switch (waveform) {
        case 0:
            [self getSfxr]->SetWaveform(SquareWave);
            break;
        case 1:
            [self getSfxr]->SetWaveform(Sawtooth);
            break;
        case 2:
            [self getSfxr]->SetWaveform(SineWave);
            break;
        case 3:
            [self getSfxr]->SetWaveform(Noise);
            break;
        default:
            abort();
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    const float value = [(UISlider*)sender value];
    const NSInteger tag = [(UIView*)sender tag];
    sfxr* model = [self getSfxr];

    switch (tag) {
        case 4:
            model->SetAttackTime(value);
            break;
        case 5:
            model->SetSustainTime(value);
            break;
        case 6:
            model->SetSustainPunch(value);
            break;
        case 7:
            model->SetDecayTime(value);
            break;
        case 8:
            model->SetStartFrequency(value);
            break;
        case 9:
            model->SetMinimumFrequency(value);
            break;
        case 10:
            model->SetSlide(value);
            break;
        case 11:
            model->SetDeltaSlide(value);
            break;
        case 12:
            model->SetVibratoDepth(value);
            break;
        case 13:
            model->SetVibratoSpeed(value);
            break;
        case 14:
            model->SetChangeAmount(value);
            break;
        case 15:
            model->SetChangeSpeed(value);
            break;
        case 16:
            model->SetSquareDuty(value);
            break;
        case 17:
            model->SetDutySweep(value);
            break;
        case 18:
            model->SetRepeatSpeed(value);
            break;
        case 19:
            model->SetPhaserOffset(value);
            break;
        case 20:
            model->SetPhaserSweep(value);
            break;
        case 21:
            model->SetLowPassFilterCutoff(value);
            break;
        case 22:
            model->SetLowPassFilterCutoffSweep(value);
            break;
        case 23:
            model->SetLowPassFilterResonance(value);
            break;
        case 24:
            model->SetHighPassFilterCutoff(value);
            break;
        case 25:
            model->SetHighPassFilterCutoffSweep(value);
            break;
        default:
            break;
    }
}

- (IBAction)saveButtonPressed:(id)sender {
    UIApplication* app = [UIApplication sharedApplication];
    sfxrAppDelegate* appDelegate = (sfxrAppDelegate*)[app delegate];
    [appDelegate tabBarController].selectedIndex = 2;
    UIViewController* viewController = [appDelegate tabBarController].selectedViewController;
    [[(LibraryViewController*)viewController saveTextField] becomeFirstResponder];
}


@end
