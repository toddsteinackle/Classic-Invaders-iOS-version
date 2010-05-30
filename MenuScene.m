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
#import "Score.h"

@implementation MenuScene

- (void)dealloc {
	[background_ release];
	[fadeImage_ release];

	[super dealloc];
}

// Set up the strings for the menu items
# define startString @"New Game"
# define scoreString @"High Scores"
# define helpString @"Help"
# define aboutString @"About"

- (id)init {

	if(self = [super init]) {

		// Set the name of this scene
		self.name_ = @"menu";

		sharedImageRenderManager_ = [ImageRenderManager sharedImageRenderManager];
		sharedGameController_ = [GameController sharedGameController];
		sharedSoundManager_ = [SoundManager sharedSoundManager];
		sharedTextureManager_ = [TextureManager sharedTextureManager];

        [sharedSoundManager_ loadSoundWithKey:@"guiTouch" soundFile:@"menu_select.caf"];

        alien1_ = [[Image alloc] initWithImageNamed:@"alien-1-2" ofType:@"png" filter:GL_LINEAR];
        alien2_ = [[Image alloc] initWithImageNamed:@"alien-2-1" ofType:@"png" filter:GL_LINEAR];
        alien3_ = [[Image alloc] initWithImageNamed:@"alien-3-1" ofType:@"png" filter:GL_LINEAR];
        alien4_ = [[Image alloc] initWithImageNamed:@"alien-1-1" ofType:@"png" filter:GL_LINEAR];
        alien5_ = [[Image alloc] initWithImageNamed:@"alien-2-4" ofType:@"png" filter:GL_LINEAR];

        help1_ = [[Image alloc] initWithImageNamed:@"alien-1-1" ofType:@"png" filter:GL_LINEAR];
        help2_ = [[Image alloc] initWithImageNamed:@"alien-2-1" ofType:@"png" filter:GL_LINEAR];
        help3_ = [[Image alloc] initWithImageNamed:@"alien-3-1" ofType:@"png" filter:GL_LINEAR];
        help4_ = [[Image alloc] initWithImageNamed:@"big-bonus-ui-gfx" ofType:@"png" filter:GL_LINEAR];
        help5_ = [[Image alloc] initWithImageNamed:@"small-bonus-ui-gfx" ofType:@"png" filter:GL_LINEAR];

        // Grab the bounds of the screen
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			screenBounds_ = CGRectMake(0, 0, 1024, 768);
		} else {
			screenBounds_ = CGRectMake(0, 0, 480, 320);
            PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                           controlFile:@"pss_coordinates"
                                                                           imageFilter:GL_LINEAR];
            background_ = [pss imageForKey:@"background.png"];

            menuFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"ci_menu_mono_30"
                                                            ofType:@"png"
                                                       controlFile:@"ci_menu_mono_30"
                                                             scale:Scale2fMake(0.95f, 0.95f)
                                                            filter:GL_LINEAR];
            monoMenuFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"ci_menu_mono_30"
                                                                ofType:@"png"
                                                           controlFile:@"ci_menu_mono_30"
                                                                 scale:Scale2fMake(0.85f, 0.85f)
                                                                filter:GL_LINEAR];
            monoScoreHighlingtFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"ci_menu_mono_30_purple"
                                                                          ofType:@"png"
                                                                     controlFile:@"ci_menu_mono_30_purple"
                                                                           scale:Scale2fMake(0.85f, 0.85f)
                                                                          filter:GL_LINEAR];

            monoHelpFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"ci_menu_mono_30"
                                                                ofType:@"png"
                                                           controlFile:@"ci_menu_mono_30"
                                                                 scale:Scale2fMake(0.75f, 0.75f)
                                                                filter:GL_LINEAR];

            fadeImage_ = [[Image alloc] initWithImageNamed:@"allBlack" ofType:@"png" filter:GL_NEAREST];
            fadeImage_.color = Color4fMake(1.0, 1.0, 1.0, 1.0);

            CGFloat alienScale = 1.75f;
            alien1_.scale = Scale2fMake(alienScale, alienScale);
            alien2_.scale = Scale2fMake(alienScale, alienScale);
            alien3_.scale = Scale2fMake(alienScale, alienScale);
            alien4_.scale = Scale2fMake(alienScale, alienScale);
            alien5_.scale = Scale2fMake(alienScale, alienScale);
		}

		// Init the fadespeed and alpha for this scene
		fadeSpeed_ = 1.0f;
		alpha_ = 1.0f;

		// Set the initial state for the menu
		state_ = SceneState_Idle;
	}
	return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
	switch (state_) {
		case SceneState_Running:

			break;

		case SceneState_TransitionIn:

			// Update the alpha value of the fadeImage
			alpha_ -= fadeSpeed_ * aDelta;
			fadeImage_.color = Color4fMake(1.0, 1.0, 1.0, alpha_);

			if(alpha_ < 0.0f) {
				alpha_ = 0.0f;
				state_ = SceneState_Running;
			}

			break;

		case SceneState_TransitionOut:

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
				state_ = SceneState_Idle;

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

    // Switch the idle timer back on as its not a problem if the phone locks while you are
	// at the menu.  This is recommended by apple and helps to save power
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    CGFloat x = 40.0f;
    CGFloat alienScale = 1.75f;
    CGFloat alienHeight = 30 * alienScale;
    CGFloat verticalPadding;

    verticalPadding = 22.5f;
    settingsButtonBounds_ = CGRectMake(x, verticalPadding, 400, alienHeight);
    instructionButtonBounds_ = CGRectMake(x, alienHeight+verticalPadding*2, 400, alienHeight);
    scoreButtonBounds_ = CGRectMake(x, alienHeight*2+verticalPadding*3, 400, alienHeight);
    startButtonBounds_ = CGRectMake(x, alienHeight*3+verticalPadding*4, 400, alienHeight);

    highScores_ = sharedGameController_.highScores_;
#ifdef MYDEBUG
    for (Score *s in highScores_) {
        NSLog(@"s -- %i, %@, %i, %i", s.score_, s.name_, s.wave_, s.isMostRecentScore_);
    }
#endif
    for (Score *s in highScores_) {
        if (s.isMostRecentScore_) {
            state_ = SceneState_Scores;
            return;
        }
    }
    state_ = SceneState_TransitionIn;
}

- (void)renderScene {

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

    } else {

        [background_ renderAtPoint:CGPointMake(0, 0)];
        if (state_ == SceneState_Running || state_ == SceneState_TransitionOut || state_ == SceneState_TransitionIn) {
            CGFloat x = 50.0f;
            CGFloat alienHeight = 30 * 1.75f;
            CGFloat verticalPadding;

            verticalPadding = 22.5f;
            [alien5_ renderAtPoint:CGPointMake(x, verticalPadding)];
            [menuFont_ renderStringJustifiedInFrame:settingsButtonBounds_ justification:BitmapFontJustification_MiddleCentered text:aboutString];

            [alien4_ renderAtPoint:CGPointMake(x, alienHeight+verticalPadding*2)];
            [menuFont_ renderStringJustifiedInFrame:instructionButtonBounds_ justification:BitmapFontJustification_MiddleCentered text:helpString];

            [alien3_ renderAtPoint:CGPointMake(x, alienHeight*2+verticalPadding*3)];
            [menuFont_ renderStringJustifiedInFrame:scoreButtonBounds_ justification:BitmapFontJustification_MiddleCentered text:scoreString];

            [alien1_ renderAtPoint:CGPointMake(x, alienHeight*3+verticalPadding*4)];
            [menuFont_ renderStringJustifiedInFrame:startButtonBounds_ justification:BitmapFontJustification_MiddleCentered text:startString];

            [sharedImageRenderManager_ renderImages];
        }
        if (state_ == SceneState_Scores) {
            [monoMenuFont_ renderStringAt:CGPointMake(5, 285) text:[NSString stringWithFormat:@"   %-11s%6s%9s", "Name", "Score", "Wave"]];
            [monoMenuFont_ renderStringAt:CGPointMake(5, 265) text:[NSString stringWithFormat:@"   %-11s%6s%9s", "====", "=====", "===="]];
            int i = 2; int j = 1; const char *name;

            BitmapFont *font;
            for (Score *s in highScores_) {
                if (s.isMostRecentScore_) {
                    font = monoScoreHighlingtFont_;
                } else {
                    font = monoMenuFont_;
                }

                name = [s.name_ UTF8String];
                if (j<10) {
                    [font renderStringAt:CGPointMake(5, 285-i*25)
                                             text:[NSString stringWithFormat:@" %d.%-11.10s%6d%9d", j++, name, s.score_, s.wave_]];
                    ++i;
                    [sharedImageRenderManager_ renderImages];
                    return;
                } else if (j == 10) {
                    [font renderStringAt:CGPointMake(5, 285-i*25)
                                             text:[NSString stringWithFormat:@"%d.%-11.10s%6d%9d", j++, name, s.score_, s.wave_]];
                    [sharedImageRenderManager_ renderImages];
                    return;
                }
            }
            [sharedImageRenderManager_ renderImages];
        }
        if (state_ == SceneState_Help) {

            int h = 265;
            int v = 35;
            [help1_ renderAtPoint:CGPointMake(50, h)];
            [help2_ renderAtPoint:CGPointMake(50, h-v)];
            [help3_ renderAtPoint:CGPointMake(50, h-v*2)];
            [help4_ renderAtPoint:CGPointMake(42, h-v*3)];
            [help5_ renderAtPoint:CGPointMake(50, h-v*4+5)];

            [monoHelpFont_ renderStringAt:CGPointMake(150, h) text:@"25"];
            [monoHelpFont_ renderStringAt:CGPointMake(150, h-v) text:@"50"];
            [monoHelpFont_ renderStringAt:CGPointMake(150, h-v*2) text:@"100"];
            [monoHelpFont_ renderStringAt:CGPointMake(150, h-v*3) text:@"1000"];
            [monoHelpFont_ renderStringAt:CGPointMake(150, h-v*4) text:@"2500"];

            [monoHelpFont_ renderStringAt:CGPointMake(50, h-v*4.85) text:@"Bonus ship every 10000."];
            [monoHelpFont_ renderStringAt:CGPointMake(50, h-v*5.7) text:@"Double tap top half of screen"];
            [monoHelpFont_ renderStringAt:CGPointMake(50, h-v*6.25) text:@"to pause a running wave."];

            int touchBoxWidth = 70;
            CGRect leftTouchControlBounds = CGRectMake(1, 1, touchBoxWidth, 35);
            CGRect rightTouchControlBounds = CGRectMake(screenBounds_.size.width - touchBoxWidth, 1, touchBoxWidth-1, 35);
            CGRect fireTouchControlBounds = CGRectMake(touchBoxWidth+1, 1, screenBounds_.size.width - 1 - touchBoxWidth*2, 35);

            [monoHelpFont_ renderStringJustifiedInFrame:leftTouchControlBounds justification:BitmapFontJustification_TopCentered text:@"Left"];
            [monoHelpFont_ renderStringJustifiedInFrame:rightTouchControlBounds justification:BitmapFontJustification_TopCentered text:@"Right"];
            [monoHelpFont_ renderStringJustifiedInFrame:fireTouchControlBounds justification:BitmapFontJustification_TopCentered text:@"Fire"];

            [sharedImageRenderManager_ renderImages];

            drawBox(leftTouchControlBounds);
			drawBox(rightTouchControlBounds);
			drawBox(fireTouchControlBounds);
        }
        if (state_ == SceneState_About) {
            CGRect top = CGRectMake(0, 200, 480, 40);
            CGRect middle = CGRectMake(0, 160, 480, 30);
            CGRect bottom = CGRectMake(0, 50, 480, 20);
            [menuFont_ renderStringJustifiedInFrame:top
                                      justification:BitmapFontJustification_MiddleCentered
                                               text:@"Programming and graphics by"];
            [menuFont_ renderStringJustifiedInFrame:middle
                                      justification:BitmapFontJustification_MiddleCentered
                                               text:@"Todd Steinackle"];
            [menuFont_ renderStringJustifiedInFrame:bottom
                                      justification:BitmapFontJustification_MiddleCentered
                                               text:@"www.noquarterarcade.com"];
            [sharedImageRenderManager_ renderImages];
        }
    }

	// If we are transitioning in, out or idle then render the fadeImage
	if (state_ == SceneState_TransitionIn || state_ == SceneState_TransitionOut || state_ == SceneState_Idle) {
		[fadeImage_ renderAtPoint:CGPointMake(0, 0)];
        [sharedImageRenderManager_ renderImages];
	}
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
	UITouch *touch = [[event touchesForView:aView] anyObject];

	// Get the point where the player has touched the screen
	CGPoint originalTouchLocation = [touch locationInView:aView];

	// As we have the game in landscape mode we need to switch the touches
	// x and y coordinates
	CGPoint touchLocation = [sharedGameController_ adjustTouchOrientationForTouch:originalTouchLocation];

	// We only want to check the touches on the screen when the scene is running.
	if (state_ == SceneState_Running) {
		// Check to see if the user touched the start button
		if (CGRectContainsPoint(startButtonBounds_, touchLocation)) {
			[sharedSoundManager_ playSoundWithKey:@"guiTouch" gain:0.5f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
			state_ = SceneState_TransitionOut;
			alpha_ = 0;
			return;
		}

		if (CGRectContainsPoint(scoreButtonBounds_, touchLocation)) {
			[sharedSoundManager_ playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
			alpha_ = 0;
			state_ = SceneState_Scores;
			return;
		}

		if (CGRectContainsPoint(instructionButtonBounds_, touchLocation)) {
			[sharedSoundManager_ playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
			alpha_ = 0;
			state_ = SceneState_Help;
			return;
		}

        if (CGRectContainsPoint(settingsButtonBounds_, touchLocation)) {
			[sharedSoundManager_ playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
			alpha_ = 0;
			state_ = SceneState_About;
			return;
		}

	}
    if (state_ == SceneState_Scores || state_ == SceneState_Help || state_ == SceneState_About) {
        if (CGRectContainsPoint(screenBounds_, touchLocation)) {
            [sharedSoundManager_ playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
            state_ = SceneState_Running;
            return;
        }
    }

}

@end
