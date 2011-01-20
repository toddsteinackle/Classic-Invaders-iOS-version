//  ClassicInvadersAppDelegate.m

#import "ClassicInvadersAppDelegate.h"
#import "Global.h"
#import "EAGLView.h"
#import "SoundManager.h"
#import "GameController.h"
#import "GameScene.h"
#import "MainMenuViewController.h"
#import <GameKit/GameKit.h>

BOOL isGameCenterAvailable()
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    return (gcClass && osVersionSupported);
}

@implementation ClassicInvadersAppDelegate

@synthesize window_;
@synthesize glView_;
@synthesize mainMenuViewController_;

- (void) dealloc
{
	[window_ release];
	[glView_ release];
	[super dealloc];
}

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
	// Grab a reference to the game and sound managers
	sharedGameController_ = [GameController sharedGameController];
	sharedSoundManager_ = [SoundManager sharedSoundManager];

	[glView_ setMultipleTouchEnabled:YES];

    sharedGameController_.interfaceOrientation_ = UIInterfaceOrientationLandscapeLeft;
	// Start getting device orientation notifications
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];

    [sharedGameController_ loadSettings];

	// Start the game
	[glView_ startAnimation];

    sharedGameController_.localPlayerAuthenticated_ = FALSE;
    if (isGameCenterAvailable()) {
#ifdef MYDEBUG
        NSLog(@"Game Center Available");
#endif
        [self authenticateLocalPlayer];
        [self registerForAuthenticationNotification];
        [mainMenuViewController_ setScoreButton];
    } else {
#ifdef MYDEBUG
        NSLog(@"Game Center Not Available");
#endif
        [mainMenuViewController_ setScoreButton];
    }
}

- (void) authenticateLocalPlayer
{
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
        if (error == nil)
        {
            // Insert code here to handle a successful authentication.
#ifdef MYDEBUG
            NSLog(@"player authenticated -- initial");
#endif
            sharedGameController_.localPlayerAuthenticated_ = TRUE;
            [mainMenuViewController_ setScoreButton];

        }
        else
        {
            // Your application can process the error parameter to report the error to the player.
#ifdef MYDEBUG
            NSLog(@"GC authenticateWithCompletionHandler error");
#endif
            sharedGameController_.localPlayerAuthenticated_ = FALSE;
            [mainMenuViewController_ setScoreButton];
        }
    }];
}

- (void) registerForAuthenticationNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector:@selector(authenticationChanged)
               name:GKPlayerAuthenticationDidChangeNotificationName
             object:nil];
}

- (void) authenticationChanged
{
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        // Insert code here to handle a successful authentication.
#ifdef MYDEBUG
        NSLog(@"player authenticated -- authenticationChanged");
#endif
        sharedGameController_.scoresRetrieved_ = FALSE;
        sharedGameController_.localPlayerAuthenticated_ = TRUE;
        [mainMenuViewController_ setScoreButton];
        [sharedGameController_ loadAndReportGKScores];
        [sharedGameController_ retrieveTopScores];
    } else {
#ifdef MYDEBUG
        NSLog(@"authenticationChanged player not authenticated");
#endif
        // Insert code here to clean up any outstanding Game Center-related classes.
        sharedGameController_.localPlayerAuthenticated_ = FALSE;
        [mainMenuViewController_ setScoreButton];
    }

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
    [sharedGameController_ saveSettings];
	// Stop the game loop
	[glView_ stopAnimation];

	// Enable the idle timer before we leave
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

@end

