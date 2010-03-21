//  ClassicInvadersAppDelegate.m

#import "ClassicInvadersAppDelegate.h"
#import "Global.h"
#import "EAGLView.h"
#import "SoundManager.h"
#import "GameController.h"
#import "GameScene.h"

#pragma mark -
#pragma mark Private interface

@interface ClassicInvadersAppDelegate (Private)

// Loads the settings from the settings plist file into the
// sound manager
- (void)loadSettings;

@end

#pragma mark -
#pragma mark Public implementation

@implementation ClassicInvadersAppDelegate

@synthesize window_;
@synthesize glView_;

- (void) dealloc
{
	[window_ release];
	[glView_ release];
	[super dealloc];
}

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
	// Grab a reference to the sound manager
	sharedGameController_ = [GameController sharedGameController];
	sharedSoundManager_ = [SoundManager sharedSoundManager];

	[glView_ setMultipleTouchEnabled:YES];

	// Start getting device orientation notifications
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];

	// Load the settings from the plist file
	[sharedGameController_ loadSettings];

	// Start the game
	[glView_ startAnimation];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	// The game is resigning its active status i.e. a phone call, alarm or lock has occured.
	// We don't want the game to continue in this case so we stop the animation
	[glView_ stopAnimation];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	// If the game was paused when it resigned active then we don't want to
	// start the game again when the app becomes active
	if (!sharedGameController_.gamePaused)
		[glView_ startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Stop the game loop
	[glView_ stopAnimation];

	// Ask the game controller to save state and settings before quiting
	[sharedGameController_.currentScene saveGameState];
	[sharedGameController_ saveSettings];

	// Enable the idle timer before we leave
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

@end

