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
#import "Animation.h"
#import "MainMenuViewController.h"

@implementation MenuScene

- (void)dealloc {
	[background_ release];
	[fadeImage_ release];

    [alien1_ release];
    [alien2_ release];
    [alien3_ release];
    [alien4_ release];
    [alien5_ release];
    [alien6_ release];

    [help1_ release];
    [help2_ release];
    [help3_ release];
    [help4_ release];
    [help5_ release];
    [help6_ release];
    [help7_ release];
    [help8_ release];
    [help9_ release];
    [help10_ release];

    [menuFont_ release];
    [monoMenuFont_ release];
    [monoScoreHighlightFont_ release];
    [monoHelpFont_ release];
    [mainMenuViewController_ release];

	[super dealloc];
}

- (id)init {

	if(self = [super init]) {

		// Set the name of this scene
		self.name_ = @"menu";

		sharedImageRenderManager_ = [ImageRenderManager sharedImageRenderManager];
		sharedGameController_ = [GameController sharedGameController];
		sharedSoundManager_ = [SoundManager sharedSoundManager];
		sharedTextureManager_ = [TextureManager sharedTextureManager];

        [sharedSoundManager_ loadSoundWithKey:@"guiTouch" soundFile:@"menu_select.caf"];

        PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"menu_pss.png"
                                                                       controlFile:@"menu_pss"
                                                                       imageFilter:GL_LINEAR];

        Image *Invaders = [[pss imageForKey:@"invaders.png"] retain];
        Image *SmallBonuses = [[pss imageForKey:@"small_bonuses.png"] retain];
        Image *BigBonuses = [[pss imageForKey:@"big_bonuses.png"] retain];

        spriteSheet_ = [SpriteSheet spriteSheetForImage:Invaders
                                               sheetKey:@"invaders.png"
                                             spriteSize:CGSizeMake(45, 30)
                                                spacing:2
                                                 margin:0];

        float delay = 0.35f;
        alien1_ = [[Animation alloc] init];
        [alien1_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(1, 3)] delay:delay];
        [alien1_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(2, 3)] delay:delay];
        alien1_.state = kAnimationState_Running;
        alien1_.type = kAnimationType_PingPong;

        alien2_ = [[Animation alloc] init];
        [alien2_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(2, 2)] delay:delay];
        [alien2_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(3, 2)] delay:delay];
        alien2_.state = kAnimationState_Running;
        alien2_.type = kAnimationType_PingPong;

        alien3_ = [[Animation alloc] init];
        [alien3_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(4, 2)] delay:delay];
        [alien3_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 3)] delay:delay];
        alien3_.state = kAnimationState_Running;
        alien3_.type = kAnimationType_PingPong;

        delay = 0.2f;
        alien4_ = [[Animation alloc] init];
        [alien4_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        [alien4_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(1, 0)] delay:delay];
        [alien4_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(2, 0)] delay:delay];
        [alien4_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(3, 0)] delay:delay];
        alien4_.state = kAnimationState_Running;
        alien4_.type = kAnimationType_PingPong;

        alien5_ = [[Animation alloc] init];
        [alien5_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(4, 0)] delay:delay];
        [alien5_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 1)] delay:delay];
        [alien5_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(1, 1)] delay:delay];
        [alien5_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(2, 1)] delay:delay];
        alien5_.state = kAnimationState_Running;
        alien5_.type = kAnimationType_PingPong;

        alien6_ = [[Animation alloc] init];
        [alien6_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(3, 1)] delay:delay];
        [alien6_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(4, 1)] delay:delay];
        [alien6_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 2)] delay:delay];
        [alien6_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(1, 2)] delay:delay];
        alien6_.state = kAnimationState_Running;
        alien6_.type = kAnimationType_PingPong;

        help1_ = [spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)];
        help2_ = [spriteSheet_ spriteImageAtCoords:CGPointMake(4, 0)];
        help3_ = [spriteSheet_ spriteImageAtCoords:CGPointMake(3, 1)];
        help6_ = [spriteSheet_ spriteImageAtCoords:CGPointMake(4, 2)];
        help7_ = [spriteSheet_ spriteImageAtCoords:CGPointMake(3, 2)];
        help8_ = [spriteSheet_ spriteImageAtCoords:CGPointMake(1, 3)];

        spriteSheet_ = [SpriteSheet spriteSheetForImage:BigBonuses
                                               sheetKey:@"big_bonuses.png"
                                             spriteSize:CGSizeMake(60, 26)
                                                spacing:2
                                                 margin:0];
        help4_ = [spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)];
        help9_ = [spriteSheet_ spriteImageAtCoords:CGPointMake(0, 1)];


        spriteSheet_ = [SpriteSheet spriteSheetForImage:SmallBonuses
                                               sheetKey:@"small_bonuses.png"
                                             spriteSize:CGSizeMake(46, 20)
                                                spacing:2
                                                 margin:0];
        help10_ = [spriteSheet_ spriteImageAtCoords:CGPointMake(0, 1)];
        help5_ = [spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)];



        // Grab the bounds of the screen
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			screenBounds_ = CGRectMake(0, 0, 1024, 768);
            background_ = [[Image alloc] initWithImageNamed:@"iPadMenuBackground" ofType:@"png" filter:GL_NEAREST];

            menuFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"mono50green"
                                                            ofType:@"png"
                                                       controlFile:@"mono50green"
                                                             scale:Scale2fMake(1.0f, 1.0f)
                                                            filter:GL_LINEAR];
            monoMenuFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"mono50green"
                                                                ofType:@"png"
                                                           controlFile:@"mono50green"
                                                                 scale:Scale2fMake(1.0f, 1.0f)
                                                                filter:GL_LINEAR];
            monoScoreHighlightFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"mono50purple"
                                                                          ofType:@"png"
                                                                     controlFile:@"mono50purple"
                                                                           scale:Scale2fMake(1.0f, 1.0f)
                                                                          filter:GL_LINEAR];
            monoHelpFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"mono50green"
                                                                ofType:@"png"
                                                           controlFile:@"mono50green"
                                                                 scale:Scale2fMake(1.0f, 1.0f)
                                                                filter:GL_LINEAR];

            fadeImage_ = [[Image alloc] initWithImageNamed:@"allBlack-iPad" ofType:@"png" filter:GL_NEAREST];
            fadeImage_.color = Color4fMake(1.0, 1.0, 1.0, 1.0);

		} else {
			screenBounds_ = CGRectMake(0, 0, 480, 320);
            PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                           controlFile:@"pss_coordinates"
                                                                           imageFilter:GL_LINEAR];
            background_ = [[pss imageForKey:@"iPhoneMenuBackground.png"] retain];

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
            monoScoreHighlightFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"ci_menu_mono_30_purple"
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
		}

        [Invaders release];
        [SmallBonuses release];
        [BigBonuses release];

		// Init the fadespeed and alpha for this scene
		fadeSpeed_ = 1.0f;
		alpha_ = 1.0f;

		// Set the initial state for the menu
		state_ = SceneState_Idle;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            mainMenuViewController_ = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController-iPad" bundle:[NSBundle mainBundle]];
        } else {
            mainMenuViewController_ = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController" bundle:[NSBundle mainBundle]];
        }
        mainMenuViewController_.menuScene = self;
	}
	return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [mainMenuViewController_ setScoreButton];
    switch (state_) {
		case SceneState_Running:
            [alien1_ updateWithDelta:aDelta];
            [alien2_ updateWithDelta:aDelta];
            [alien3_ updateWithDelta:aDelta];
            [alien4_ updateWithDelta:aDelta];
            [alien5_ updateWithDelta:aDelta];
            [alien6_ updateWithDelta:aDelta];
			break;

		case SceneState_TransitionIn:
			// Update the alpha value of the fadeImage
			alpha_ -= fadeSpeed_ * aDelta;
			fadeImage_.color = Color4fMake(1.0, 1.0, 1.0, alpha_);

			if(alpha_ < 0.0f) {
				alpha_ = 0.0f;
				state_ = SceneState_Running;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showMainMenu" object:self];
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

                [sharedSoundManager_ stopSoundWithKey:@"menu"];
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
    [sharedSoundManager_ playSoundWithKey:@"menu" gain:0.2f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO];
}

- (void)renderScene {

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
#pragma mark iPad renderScene
        [background_ renderAtPoint:CGPointMake(0, 0)];
        if (state_ == SceneState_Running || state_ == SceneState_TransitionOut || state_ == SceneState_TransitionIn) {
            CGFloat x = 150.0f;
            CGFloat alienHeight = 30 * 3.0f;
            CGFloat verticalPadding = 90.0f;

            CGFloat animScale = 3.0f;
            if (sharedGameController_.graphicsChoice_ == 0) {
                [alien2_ renderAtPoint:CGPointMake(x, verticalPadding) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien1_ renderAtPoint:CGPointMake(x, alienHeight+verticalPadding*2) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien3_ renderAtPoint:CGPointMake(x, alienHeight*2+verticalPadding*3) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien1_ renderAtPoint:CGPointMake(x, alienHeight*3+verticalPadding*4) scale:Scale2fMake(animScale, animScale) rotation:0];
            } else {
                [alien5_ renderAtPoint:CGPointMake(x, verticalPadding) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien4_ renderAtPoint:CGPointMake(x, alienHeight+verticalPadding*2) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien6_ renderAtPoint:CGPointMake(x, alienHeight*2+verticalPadding*3) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien4_ renderAtPoint:CGPointMake(x, alienHeight*3+verticalPadding*4) scale:Scale2fMake(animScale, animScale) rotation:0];
            }

            [sharedImageRenderManager_ renderImages];
        }
        if (state_ == SceneState_Scores) {
            [monoMenuFont_ renderStringAt:CGPointMake(30, 695) text:[NSString stringWithFormat:@"   %-11s%8s%10s", "Name", "Score", "Wave"]];
            [monoMenuFont_ renderStringAt:CGPointMake(30, 660) text:[NSString stringWithFormat:@"   %-11s%8s%10s", "====", "=====", "===="]];
            [sharedImageRenderManager_ renderImages];

            int i = 2; int j = 1; const char *name;

            BitmapFont *font;
            for (Score *s in highScores_) {
                if (s.isMostRecentScore_) {
                    font = monoScoreHighlightFont_;
                } else {
                    font = monoMenuFont_;
                }

                name = [s.name_ UTF8String];
                if (j<10) {
                    [font renderStringAt:CGPointMake(30, 695-i*50)
                                    text:[NSString stringWithFormat:@" %d.%-11.10s%8d%10d", j++, name, s.score_, s.wave_]];
                    [sharedImageRenderManager_ renderImages];
                    ++i;
                } else if (j == 10) {
                    [font renderStringAt:CGPointMake(30, 695-i*50)
                                    text:[NSString stringWithFormat:@"%d.%-11.10s%8d%10d", j++, name, s.score_, s.wave_]];
                    [sharedImageRenderManager_ renderImages];
                }
            }
        }
        if (state_ == SceneState_Help) {

            int h = 675;
            int v = 75;
            int alienOffset = 100;
            int scoreOffset = 325;

            CGFloat helpScale = 2.0f;
            help1_.scale = Scale2fMake(helpScale, helpScale);
            help2_.scale = Scale2fMake(helpScale, helpScale);
            help3_.scale = Scale2fMake(helpScale, helpScale);
            help4_.scale = Scale2fMake(helpScale, helpScale);
            help5_.scale = Scale2fMake(helpScale, helpScale);
            help6_.scale = Scale2fMake(helpScale, helpScale);
            help7_.scale = Scale2fMake(helpScale, helpScale);
            help8_.scale = Scale2fMake(helpScale, helpScale);
            help9_.scale = Scale2fMake(helpScale, helpScale);
            help10_.scale = Scale2fMake(helpScale, helpScale);

            if (sharedGameController_.graphicsChoice_ == 1) {
                [help1_ renderAtPoint:CGPointMake(alienOffset, h)];
                [help2_ renderAtPoint:CGPointMake(alienOffset, h-v)];
                [help3_ renderAtPoint:CGPointMake(alienOffset, h-v*2)];
                [help4_ renderAtPoint:CGPointMake(alienOffset-15, h-v*3)];
                [help5_ renderAtPoint:CGPointMake(alienOffset, h-v*4+5)];
            } else {
                [help7_ renderAtPoint:CGPointMake(alienOffset, h)];
                [help6_ renderAtPoint:CGPointMake(alienOffset, h-v)];
                [help8_ renderAtPoint:CGPointMake(alienOffset, h-v*2)];
                [help9_ renderAtPoint:CGPointMake(alienOffset-14, h-v*3+7)];
                [help10_ renderAtPoint:CGPointMake(alienOffset, h-v*4+16)];
            }

            [monoHelpFont_ renderStringAt:CGPointMake(scoreOffset, h) text:@"25"];
            [monoHelpFont_ renderStringAt:CGPointMake(scoreOffset, h-v) text:@"50"];
            [monoHelpFont_ renderStringAt:CGPointMake(scoreOffset, h-v*2) text:@"100"];
            [monoHelpFont_ renderStringAt:CGPointMake(scoreOffset, h-v*3) text:@"1000"];
            [monoHelpFont_ renderStringAt:CGPointMake(scoreOffset, h-v*4) text:@"2500"];

            [monoHelpFont_ renderStringAt:CGPointMake(alienOffset, h-v*5.25) text:@"Bonus ship every 10000."];
            [monoHelpFont_ renderStringAt:CGPointMake(alienOffset, h-v*6.5) text:@"Double tap top half of screen"];
            [monoHelpFont_ renderStringAt:CGPointMake(alienOffset, h-v*7.1) text:@"to pause a running wave."];
            [monoHelpFont_ renderStringAt:CGPointMake(alienOffset, h-v*8.25) text:@"Arrows to move, tap elsewhere"];
            [monoHelpFont_ renderStringAt:CGPointMake(alienOffset, h-v*8.925) text:@"on bottom area to fire."];



            [sharedImageRenderManager_ renderImages];
        }
        if (state_ == SceneState_About) {
            CGRect top = CGRectMake(0, 450, 1024, 80);
            CGRect middle = CGRectMake(0, 360, 1024, 60);
            CGRect bottom = CGRectMake(0, 150, 1024, 40);
            [menuFont_ renderStringJustifiedInFrame:top
                                      justification:BitmapFontJustification_MiddleCentered
                                               text:@"Design and programming by"];
            [menuFont_ renderStringJustifiedInFrame:middle
                                      justification:BitmapFontJustification_MiddleCentered
                                               text:@"Todd Steinackle"];
            [menuFont_ renderStringJustifiedInFrame:bottom
                                      justification:BitmapFontJustification_MiddleCentered
                                               text:@"www.noquarterarcade.com"];
            [sharedImageRenderManager_ renderImages];
        }

        // If we are transitioning in, out or idle then render the fadeImage
        if (state_ == SceneState_TransitionIn || state_ == SceneState_TransitionOut || state_ == SceneState_Idle) {
            [fadeImage_ renderAtPoint:CGPointMake(0, 0)];
            [sharedImageRenderManager_ renderImages];
        }

    } else {
#pragma mark iPhone renderScene
        [background_ renderAtPoint:CGPointMake(0, 0)];
        if (state_ == SceneState_Running || state_ == SceneState_TransitionOut || state_ == SceneState_TransitionIn) {
            CGFloat x = 50.0f;
            CGFloat alienHeight = 30 * 1.75f;
            CGFloat verticalPadding = 22.5f;

            CGFloat animScale = 1.75f;
            if (sharedGameController_.graphicsChoice_ == 0) {
                [alien2_ renderAtPoint:CGPointMake(x, verticalPadding) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien1_ renderAtPoint:CGPointMake(x, alienHeight+verticalPadding*2) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien3_ renderAtPoint:CGPointMake(x, alienHeight*2+verticalPadding*3) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien1_ renderAtPoint:CGPointMake(x, alienHeight*3+verticalPadding*4) scale:Scale2fMake(animScale, animScale) rotation:0];
            } else {
                [alien5_ renderAtPoint:CGPointMake(x, verticalPadding) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien4_ renderAtPoint:CGPointMake(x, alienHeight+verticalPadding*2) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien6_ renderAtPoint:CGPointMake(x, alienHeight*2+verticalPadding*3) scale:Scale2fMake(animScale, animScale) rotation:0];
                [alien4_ renderAtPoint:CGPointMake(x, alienHeight*3+verticalPadding*4) scale:Scale2fMake(animScale, animScale) rotation:0];
            }

            [sharedImageRenderManager_ renderImages];
        }
        if (state_ == SceneState_Scores) {
            [monoMenuFont_ renderStringAt:CGPointMake(5, 285) text:[NSString stringWithFormat:@"   %-11s%6s%9s", "Name", "Score", "Wave"]];
            [monoMenuFont_ renderStringAt:CGPointMake(5, 265) text:[NSString stringWithFormat:@"   %-11s%6s%9s", "====", "=====", "===="]];
            [sharedImageRenderManager_ renderImages];

            int i = 2; int j = 1; const char *name;

            BitmapFont *font;
            for (Score *s in highScores_) {
                if (s.isMostRecentScore_) {
                    font = monoScoreHighlightFont_;
                } else {
                    font = monoMenuFont_;
                }

                name = [s.name_ UTF8String];
                if (j<10) {
                    [font renderStringAt:CGPointMake(5, 285-i*25)
                                             text:[NSString stringWithFormat:@" %d.%-11.10s%6d%9d", j++, name, s.score_, s.wave_]];
                    [sharedImageRenderManager_ renderImages];
                    ++i;
                } else if (j == 10) {
                    [font renderStringAt:CGPointMake(5, 285-i*25)
                                             text:[NSString stringWithFormat:@"%d.%-11.10s%6d%9d", j++, name, s.score_, s.wave_]];
                    [sharedImageRenderManager_ renderImages];
                }
            }
        }
        if (state_ == SceneState_Help) {

            int h = 265;
            int v = 35;

            CGFloat helpScale = 1.0f;
            help1_.scale = Scale2fMake(helpScale, helpScale);
            help2_.scale = Scale2fMake(helpScale, helpScale);
            help3_.scale = Scale2fMake(helpScale, helpScale);
            help4_.scale = Scale2fMake(helpScale, helpScale);
            help5_.scale = Scale2fMake(helpScale, helpScale);
            help6_.scale = Scale2fMake(helpScale, helpScale);
            help7_.scale = Scale2fMake(helpScale, helpScale);
            help8_.scale = Scale2fMake(helpScale, helpScale);
            help9_.scale = Scale2fMake(helpScale, helpScale);
            help10_.scale = Scale2fMake(helpScale, helpScale);

            if (sharedGameController_.graphicsChoice_ == 1) {
                [help1_ renderAtPoint:CGPointMake(50, h)];
                [help2_ renderAtPoint:CGPointMake(50, h-v)];
                [help3_ renderAtPoint:CGPointMake(50, h-v*2)];
                [help4_ renderAtPoint:CGPointMake(42, h-v*3)];
                [help5_ renderAtPoint:CGPointMake(50, h-v*4+5)];
            } else {
                [help7_ renderAtPoint:CGPointMake(50, h)];
                [help6_ renderAtPoint:CGPointMake(50, h-v)];
                [help8_ renderAtPoint:CGPointMake(50, h-v*2)];
                [help9_ renderAtPoint:CGPointMake(42, h-v*3+2.5)];
                [help10_ renderAtPoint:CGPointMake(50, h-v*4+5)];
            }

            [monoHelpFont_ renderStringAt:CGPointMake(150, h) text:@"25"];
            [monoHelpFont_ renderStringAt:CGPointMake(150, h-v) text:@"50"];
            [monoHelpFont_ renderStringAt:CGPointMake(150, h-v*2) text:@"100"];
            [monoHelpFont_ renderStringAt:CGPointMake(150, h-v*3) text:@"1000"];
            [monoHelpFont_ renderStringAt:CGPointMake(150, h-v*4) text:@"2500"];

            [monoHelpFont_ renderStringAt:CGPointMake(50, h-v*4.85) text:@"Bonus ship every 10000."];
            [monoHelpFont_ renderStringAt:CGPointMake(50, h-v*5.7) text:@"Double tap top half of screen"];
            [monoHelpFont_ renderStringAt:CGPointMake(50, h-v*6.25) text:@"to pause a running wave."];
            [monoHelpFont_ renderStringAt:CGPointMake(50, h-v*7.0) text:@"Arrows to move, tap elsewhere"];
            [monoHelpFont_ renderStringAt:CGPointMake(50, h-v*7.6) text:@"on bottom area to fire."];

            [sharedImageRenderManager_ renderImages];
        }
        if (state_ == SceneState_About) {
            CGRect top = CGRectMake(0, 200, 480, 40);
            CGRect middle = CGRectMake(0, 160, 480, 30);
            CGRect bottom = CGRectMake(0, 50, 480, 20);
            [menuFont_ renderStringJustifiedInFrame:top
                                      justification:BitmapFontJustification_MiddleCentered
                                               text:@"Design and programming by"];
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

    if (state_ == SceneState_Scores || state_ == SceneState_Help || state_ == SceneState_About) {
        if (CGRectContainsPoint(screenBounds_, touchLocation)) {
            [sharedSoundManager_ playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
            alpha_ = 0;
            state_ = SceneState_TransitionIn;
            return;
        }
    }

}

@end
