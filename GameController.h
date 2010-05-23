//  GameController.h

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
	SoundManager *sharedSoundManager_;				// Reference to the shared sound manager

	///////////////////// Views and orientation
	EAGLView *eaglView_;						        // Reference to the EAGLView
	UIInterfaceOrientation interfaceOrientation_;	// Devices interface orientation

    ///////////////////// Game controller iVars
	CGRect screenBounds_;					// Bounds of the screen
    NSDictionary *gameScenes_;				// Dictionary of the different game scenes
	NSArray *highScores_;					// Sorted high scores array
	NSMutableArray *unsortedHighScores_;		// Unsorted high scores array
    AbstractScene *currentScene_;			// Current game scene being updated and rendered

}

@property (nonatomic, retain) EAGLView *eaglView_;
@property (nonatomic, retain) AbstractScene *currentScene_;
@property (nonatomic, retain) NSDictionary *gameScenes_;
@property (nonatomic, retain) NSArray *highScores_;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation_;

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

// Returns an adjusted touch point based on the orientation of the device
- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch;

@end
