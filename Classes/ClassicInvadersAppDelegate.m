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

    sharedGameController_.interfaceOrientation_ = UIInterfaceOrientationLandscapeLeft;
	// Start getting device orientation notifications
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];

	// Load the settings from the plist file
	[sharedGameController_ loadSettings];

	// Start the game
	[glView_ startAnimation];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	// The game is resigning its active status i.e. a phone call, alarm or lock has occured.
	// We don't want the game to continue in this case so we stop the animation
    if ([sharedGameController_.currentScene_.name_ isEqualToString:@"game"] &&
        sharedGameController_.currentScene_.state_ == SceneState_Running) {
        [sharedGameController_.currentScene_ initPause];
    }
	[glView_ stopAnimation];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    if ([sharedGameController_.currentScene_.name_ isEqualToString:@"game"]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    [glView_ startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Stop the game loop
	[glView_ stopAnimation];

	// Ask the game controller to save state and settings before quiting
	[sharedGameController_.currentScene_ saveGameState];
	[sharedGameController_ saveSettings];

	// Enable the idle timer before we leave
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

@end

