//
//  GameController.m
//  GLGamev2
//
//  Created by Michael Daley on 10/07/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "GameController.h"
#import "ClassicInvadersAppDelegate.h"
#import "AbstractScene.h"
#import "SoundManager.h"
#import "GameScene.h"
#import "MenuScene.h"
#import "EAGLView.h"
#import "Score.h"

#pragma mark -
#pragma mark Private interface

@interface GameController (Private)
// Initializes OpenGL
- (void)initGameController;

// Sort the unsortedHighScores mutable array by score and date
- (void)sortHighScores;

// Sets up the path for reading the settings file
- (void)initSettingsFilePath;

@end

#pragma mark -
#pragma mark Public implementation

@implementation GameController

@synthesize currentScene;
@synthesize resumedGameAvailable;
@synthesize shouldResumeGame;
@synthesize gameScenes;
@synthesize eaglView;
@synthesize highScores;
@synthesize interfaceOrientation;
@synthesize gamePaused;

// Make this class a singleton class
SYNTHESIZE_SINGLETON_FOR_CLASS(GameController);

- (void)dealloc {

    [gameScenes release];
	[highScores release];
	[settingsFilePath release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if(self != nil) {

		// Initialize the game
        [self initGameController];
    }
    return self;
}

#pragma mark -
#pragma mark HighScores

- (void)loadHighScores {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

	NSMutableData *highScoresData;
    NSKeyedUnarchiver *decoder;

    // Check to see if the highScores.dat file exists and if so load the contents into the
    // highScores array
    NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"highScores.dat"];

	highScoresData = [NSData dataWithContentsOfFile:documentPath];

	if (highScoresData) {
		decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:highScoresData];
		unsortedHighScores = [[decoder decodeObjectForKey:@"highScores"] retain];
		[decoder release];
	} else {
		unsortedHighScores = [[NSMutableArray alloc] init];
	}

	[self sortHighScores];
}

- (void)saveHighScores {
	// Set up the game state path to the data file that the game state will be saved too.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *scoresPath = [documentsDirectory stringByAppendingPathComponent:@"highScores.dat"];

	// Set up the encoder and storage for the game state data
	NSMutableData *scores;
	NSKeyedArchiver *encoder;
	scores = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:scores];

	// Archive the entities
	[encoder encodeObject:unsortedHighScores forKey:@"highScores"];

	// Finish encoding and write the contents of gameData to file
	[encoder finishEncoding];
	[scores writeToFile:scoresPath atomically:YES];
	[encoder release];
}

- (void)addToHighScores:(int)score name:(NSString*)name wave:(int)wave {
	Score *s = [[Score alloc] initWithScore:score name:name wave:wave];
	[unsortedHighScores addObject:s];
	[s release];
	[self saveHighScores];
	[self sortHighScores];
}

#pragma mark -
#pragma mark Save game settings

- (void)deleteGameState {

	// Delete the gameState.dat file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *gameStatePath = [documentsDirectory stringByAppendingPathComponent:@"gameState.dat"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:gameStatePath error:NULL];

	// Flag that there is then no resume game available
	resumedGameAvailable = NO;
	shouldResumeGame = NO;
}

- (void)loadSettings {

	SLQLOG(@"INFO - EAGLView: Loading settings.");
	// If the prefs file has not been initialised then init the prefs file
	if(settingsFilePath == nil)
		[self initSettingsFilePath];

	// If the prefs file cannot be found then create it with default values
	if([[NSFileManager defaultManager] fileExistsAtPath:settingsFilePath]) {
		SLQLOG(@"INFO - GameController: Found settings file");
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsFilePath];
	} else {
		SLQLOG(@"INFO - GameController: No settings file, creating defaults");
		settings = [[NSMutableDictionary alloc] init];
		[settings setObject:[NSString stringWithFormat:@"%f", 0.7f] forKey:@"musicVolume"];
		[settings setObject:[NSString stringWithFormat:@"%f", 0.5f] forKey:@"fxVolume"];
	}

	// Get the prefs from the pref file and update the sound manager
	[sharedSoundManager setMusicVolume:[(NSString *)[settings valueForKey:@"musicVolume"] floatValue]];
	[sharedSoundManager setFxVolume:[(NSString *)[settings valueForKey:@"fxVolume"] floatValue]];

}

- (void)saveSettings {
	// Save the current settings to the apps prefs file
	NSNumber *mv = [NSNumber numberWithFloat:sharedSoundManager.musicVolume];
	NSNumber *fv = [NSNumber numberWithFloat:sharedSoundManager.fxVolume];
	[settings setObject:mv forKey:@"musicVolume"];
	[settings setObject:fv forKey:@"fxVolume"];
	[settings writeToFile:settingsFilePath atomically:YES];
	SLQLOG(@"INFO - GameController: Saving musicVolume=%f, fxVolume=%f", [mv floatValue], [fv floatValue]);
}

#pragma mark -
#pragma mark Update & Render

- (void)updateCurrentSceneWithDelta:(float)aDelta {
    [currentScene updateSceneWithDelta:aDelta];
}

-(void)renderCurrentScene {
    [currentScene renderScene];
}

#pragma mark -
#pragma mark Transition

- (void)transitionToSceneWithKey:(NSString*)aKey {

	// Set the current scene to the one specified in the key
	currentScene = [gameScenes objectForKey:aKey];

	// Run the transitionIn method inside the new scene
	[currentScene transitionIn];
}

#pragma mark -
#pragma mark Orientation adjustment

- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch {

	CGPoint touchLocation;

	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		touchLocation.x = aTouch.y;
		touchLocation.y = aTouch.x;
	}

	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            touchLocation.x = 1024 - aTouch.y;
            touchLocation.y = 768 - aTouch.x;
        } else {
            touchLocation.x = 480 - aTouch.y;
            touchLocation.y = 320 - aTouch.x;
        }
	}

	return touchLocation;
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation GameController (Private)

- (void)initGameController {

    SLQLOG(@"INFO - GameController: Starting game initialization.");

	// Set up the sound manager
	sharedSoundManager = [SoundManager sharedSoundManager];

	// Set the random number seed.  If we don't set this then each time the game is run we will get
	// the same numbers generated from the random macros in global.h
	srandomdev();

	// Settup the menu scenes
    gameScenes = [[NSMutableDictionary alloc] init];

    // Menu scene
	AbstractScene *scene = [[MenuScene alloc] init];
    [gameScenes setValue:scene forKey:@"menu"];
	[scene release];

	// Game scene
	scene = [[GameScene alloc] init];
	[gameScenes setValue:scene forKey:@"game"];
	[scene release];

    // Set the starting scene for the game
    currentScene = [gameScenes objectForKey:@"menu"];

	// Setup and load the highscores
	highScores = [[NSArray alloc] init];
	[self loadHighScores];

	// Get the path to the saved game state file
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"gameState.dat"];

	// By default a saved game does exist
	resumedGameAvailable = YES;

	// By default the game is not paused
	gamePaused = NO;

	// ...and if it doesn't then flag it
	if (![fileManager fileExistsAtPath:documentPath])
		resumedGameAvailable = NO;

	// By default we are not going to start from a resumed game.  This is set to YES if the
	// resume game option is selected from the main menu
	shouldResumeGame = NO;

    // Set the initial scenes state
    [currentScene transitionIn];

    SLQLOG(@"INFO - GameController: Finished game initialization.");
}

- (void)sortHighScores {
	// Sort the high score data using the score and then the date and time.  For this we need to create two
	// sort descriptors using the score and wave properties of the score object
	NSSortDescriptor *scoreSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"score_" ascending:NO] autorelease];
	NSSortDescriptor *waveSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"wave_" ascending:NO] autorelease];

	// We then place the sort descriptors we want to use into an array of sortDescriptors
	NSArray *sortDescriptors = [NSArray arrayWithObjects:scoreSortDescriptor, waveSortDescriptor, nil];

	// We have a retain on highScores, so we release that before loading the sorted data into the highScores array
	[highScores release];

	// Load the highScores array with the sorted data from the unsortedHighScores array
	highScores = [[unsortedHighScores sortedArrayUsingDescriptors:sortDescriptors] retain];
}

- (void)initSettingsFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask,
														 YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	settingsFilePath = [documentsDirectory stringByAppendingPathComponent:@"cinvaders.plist"];
	[settingsFilePath retain];
}

- (void)startGame {
	gamePaused = NO;
}

- (void)pauseGame {
	gamePaused = YES;
}

@end
