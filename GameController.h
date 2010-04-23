//
//  GameController.h
//  GLGamev2
//
//  Created by Michael Daley on 10/07/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SynthesizeSingleton.h"
#import "EAGLView.h"
#import "Global.h"

@class AbstractScene;
@class EAGLView;
@class SoundManager;

// Class responsbile for passing touch and game events to the correct game
// scene.  A game scene is an object which is responsible for a specific
// scene within the game i.e. Main menu, main game, high scores etc.
// The state manager hold the currently active scene and the game controller
// will then pass the necessary messages to that scene.
//
@interface GameController : NSObject {


	///////////////////// Singletons
	SoundManager *sharedSoundManager;				// Reference to the shared sound manager

	///////////////////// Views and orientation
	EAGLView *eaglView;						        // Reference to the EAGLView
	UIInterfaceOrientation interfaceOrientation;	// Devices interface orientation

    ///////////////////// Game controller iVars
	CGRect screenBounds;					// Bounds of the screen
    NSDictionary *gameScenes;				// Dictionary of the different game scenes
	NSArray *highScores;					// Sorted high scores array
	NSMutableArray *unsortedHighScores;		// Unsorted high scores array
    AbstractScene *currentScene;			// Current game scene being updated and rendered

	///////////////////// Game controller flags
	BOOL resumedGameAvailable;				// Can a game be resumed
	BOOL shouldResumeGame;					// Should the game being loaded be resumed
	BOOL gamePaused;						// Is the game paused

	///////////////////// Settings
	NSMutableDictionary *settings;			// Dictionary of the games settings i.e. joypad location and volumes
	NSString *settingsFilePath;				// Location of the settings file

}

@property (nonatomic, retain) EAGLView *eaglView;
@property (nonatomic, retain) AbstractScene *currentScene;
@property (nonatomic, retain) NSDictionary *gameScenes;
@property (nonatomic, retain) NSArray *highScores;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign) BOOL resumedGameAvailable;
@property (nonatomic, assign) BOOL shouldResumeGame;
@property (nonatomic, assign) BOOL gamePaused;

// Class method to return an instance of GameController.  This is needed as this
// class is a singleton class
+ (GameController *)sharedGameController;

// Updates the logic within the current scene
- (void)updateCurrentSceneWithDelta:(float)aDelta;

// Renders the current scene
- (void)renderCurrentScene;

// Causes the game controller to select a new scene as the current scene
- (void)transitionToSceneWithKey:(NSString*)aKey;

// Load the high scores
- (void)loadHighScores;

// Add a new score to the high scores list
- (void)addToHighScores:(int)score name:(NSString*)name wave:(int)wave;

// Save the current high scores table
- (void)saveHighScores;

// Deletes the game state file
- (void)deleteGameState;

// Loads the game settings such as volume and joypad location
- (void)loadSettings;

// Saves the current settings
- (void)saveSettings;

// Returns an adjusted touch point based on the orientation of the device
- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch;

@end
