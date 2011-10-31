//
//  LibraryViewController.h
//  sfxr
//
//  Copyright Christopher Gassib 2009.
//  This file is released under the MIT license as described in readme.txt
//

#import <UIKit/UIKit.h>

class sfxr;

@interface LibraryViewController : UIViewController
<MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {

    UITextField* saveTextField;
    sfxr* currentSoundFX;

    NSString* saveFile;
    std::streampos recordSize;
}

@property (nonatomic, readonly) UITextField* saveTextField;
@property (nonatomic, readonly) sfxr* currentSoundFX;

- (IBAction)saveFilenameEditingDidBegin:(id)sender;
- (IBAction)loadButtonPressed:(id)sender;
- (IBAction)mailButtonPressed:(id)sender;

@end
