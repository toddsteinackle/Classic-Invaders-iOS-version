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
	[background release];
	[fadeImage release];

	if (clouds)
		free(clouds);
	if (cloudPositions)
		free(cloudPositions);

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

		sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
		sharedGameController = [GameController sharedGameController];
		sharedSoundManager = [SoundManager sharedSoundManager];
		sharedTextureManager = [TextureManager sharedTextureManager];

		// Create a packed spritesheet for the menu
		pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"menuAtlas.png" controlFile:@"menuCoords" imageFilter:GL_LINEAR];

		// Create images for the menu from packed spritesheet and also the fade image
		background = [pss imageForKey:@"title.png"];
		logo = [pss imageForKey:@"small_logo.png"];
		menu = [pss imageForKey:@"menu.png"];
		menuButton = [pss imageForKey:@"resumeButton.png"];
		castle = [pss imageForKey:@"castle.png"];
		settings = [pss imageForKey:@"gear.png"];
		settings.color = Color4fMake(1, 1, 1, 0.6f);

		clouds = [[NSArray arrayWithObjects:
				  [pss imageForKey:@"cloud.png"],
				  [pss imageForKey:@"cloud2.png"],
				  [pss imageForKey:@"cloud3.png"],
				  [pss imageForKey:@"cloud4.png"],
				  [pss imageForKey:@"cloud5.png"],
				  [pss imageForKey:@"cloud6.png"],
				  [pss imageForKey:@"cloud7.png"],
				  nil] retain];

		fadeImage = [[Image alloc] initWithImageNamed:@"allBlack" ofType:@"png" filter:GL_NEAREST];
		fadeImage.color = Color4fMake(1.0, 1.0, 1.0, 1.0);

		// Define cloud speed and position
		cloudSpeed = 3;

		cloudPositions = (CGPoint*)malloc(sizeof(CGPoint) * 7);
		cloudPositions[0] = CGPointMake(20, 100);
		cloudPositions[1] = CGPointMake(100, 150);
		cloudPositions[2] = CGPointMake(225, 225);
		cloudPositions[3] = CGPointMake(350, 0);
		cloudPositions[4] = CGPointMake(300, 25);
		cloudPositions[5] = CGPointMake(200, 190);
	    cloudPositions[6] = CGPointMake(50, 50);

		// Init the fadespeed and alpha for this scene
		fadeSpeed_ = 1.0f;
		alpha_ = 1.0f;

		// Define the bounds for the buttons being used on the menu
		startButtonBounds = CGRectMake(74, 235, 140, 50);
		scoreButtonBounds = CGRectMake(71, 178, 135, 50);
		instructionButtonBounds = CGRectMake(74, 120, 144, 50);
		resumeButtonBounds = CGRectMake(74, 61, 142, 50);
		logoButtonBounds = CGRectMake(15, 0, 50, 50);
		settingsButtonBounds = CGRectMake(430, 0, 50, 50);

		// Set the default music volume for the menu.  Start at 0 as we are going to fade the sound up
		musicVolume = 1.0f;

		// Set the initial state for the menu
		state_ = kSceneState_Idle;
	}
	return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
	switch (state_) {
		case kSceneState_Running:

			// Loop through clouds travelling to the right.  We want the speed of each cloud to
			// be different as it looks better than having them all travel at the same speed.  To
			// Achieve this we have a very simple calculation that uses the index of the cloud in
			// the array to work out the speed.
			for (int index=0; index < 4 ; index++) {
				CGPoint point = cloudPositions[index];
				point.x += (cloudSpeed * index+1) * aDelta;
				if (point.x > 480)
					point.x = - 200;
				cloudPositions[index] = point;
			}

			// Loop through clouds travelling to the right
			for (int index=4; index < 7 ; index++) {
				CGPoint point = cloudPositions[index];
				point.x -= (cloudSpeed * index+1) * aDelta;
				if (point.x < -200)
					point.x = 480;
				cloudPositions[index] = point;
			}
			break;
		case kSceneState_TransitionIn:

			// If external music is playing, then don't start the in game music
			if (!isMusicFading && !sharedSoundManager.isExternalAudioPlaying) {
				isMusicFading = YES;
				sharedSoundManager.currentMusicVolume = 0;
				[sharedSoundManager startPlaylistNamed:@"menu"];
				[sharedSoundManager fadeMusicVolumeFrom:0 toVolume:sharedSoundManager.musicVolume duration:0.8f stop:NO];
			}

			// Update the alpha value of the fadeImage
			alpha_ -= fadeSpeed_ * aDelta;
			fadeImage.color = Color4fMake(1.0, 1.0, 1.0, alpha_);

			if(alpha_ < 0.0f) {
				alpha_ = 0.0f;
				isMusicFading = NO;
				state_ = kSceneState_Running;
			}
			break;
		case kSceneState_TransitionOut:

			// If not already fading, fade the currently playing track from the current volume to 0
			if (!isMusicFading && sharedSoundManager.isMusicPlaying) {
				isMusicFading = YES;
				[sharedSoundManager fadeMusicVolumeFrom:sharedSoundManager.musicVolume toVolume:0 duration:0.8f stop:YES];
			}

			// Adjust the alpha value of the fadeImage.  This will cause the image to move from transparent to opaque
			alpha_ += fadeSpeed_ * aDelta;
			fadeImage.color = Color4fMake(1.0, 1.0, 1.0, alpha_);

			// Check to see if the image is now fully opache.  If so then the fade is finished
			if(alpha_ > 1.0f) {
				alpha_ = 1.0f;

				// The render routine will not be called for this scene past this point, so we have added
				// a render of the fadeImage here so that the menu scene is completely removed.  Without this
				// it was sometimes possible to see the main menu faintly.
				[fadeImage renderAtPoint:CGPointMake(0, 0)];
				[sharedImageRenderManager renderImages];

				// This scene is now idle
				state_ = kSceneState_Idle;

				// We stop the music for this scene and also remove the music we have been using.  This frees
				// up memory for the game scene.
				[sharedSoundManager removeMusicWithKey:@"themeIntro"];
				[sharedSoundManager removeMusicWithKey:@"themeLoop"];
				[sharedSoundManager removeSoundWithKey:@"guiTouch"];
				[sharedSoundManager removePlaylistNamed:@"menu"];
				sharedSoundManager.usePlaylist = NO;
				sharedSoundManager.loopLastPlaylistTrack = NO;

				// Stop the idletimer from kicking in while playing the game.  This stops the screen from fading
				// during game play
				[[UIApplication sharedApplication] setIdleTimerDisabled:YES];

				// Reset the music fading flag
				isMusicFading = NO;

				// Ask the game controller to transition to the scene called game.
				[sharedGameController transitionToSceneWithKey:@"game"];
			}
			break;

		default:
			break;
	}
}

- (void)transitionIn {
	// Load GUI sounds
	[sharedSoundManager setListenerPosition:CGPointMake(0, 0)];
	[sharedSoundManager loadSoundWithKey:@"guiTouch" soundFile:@"guiTouch.caf"];
	[sharedSoundManager loadMusicWithKey:@"themeIntro" musicFile:@"themeIntro.mp3"];
	[sharedSoundManager loadMusicWithKey:@"themeLoop" musicFile:@"themeLoop.mp3"];
	[sharedSoundManager removePlaylistNamed:@"menu"];
	[sharedSoundManager addToPlaylistNamed:@"menu" track:@"themeIntro"];
	[sharedSoundManager addToPlaylistNamed:@"menu" track:@"themeLoop"];
	sharedSoundManager.usePlaylist = YES;
	sharedSoundManager.loopLastPlaylistTrack = YES;

    // Switch the idle timer back on as its not a problem if the phone locks while you are
	// at the menu.  This is recommended by apple and helps to save power
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];

	state_ = kSceneState_TransitionIn;
}

- (void)renderScene {

	// Render the background
	[background renderAtPoint:CGPointMake(0, 0)];

	// Loop through the clounds and render them
	for (int index=0; index < 7; index++) {
		Image *cloud = [clouds objectAtIndex:index];
		[cloud renderAtPoint:(CGPoint)cloudPositions[index]];
	}

	// Render the cast ontop of the background and clouds
	[castle renderAtPoint:CGPointMake(249, 0)];

	// Render the 71Squared logo
	[logo renderAtPoint:CGPointMake(25, 0)];

	// Render the gear image for settings
	[settings renderAtPoint:CGPointMake(450, 0)];

	// Render the menu and add the options text
	[menu renderAtPoint:CGPointMake(0, 0)];

	// Check with the game controller to see if a saved game is available
	if ([sharedGameController resumedGameAvailable]) {
		[menuButton renderAtPoint:CGPointMake(71, 60)];
	}

	// If we are transitioning in, out or idle then render the fadeImage
	if (state_ == kSceneState_TransitionIn || state_ == kSceneState_TransitionOut || state_ == kSceneState_Idle) {
		[fadeImage renderAtPoint:CGPointMake(0, 0)];
	}

	// Having rendered our images we ask the render manager to actually put then on screen.
	[sharedImageRenderManager renderImages];

// If debug is on then display the bounds of the buttons
#ifdef SCB
	drawBox(startButtonBounds);
	drawBox(scoreButtonBounds);
	drawBox(instructionButtonBounds);
	drawBox(resumeButtonBounds);
	drawBox(logoButtonBounds);
	drawBox(settingsButtonBounds);
#endif

}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
	UITouch *touch = [[event touchesForView:aView] anyObject];

	// Get the point where the player has touched the screen
	CGPoint originalTouchLocation = [touch locationInView:aView];

	// As we have the game in landscape mode we need to switch the touches
	// x and y coordinates
	CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation];

	// We only want to check the touches on the screen when the scene is running.
	if (state_ == kSceneState_Running) {
		// Check to see if the user touched the start button
		if (CGRectContainsPoint(startButtonBounds, touchLocation)) {
			[sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
			state_ = kSceneState_TransitionOut;
			sharedGameController.shouldResumeGame = NO;
			alpha_ = 0;
			return;
		}

		if (CGRectContainsPoint(scoreButtonBounds, touchLocation)) {
			[sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
			alpha_ = 0;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"showHighScore" object:self];
			return;
		}

		if (CGRectContainsPoint(instructionButtonBounds, touchLocation)) {
			[sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
			alpha_ = 0;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"showInstructions" object:self];
			return;
		}

		// If the resume button is visible then check to see if the player touched
		// the resume button
		if ([sharedGameController resumedGameAvailable] && CGRectContainsPoint(resumeButtonBounds, touchLocation)) {
			[sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
			alpha_ = 0;
			[sharedGameController setShouldResumeGame:YES];
			state_ = kSceneState_TransitionOut;
			return;
		}

		// If the logo is pressed then show the credits for the game
		if (CGRectContainsPoint(logoButtonBounds, touchLocation)) {

			[[NSNotificationCenter defaultCenter] postNotificationName:@"showCredits" object:self];
			return;
		}

		// If the gear is pressed then show the settings for the game
		if (CGRectContainsPoint(settingsButtonBounds, touchLocation)) {

			[[NSNotificationCenter defaultCenter] postNotificationName:@"showSettings" object:self];
			return;
		}
	}
}

@end
