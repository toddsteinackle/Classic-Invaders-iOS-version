//  ClassicInvadersAppDelegate.h

#import <UIKit/UIKit.h>

@class EAGLView;
@class SoundManager;
@class GameController;
@class MainMenuViewController;

@interface ClassicInvadersAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window_;
    EAGLView *glView_;

	// Sound manager reference
	SoundManager *sharedSoundManager_;
	GameController *sharedGameController_;
    MainMenuViewController *mainMenuViewController_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window_;
@property (nonatomic, retain) IBOutlet EAGLView *glView_;
@property (nonatomic, assign) MainMenuViewController *mainMenuViewController_;

- (void) authenticateLocalPlayer;
- (void) registerForAuthenticationNotification;
- (void) authenticationChanged;

@end

