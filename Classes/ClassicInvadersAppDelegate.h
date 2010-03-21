//  ClassicInvadersAppDelegate.h

#import <UIKit/UIKit.h>

@class EAGLView;
@class SoundManager;
@class GameController;

@interface ClassicInvadersAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window_;
    EAGLView *glView_;

	// Sound manager reference
	SoundManager *sharedSoundManager_;
	GameController *sharedGameController_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window_;
@property (nonatomic, retain) IBOutlet EAGLView *glView_;

@end

