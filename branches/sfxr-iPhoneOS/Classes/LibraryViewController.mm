//
//  LibraryViewController.mm
//  sfxr
//
//  Copyright Christopher Gassib 2009.
//  This file is released under the MIT license as described in readme.txt
//

#import "LibraryViewController.h"
#import "sfxrAppDelegate.h"
#include "SampleSourceFunctor.h"
#include "sfxr.h"
#include "AudioInterface.h"


const unsigned int fileVersion = 1;

@interface LibraryViewController()
@end

@implementation LibraryViewController

static sfxr* mySfxr = NULL;

@synthesize saveTextField;
@synthesize currentSoundFX;

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
    delete currentSoundFX;
    [saveFile dealloc];
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
    UITableView* tableView = (UITableView*)[self.view viewWithTag:4];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    saveTextField = (UITextField*)[self.view viewWithTag:5];

    currentSoundFX = new sfxr(*[self getSfxr]);
}

- (void)viewWillDisappear:(BOOL)animated {
    *([self getSfxr]) = *currentSoundFX;
}

- (IBAction)saveFilenameEditingDidBegin:(id)sender {
    UITextField* textField = (UITextField*)sender;
    textField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    // Read the soundFX name from the textbox.
    NSString* nameText = textField.text;
    if ([nameText length] == 0)
    {
        [textField resignFirstResponder];
        return NO;
    }
    const char* cstrNameText = [nameText cStringUsingEncoding:NSUTF8StringEncoding];
    std::string name(cstrNameText);

    std::vector<char> paddedName(32, '\0');
    const unsigned int length = std::min(32u, static_cast<unsigned int>(name.length()));
    for (unsigned int i = 0; i < length; i++)
    {
        paddedName[i] = name[i];
    }

    //////////////////////////////////////////

    const char* cstrPath = [saveFile cStringUsingEncoding:NSUTF8StringEncoding];

    const std::ios_base::openmode mode = std::ios_base::binary | 
        ((0 == recordSize) ? std::ios_base::trunc : std::ios_base::app);
    std::ofstream stream(cstrPath, mode);

    if (0 == recordSize)
    {
        stream.write(reinterpret_cast<const char*>(&fileVersion), sizeof(fileVersion));
    }

    stream.write(&paddedName[0], paddedName.size());

    [self getSfxr]->SaveSettings(stream);

    std::streampos lastWritePosition = stream.tellp();
    
    if (0 == recordSize)
    {
        recordSize = lastWritePosition;
        recordSize -= sizeof(fileVersion);
    }
    
    // Refresh the list view.
    const NSUInteger index = (0 == recordSize) ? 0 : (lastWritePosition / recordSize) - 1;
    NSUInteger indexNodes[2] = { 0, index };
    NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:indexNodes length:2];
    NSArray* indexPaths = [NSArray arrayWithObject:indexPath];
    UITableView* tableView = (UITableView*)[self.view viewWithTag:4];
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    // Get rid of the keyboard now.
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)loadButtonPressed:(id)sender {
    UITableView* tableView = (UITableView*)[self.view viewWithTag:4];
    NSIndexPath* indexPath = [tableView indexPathForSelectedRow];

    if (nil == indexPath)
    {
        return;
    }

    const unsigned int recordIndex = [indexPath indexAtPosition:1];

    //////////////////////////////////////////

    const char* cstrPath = [saveFile cStringUsingEncoding:NSUTF8StringEncoding];

    std::ifstream stream(cstrPath, std::ios_base::binary);
    stream.seekg(sizeof(fileVersion) + (recordSize * recordIndex));
    if (stream.good())
    {
        char name[32];
        stream.read(name, sizeof(name));
        if (stream.eof())
        {
            return;
        }

        currentSoundFX->LoadSettings(stream);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    const unsigned int recordIndex = [indexPath indexAtPosition:1];
    const char* cstrPath = [saveFile cStringUsingEncoding:NSUTF8StringEncoding];

    std::ifstream stream(cstrPath, std::ios_base::binary);
    stream.seekg(sizeof(fileVersion) + (recordSize * recordIndex));
    if (stream.good())
    {
        char name[32];
        stream.read(name, sizeof(name));
        if (stream.eof())
        {
            return;
        }

        [self getSfxr]->LoadSettings(stream);
    }

    [self getSfxr]->PlaySample();
}

- (IBAction)mailButtonPressed:(id)sender {
    UITableView* tableView = (UITableView*)[self.view viewWithTag:4];
    NSIndexPath* indexPath = [tableView indexPathForSelectedRow];
    NSString* soundFXName = @"SoundFX";

    if (nil != indexPath)
    {
        const unsigned int recordIndex = [indexPath indexAtPosition:1];
        const char* cstrPath = [saveFile cStringUsingEncoding:NSUTF8StringEncoding];

        std::ifstream stream(cstrPath, std::ios_base::binary);
        stream.seekg(sizeof(fileVersion) + (recordSize * recordIndex));
        if (stream.good())
        {
            char name[32];
            stream.read(name, sizeof(name));
            if (!stream.eof())
            {
                soundFXName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            }
        }
    }

    //////////////////////////////////////////

    NSString* tempDirectory = NSTemporaryDirectory();
    NSString* wavePath = [tempDirectory stringByAppendingPathComponent:@"sfxr.wav"];    
    const char* cstrPath = [wavePath cStringUsingEncoding:NSUTF8StringEncoding];
    [self getSfxr]->ExportWAV(cstrPath);

    NSString* settingsPath = [tempDirectory stringByAppendingPathComponent:@"sfxr.settings"];
    cstrPath = [settingsPath cStringUsingEncoding:NSUTF8StringEncoding];
    [self getSfxr]->SaveSettings(cstrPath);

    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:[soundFXName stringByAppendingString:@" exported from sfxr."]];

    // Attach the WAV to the email.
    NSData *myData1 = [NSData dataWithContentsOfFile:wavePath];
    [picker addAttachmentData:myData1 mimeType:@"audio/wav"
                                     fileName:@"sfxr.wav"];

    // Attach synth settings to the email.
    NSData *myData2 = [NSData dataWithContentsOfFile:settingsPath];
    [picker addAttachmentData:myData2 mimeType:@"application/x.sfxr"
                                     fileName:@"sfxr.settings"];

    // Fill out the email body text.
    NSString *emailBody = @"Wave file & settings attached.";
    [picker setMessageBody:emailBody isHTML:NO];

    // Present the mail composition interface.
    [self presentModalViewController:picker animated:YES];
    [picker release]; // Can safely release the controller now.
}

// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
              didFinishWithResult:(MFMailComposeResult)result
              error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    const char* cstrPath = [saveFile cStringUsingEncoding:NSUTF8StringEncoding];
    const unsigned int recordIndex = [indexPath indexAtPosition:1];

    std::vector<char> name(32, '\0');

    std::ifstream stream(cstrPath, std::ios_base::binary);
    stream.seekg(sizeof(fileVersion) + (recordSize * recordIndex));
    if (stream.good())
    {
        stream.read(&name[0], name.size());
    }

    static NSString* MyIdentifier = @"MyIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (nil == cell) // if (we didn't get a recycled cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
    }

    NSString* label = [NSString stringWithUTF8String:&name[0]];
    cell.textLabel.text = label;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // NOTE: Tried to use NSCachesDirectory, but it gets blown away like a temp directory between runs.
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* cacheDirectory = [paths objectAtIndex:0];
    
    // Cache the name of the save file that's being used.
    saveFile = [[NSString alloc] initWithString:[cacheDirectory stringByAppendingPathComponent:@"sfxr.sav"]];
    
    const char* cstrPath = [saveFile cStringUsingEncoding:NSUTF8StringEncoding];

    NSInteger rowCount = 0;

    std::ifstream stream(cstrPath, std::ios_base::binary);
    if (!stream.good())
    {
        return rowCount;
    }
    
    unsigned int version = 0;
    stream.read(reinterpret_cast<char*>(&version), sizeof(version));
    if (fileVersion < version)
    {
        recordSize = 0;
        return rowCount;
    }

    while (stream.good())
    {
        char name[32];
        stream.read(name, sizeof(name));
        if (stream.eof())
        {
            break;
        }

        sfxr temp;
        temp.LoadSettings(stream);
        
        // Now that a complete record has been read get the record size.
        if (0 == rowCount) // if (this is the first record)
        {
            recordSize = stream.tellg();
            recordSize -= sizeof(version);
        }

        rowCount++;
    }

    return rowCount;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete != editingStyle) // if (this method isn't called for delete)
    {
        return;
    }

    const unsigned int index = [indexPath indexAtPosition:1];
    unsigned int count = 0;

    // Read all settings from the file, except the one to be deleted.
    std::vector< std::pair<std::string, sfxr> > records;

    const char* cstrPath = [saveFile cStringUsingEncoding:NSUTF8StringEncoding];

    std::fstream stream(cstrPath, std::ios_base::in | std::ios_base::binary);
    if (!stream.good())
    {
        return;
    }
    
    unsigned int version = 0;
    stream.read(reinterpret_cast<char*>(&version), sizeof(version));
    if (fileVersion < version)
    {
        return;
    }
    
    while (stream.good())
    {
        char name[32];
        stream.read(name, sizeof(name));
        if (stream.eof())
        {
            break;
        }

        sfxr temp;
        temp.LoadSettings(stream);

        if (index != count) // if (this isn't the record to delete)
        {
            records.push_back(std::make_pair(name, temp));
        }
        count++;
    }
    stream.close();

    // Write all the settings back to the file.
    stream.open(cstrPath, std::ios_base::out | std::ios_base::binary | std::ios_base::trunc);
    
    version = fileVersion;
    stream.write(reinterpret_cast<const char*>(&version), sizeof(version));
    
    for (unsigned int i = 0; i < records.size(); i++)
    {
        std::vector<char> paddedName(32);
        const unsigned int length = std::min(32u, static_cast<unsigned int>(records[i].first.length()));
        unsigned int c;
        for (c = 0; c < length; c++)
        {
            paddedName[c] = records[i].first[c];
        }
        for ( ; c < 32u; c++)
        {
            paddedName[c] = '\0';
        }

        stream.write(&paddedName[0], paddedName.size());
        
        records[i].second.SaveSettings(stream);
    }
    stream.close();

    // Remove the table row.
    NSArray* indexPathsArray = [NSArray arrayWithObject:indexPath];

    [tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
}


@end
