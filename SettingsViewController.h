//
//  SettingsViewController.h
//  ClassicInvaders
//
//  Created by Todd Steinackle on 7/5/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SoundManager;
@class GameController;

@interface SettingsViewController : UIViewController {

    SoundManager *sharedSoundManager;
	GameController *sharedGameController;

    IBOutlet UISlider *bgVolume;
	IBOutlet UISlider *fxVolume;
	IBOutlet UISegmentedControl *buttonPositions;
    IBOutlet UISegmentedControl *graphicsChoice;

}

// Used to hide the settings view
- (IBAction)hide:(id)aSender;

// Sets the music volume within the sound manager class when the music volume
// slider on the settings view is changed
- (IBAction)backgroundValueChanged:(UISlider*)sender;

// Sets the fx volume within the sound manager class when the fx volume
// slider on the settings view is changed
- (IBAction)fxValueChanged:(UISlider*)sender;

- (IBAction)buttonPositionsChanged:(UISegmentedControl*)sender;

- (IBAction)grahicsChoiceChanged:(UISegmentedControl*)sender;

@end
