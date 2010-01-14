//
//  SettingsViewController.h
//  sfxr
//
//  Copyright Christopher Gassib 2009.
//  This file is released under the MIT license as described in readme.txt
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController {

}

- (IBAction)volumeSliderValueChangedSettingsView:(id)sender;
- (IBAction)playButtonPressedSettingsView:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)waveSelectorChanged:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;

@end
