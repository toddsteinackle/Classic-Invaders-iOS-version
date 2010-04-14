//  MenuScene.m

#import "MenuScene.h"
#import "Primatives.h"
#import "Global.h"
#import "ImageRenderManager.h"
#import "GameController.h"
#import "Image.h"
#import "BitmapFont.h"
#import "SoundManager.h"
#import "TextureManager.h"
#import "PackedSpriteSheet.h"
#import "SpriteSheet.h"

@implementation MenuScene

- (void)dealloc {
	[background_ release];
	[fadeImage_ release];

	[super dealloc];
}

// Set up the strings for the menu items
# define startString @"New Game"
# define resumeString @"Resume Game"
# define scoreString @"Score"
# define creditString @"Credits"

- (id)init {

	if(self = [super init]) {

		// Set the name of this scene
		self.name_ = @"menu";

		sharedImageRenderManager_ = [ImageRenderManager sharedImageRenderManager];
		sharedGameController_ = [GameController sharedGameController];
		sharedSoundManager_ = [SoundManager sharedSoundManager];
		sharedTextureManager_ = [TextureManager sharedTextureManager];

        // Grab the bounds of the screen
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			screenBounds_ = CGRectMake(0, 0, 1024, 768);
		} else {
			screenBounds_ = CGRectMake(0, 0, 480, 320);
		}

        PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                       controlFile:@"pss_coordinates"
                                                                       imageFilter:GL_LINEAR];
		background_ = [pss imageForKey:@"background.png"];

		fadeImage_ = [[Image alloc] initWithImageNamed:@"allBlack" ofType:@"png" filter:GL_NEAREST];
		fadeImage_.color = Color4fMake(1.0, 1.0, 1.0, 1.0);

        alien1_ = [[Image alloc] initWithImageNamed:@"alien-1-2" ofType:@"png" filter:GL_LINEAR];
        alien1_.scale = Scale2fMake(2.0f, 2.0f);

		// Init the fadespeed and alpha for this scene
		fadeSpeed_ = 1.0f;
		alpha_ = 1.0f;

		// Define the bounds for the buttons being used on the menu
		startButtonBounds = CGRectMake((screenBounds_.size.width - 90) / 2,
                                       (screenBounds_.size.height - 60) / 2, 90, 60);
		scoreButtonBounds = CGRectMake(71, 178, 135, 50);
		instructionButtonBounds = CGRectMake(74, 120, 144, 50);
		resumeButtonBounds = CGRectMake(74, 61, 142, 50);

		// Set the initial state for the menu
		state_ = kSceneState_Idle;
	}
	return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
	switch (state_) {
		case kSceneState_Running:

			break;

		case kSceneState_TransitionIn:

			// Update the alpha value of the fadeImage
			alpha_ -= fadeSpeed_ * aDelta;
			fadeImage_.color = Color4fMake(1.0, 1.0, 1.0, alpha_);

			if(alpha_ < 0.0f) {
				alpha_ = 0.0f;
				state_ = kSceneState_Running;
			}

			break;

		case kSceneState_TransitionOut:

			// Adjust the alpha value of the fadeImage.  This will cause the image to move from transparent to opaque
			alpha_ += fadeSpeed_ * aDelta;
			fadeImage_.color = Color4fMake(1.0, 1.0, 1.0, alpha_);

			// Check to see if the image is now fully opache.  If so then the fade is finished
			if(alpha_ > 1.0f) {
				alpha_ = 1.0f;

				// The render routine will not be called for this scene past this point, so we have added
				// a render of the fadeImage here so that the menu scene is completely removed.  Without this
				// it was sometimes possible to see the main menu faintly.
				[fadeImage_ renderAtPoint:CGPointMake(0, 0)];
				[sharedImageRenderManager_ renderImages];

				// This scene is now idle
				state_ = kSceneState_Idle;

				// Stop the idletimer from kicking in while playing the game.  This stops the screen from fading
				// during game play
				[[UIApplication sharedApplication] setIdleTimerDisabled:YES];

				// Ask the game controller to transition to the scene called game.
				[sharedGameController_ transitionToSceneWithKey:@"game"];
			}
			break;

		default:
			break;
	}
}

- (void)transitionIn {
	// Load GUI sounds

    // Switch the idle timer back on as its not a problem if the phone locks while you are
	// at the menu.  This is recommended by apple and helps to save power
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];

	state_ = kSceneState_TransitionIn;
}

- (void)renderScene {

	// Render the background
	[background_ renderAtPoint:CGPointMake(0, 0)];
    [alien1_ renderAtPoint:CGPointMake((screenBounds_.size.width - 90) / 2, (screenBounds_.size.height - 60) / 2)];

	// Check with the game controller to see if a saved game is available
	if ([sharedGameController_ resumedGameAvailable]) {
		//[menuButton renderAtPoint:CGPointMake(71, 60)];
	}

	// If we are transitioning in, out or idle then render the fadeImage
	if (state_ == kSceneState_TransitionIn || state_ == kSceneState_TransitionOut || state_ == kSceneState_Idle) {
		[fadeImage_ renderAtPoint:CGPointMake(0, 0)];
	}

	// Having rendered our images we ask the render manager to actually put then on screen.
	[sharedImageRenderManager_ renderImages];

// If debug is on then display the bounds of the buttons
//#ifdef MYDEBUG
//	drawBox(startButtonBounds);
//	drawBox(scoreButtonBounds);
//	drawBox(instructionButtonBounds);
//	drawBox(resumeButtonBounds);
//#endif

}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
	UITouch *touch = [[event touchesForView:aView] anyObject];

	// Get the point where the player has touched the screen
	CGPoint originalTouchLocation = [touch locationInView:aView];

	// As we have the game in landscape mode we need to switch the touches
	// x and y coordinates
	CGPoint touchLocation = [sharedGameController_ adjustTouchOrientationForTouch:originalTouchLocation];

	// We only want to check the touches on the screen when the scene is running.
	if (state_ == kSceneState_Running) {
		// Check to see if the user touched the start button
		if (CGRectContainsPoint(startButtonBounds, touchLocation)) {
			[sharedSoundManager_ playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
			state_ = kSceneState_TransitionOut;
			sharedGameController_.shouldResumeGame = NO;
			alpha_ = 0;
			return;
		}
//
//		if (CGRectContainsPoint(scoreButtonBounds, touchLocation)) {
//			[sharedSoundManager_ playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
//			alpha_ = 0;
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"showHighScore" object:self];
//			return;
//		}
//
//		if (CGRectContainsPoint(instructionButtonBounds, touchLocation)) {
//			[sharedSoundManager_ playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
//			alpha_ = 0;
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"showInstructions" object:self];
//			return;
//		}

		// If the resume button is visible then check to see if the player touched
		// the resume button
//		if ([sharedGameController_ resumedGameAvailable] && CGRectContainsPoint(resumeButtonBounds, touchLocation)) {
//			[sharedSoundManager_ playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
//			alpha_ = 0;
//			[sharedGameController_ setShouldResumeGame:YES];
//			state_ = kSceneState_TransitionOut;
//			return;
//		}
	}
}

@end
