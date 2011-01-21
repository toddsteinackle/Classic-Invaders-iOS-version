//
//  GameController.m
//

#import "GameController.h"
#import "ClassicInvadersAppDelegate.h"
#import "AbstractScene.h"
#import "SoundManager.h"
#import "GameScene.h"
#import "MenuScene.h"
#import "EAGLView.h"
#import "Score.h"
#import "SettingsViewController.h"
#import "LeaderboardViewController.h"
#import <GameKit/GameKit.h>

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

@synthesize currentScene_;
@synthesize gameScenes_;
@synthesize eaglView_;
@synthesize highScores_;
@synthesize interfaceOrientation_;
@synthesize buttonPositions_;
@synthesize graphicsChoice_;
@synthesize localPlayerAuthenticated_;
@synthesize leaderBoardScores_;
@synthesize playerAlias_;
@synthesize localPlayerScore_;
@synthesize scoresRetrieved_;
@synthesize playerAliasesRetrieved_;

// Make this class a singleton class
SYNTHESIZE_SINGLETON_FOR_CLASS(GameController);

- (void)dealloc {

    [gameScenes_ release];
	[highScores_ release];
    [settingsViewController_ release];
    [gkScores_ release];
    [leaderboardRequest release];
    [playerAlias_ release];
    [playerIDs release];
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
		unsortedHighScores_ = [[decoder decodeObjectForKey:@"highScores"] retain];
		[decoder release];
	} else {
		unsortedHighScores_ = [[NSMutableArray alloc] init];
	}

	[self sortHighScores];
}

- (void)saveHighScores {
	// Set up the path to the data file that the scores will be saved too.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *scoresPath = [documentsDirectory stringByAppendingPathComponent:@"highScores.dat"];

	// Set up the encoder and storage for scores
	NSMutableData *scores;
	NSKeyedArchiver *encoder;
	scores = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:scores];

	// Archive the scores
	[encoder encodeObject:unsortedHighScores_ forKey:@"highScores"];

	// Finish encoding and write the contents of scores to file
	[encoder finishEncoding];
	[scores writeToFile:scoresPath atomically:YES];
	[encoder release];
}

- (void)addToHighScores:(int)score name:(NSString*)name wave:(int)wave {
	Score *s = [[Score alloc] initWithScore:score name:name wave:wave];
	[unsortedHighScores_ addObject:s];
	[s release];
	[self saveHighScores];
	[self sortHighScores];
}

#pragma mark -
#pragma mark Game Center

- (void)retrieveTopScores {

    if (leaderboardRequest != nil) {
#ifdef MYDEBUG
        NSLog(@"leaderboardRequest != nil");
#endif
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.range = NSMakeRange(1,25);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            leaderboardRequest.category = @"com.noquarterarcade.classicinvaders.iPadLeaderboard";
        } else {
            leaderboardRequest.category = @"com.noquarterarcade.classicinvaders.iPhoneLeaderboard";
        }
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {

            if (error != nil)
            {
                // handle the error.
                NSLog(@"Scores not retrieved from Game Center.");
                NSLog(@"%@", error);
            }

            if (scores != nil)
            {
                // process the score information.
                leaderBoardScores_ = scores;
                for (GKScore *gkScore in leaderBoardScores_) {
                    [playerIDs addObject:gkScore.playerID];
                }
                [self loadPlayerData:playerIDs];
#ifdef MYDEBUG
                NSLog(@"retrieveTopScores");
                for (GKScore *gkScore in leaderBoardScores_) {
                    NSLog(@"%@", gkScore);
                }
#endif
                localPlayerScore_ = leaderboardRequest.localPlayerScore;
                scoresRetrieved_ = TRUE;
#ifdef MYDEBUG
                NSLog(@"localPlayerScore_");
                NSLog(@"%@", localPlayerScore_);
#endif
            } else {
#ifdef MYDEBUG
                NSLog(@"scores nil");
#endif
                leaderBoardScores_ = scores;
                localPlayerScore_ = leaderboardRequest.localPlayerScore;
                scoresRetrieved_ = TRUE;
#ifdef MYDEBUG
                NSLog(@"localPlayerScore_");
                NSLog(@"%@", localPlayerScore_);
#endif
            }
        }];
    }
}

- (void)loadPlayerData:(NSArray *)identifiers {

    [GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray *players, NSError *error) {

        if (error != nil)
        {

            // Handle the error.
            NSLog(@"error loading player data");
            NSLog(@"%@", error);

        }

        if (players != nil)
        {

            // Process the array of GKPlayer objects.
            for (GKPlayer *gkPlayer in players) {
                [playerAlias_ setObject:gkPlayer.alias forKey:gkPlayer.playerID];
            }
            playerAliasesRetrieved_ = TRUE;
#ifdef MYDEBUG
            NSLog(@"loadPlayerData");
            NSEnumerator *enumerator = [playerAlias_ keyEnumerator];
            id aKey = nil;
            while ( (aKey = [enumerator nextObject]) != nil) {
                id value = [playerAlias_ objectForKey:aKey];
                NSLog(@"%@: %@", aKey, value);
            }

#endif
        }

    }];

}

- (void)saveGKScores {
	// Set up the path to the data file that the scores will be saved too.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *scoresPath = [documentsDirectory stringByAppendingPathComponent:@"GKScores.dat"];

	// Set up the encoder and storage for scores
	NSMutableData *scores;
	NSKeyedArchiver *encoder;
	scores = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:scores];

	// Archive the scores
	[encoder encodeObject:gkScores_ forKey:@"GKScores"];

	// Finish encoding and write the contents of scores to file
	[encoder finishEncoding];
	[scores writeToFile:scoresPath atomically:YES];
	[encoder release];
}

- (void)loadAndReportGKScores {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

	NSMutableData *highScoresData;
    NSKeyedUnarchiver *decoder;

    // Check to see if the GKScores.dat file exists and if so load the contents into the
    // highScores array
    NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"GKScores.dat"];

	highScoresData = [NSData dataWithContentsOfFile:documentPath];

	if (highScoresData) {
		decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:highScoresData];
		gkScores_ = [[decoder decodeObjectForKey:@"GKScores"] retain];
		[decoder release];
#ifdef MYDEBUG
        NSLog(@"before calling reportScore in loadAndReportGKScores");
        for (GKScore *gkScore in gkScores_) {
            NSLog(@"%@", gkScore);
        }
#endif
        for (GKScore *gkScore in gkScores_) {

            [gkScore reportScoreWithCompletionHandler:^(NSError *error) {

                if (error != nil) {
                    NSLog(@"%@", error);
                } else {
                    [gkScores_ removeObject:gkScore];
                    [self saveGKScores];
                    scoresRetrieved_ = FALSE;
                    playerAliasesRetrieved_ = FALSE;
                    [self retrieveTopScores];
#ifdef MYDEBUG
                    NSLog(@"%@", gkScore.category);
                    NSLog(@"score object removed");
                    for (GKScore *gkScore in gkScores_) {
                        NSLog(@"%@", gkScore);
                    }
#endif
                }

            }];
        }
	}
}

- (void)reportScore:(int64_t)score forCategory:(NSString*)category
{
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
	scoreReporter.value = score;
    [gkScores_ addObject:scoreReporter];
    [self saveGKScores];
#ifdef MYDEBUG
    NSLog(@"before calling Game Center in reportScore");
    for (GKScore *gkScore in gkScores_) {
        NSLog(@"%@", gkScore);
    }
#endif
	[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {

		if (error != nil) {
			NSLog(@"%@", error);
		} else {
            [gkScores_ removeObject:scoreReporter];
            [self saveGKScores];
            scoresRetrieved_ = FALSE;
            playerAliasesRetrieved_ = FALSE;
            [self retrieveTopScores];
#ifdef MYDEBUG
            NSLog(@"score object removed");
            for (GKScore *gkScore in gkScores_) {
                NSLog(@"%@", gkScore);
            }
#endif
        }

	}];
}

#pragma mark -
#pragma mark Update & Render

- (void)updateCurrentSceneWithDelta:(float)aDelta {
    [currentScene_ updateSceneWithDelta:aDelta];
}

-(void)renderCurrentScene {
    [currentScene_ renderScene];
}

#pragma mark -
#pragma mark Transition

- (void)transitionToSceneWithKey:(NSString*)aKey {

	// Set the current scene to the one specified in the key
	currentScene_ = [gameScenes_ objectForKey:aKey];

	// Run the transitionIn method inside the new scene
	[currentScene_ transitionIn];
}

#pragma mark -
#pragma mark Orientation adjustment

- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch {

	CGPoint touchLocation;

	if (interfaceOrientation_ == UIInterfaceOrientationLandscapeRight) {
		touchLocation.x = aTouch.y;
		touchLocation.y = aTouch.x;
	}

	if (interfaceOrientation_ == UIInterfaceOrientationLandscapeLeft) {
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

- (void)loadSettings {
#ifdef MYDEBUG
	SLQLOG(@"INFO - EAGLView: Loading settings.");
#endif
	// If the prefs file has not been initialised then init the prefs file
	if(settingsFilePath == nil)
		[self initSettingsFilePath];

	// If the prefs file cannot be found then create it with default values
	if([[NSFileManager defaultManager] fileExistsAtPath:settingsFilePath]) {
#ifdef MYDEBUG
		SLQLOG(@"INFO - GameController: Found settings file");
#endif
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsFilePath];
	} else {
#ifdef MYDEBUG
		SLQLOG(@"INFO - GameController: No settings file, creating defaults");
#endif
		settings = [[NSMutableDictionary alloc] init];
		[settings setObject:[NSString stringWithFormat:@"%f", 1.0f] forKey:@"bgVolume"];
		[settings setObject:[NSString stringWithFormat:@"%f", 1.0f] forKey:@"fxVolume"];
		[settings setObject:[NSNumber numberWithInt:1] forKey:@"buttonsPosition"];
        [settings setObject:[NSNumber numberWithInt:0] forKey:@"graphicsChoice"];
	}

	// Get the prefs from the pref file and update the sound manager
	[sharedSoundManager_ setBgVolume:[(NSString *)[settings valueForKey:@"bgVolume"] floatValue]];
	[sharedSoundManager_ setFxVolume:[(NSString *)[settings valueForKey:@"fxVolume"] floatValue]];
	buttonPositions_ = [[settings valueForKey:@"buttonsPosition"] intValue];
    graphicsChoice_ = [[settings valueForKey:@"graphicsChoice"] intValue];

	// Now that the settings values have been updated from the settings file, post a notification
	// which causes the sliders on the settings view to be updated with the new values.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"updateSettingsSliders" object:self];
}

- (void)saveSettings {
	// Save the current settings to the apps prefs file
	NSNumber *bv = [NSNumber numberWithFloat:sharedSoundManager_.bgVolume];
	NSNumber *fv = [NSNumber numberWithFloat:sharedSoundManager_.fxVolume];
	NSNumber *bp = [NSNumber numberWithInt:buttonPositions_];
    NSNumber *gc = [NSNumber numberWithInt:graphicsChoice_];
	[settings setObject:bv forKey:@"bgVolume"];
	[settings setObject:fv forKey:@"fxVolume"];
	[settings setObject:bp forKey:@"buttonsPosition"];
    [settings setObject:gc forKey:@"graphicsChoice"];
	[settings writeToFile:settingsFilePath atomically:YES];
#ifdef MYDEBUG
	SLQLOG(@"INFO - GameController: Saving bgVolume=%f, fxVolume=%f, buttonsPosition=%d, graphicsChoice=%d",
           [bv floatValue], [fv floatValue], [bp intValue], [gc intValue]);
#endif
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation GameController (Private)

- (void)initGameController {
#ifdef MYDEBUG
    SLQLOG(@"INFO - GameController: Starting game initialization.");
#endif
	// Set up the sound manager
	sharedSoundManager_ = [SoundManager sharedSoundManager];

	// Set the random number seed.  If we don't set this then each time the game is run we will get
	// the same numbers generated from the random macros in global.h
	srandomdev();

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        settingsViewController_ = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController-iPad" bundle:[NSBundle mainBundle]];
        leaderboardViewController_ = [[LeaderboardViewController alloc] initWithNibName:@"LeaderboardViewController-iPad" bundle:[NSBundle mainBundle]];
    } else {
        settingsViewController_ = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
        leaderboardViewController_ = [[LeaderboardViewController alloc] initWithNibName:@"LeaderboardViewController" bundle:[NSBundle mainBundle]];
    }

	// Settup the menu scenes
    gameScenes_ = [[NSMutableDictionary alloc] init];

    // Menu scene
	AbstractScene *scene = [[MenuScene alloc] init];
    [gameScenes_ setValue:scene forKey:@"menu"];
	[scene release];

	// Game scene
	scene = [[GameScene alloc] init];
	[gameScenes_ setValue:scene forKey:@"game"];
	[scene release];

    // Set the starting scene for the game
    currentScene_ = [gameScenes_ objectForKey:@"menu"];

	// Setup and load the highscores
	highScores_ = [[NSArray alloc] init];
	[self loadHighScores];

    gkScores_ = [[NSMutableArray alloc] init];
    leaderboardRequest = [[GKLeaderboard alloc] init];
    playerAlias_ = [[NSMutableDictionary alloc] init];
    playerIDs = [[NSMutableArray alloc] init];

    // Set the initial scenes state
    [currentScene_ transitionIn];
#ifdef MYDEBUG
    SLQLOG(@"INFO - GameController: Finished game initialization.");
#endif
}

- (void)sortHighScores {
	// Sort the high score data using the score and then the date and time.  For this we need to create two
	// sort descriptors using the score and wave properties of the score object
	NSSortDescriptor *scoreSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"score_" ascending:NO] autorelease];
	NSSortDescriptor *waveSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"wave_" ascending:NO] autorelease];

	// We then place the sort descriptors we want to use into an array of sortDescriptors
	NSArray *sortDescriptors = [NSArray arrayWithObjects:scoreSortDescriptor, waveSortDescriptor, nil];

	// We have a retain on highScores, so we release that before loading the sorted data into the highScores array
	[highScores_ release];

	// Load the highScores array with the sorted data from the unsortedHighScores array
	highScores_ = [[unsortedHighScores_ sortedArrayUsingDescriptors:sortDescriptors] retain];
}

- (void)initSettingsFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask,
														 YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	settingsFilePath = [documentsDirectory stringByAppendingPathComponent:@"cinvaders.plist"];
	[settingsFilePath retain];
}

@end
