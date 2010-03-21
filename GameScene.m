//  GameScene.m

#import <QuartzCore/QuartzCore.h>
#import "Global.h"
#import "GameController.h"
#import "ImageRenderManager.h"
#import "GameScene.h"
#import "TextureManager.h"
#import "SoundManager.h"
#import "AbstractEntity.h"
#import "Image.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "BitmapFont.h"
#import "ParticleEmitter.h"
#import "Primatives.h"
#import "PackedSpriteSheet.h"
#import "Layer.h"
#import "Alien.h"
#import "Alien2.h"
#import "Alien3.h"
#import "Player.h"
#import "Shot.h"

#include <stdlib.h>

// Scene States
enum {
	SceneState_Idle,
	SceneState_Credits,
	SceneState_Loading,
	SceneState_TransitionIn,
	SceneState_TransitionOut,
	SceneState_Running,
	SceneState_Paused,
	SceneState_GameOver,
	SceneState_SaveScore,
	SceneState_GameCompleted
};

const CGFloat playerSpeed = 115.0f;
bool isLeftTouchActive = FALSE;
bool isRightTouchActive = FALSE;

#pragma mark -
#pragma mark Private interface

@interface GameScene (Private)
// Initialize the sound needed for this scene
- (void)initSound;

// Sets up the game from the previously saved game.  If any of the data files are
// missing then the resume will not take place and the initial game state will be
// used instead
- (void)loadGameState;

// Deallocates resources this scene has created
- (void)deallocResources;

- (void)initAliensWithSpeed:(int)alienSpeed chanceToFire:(int)chanceToFire;
- (void)playerFireShot;
- (void)initPlayerShots;
- (void)aliensHaveLanded;

@end

#pragma mark -
#pragma mark Private implementation

@implementation GameScene (Private)

- (void)aliensHaveLanded {
	//NSLog(@"the aliens have landed");
}

- (void)playerFireShot {
	static double playerShotDelay = 0.5f;
	static double lastShot = 0.0f;
	static int playerShotCounter = 0;
	// check that player has waited long enough to fire
	if (CACurrentMediaTime() - lastShot < playerShotDelay) {
		return;
	}
	// record time and fire
	lastShot = CACurrentMediaTime();
	Shot *shot = [playerShots_ objectAtIndex:playerShotCounter];
	shot.pixelLocation_ = CGPointMake(player_.pixelLocation_.x + player_.playerInitialXShotPostion_,
									  player_.pixelLocation_.y + player_.playerInitialYShotPostion_ + 1);
	shot.active_ = TRUE;
	if (++playerShotCounter == numberOfPlayerShots_) {
		playerShotCounter = 0;
	}
}

- (void)initAliensWithSpeed:(int)alienSpeed chanceToFire:(int)chanceToFire {
	Alien *alien;
	int alienCount = 0;
	CGFloat x = 65.0f;
	CGFloat y = 170.0f;
	CGFloat horizontalSpace = 35;
	CGFloat verticalSpace = 25;
	// create a block of aliens
	for (int i = 0; i < 5; ++i) {
		for (int j = 0; j < 10; ++j) {
			switch (i) {
				case 0:
				{
					// initialize the bottom row of aliens to fire
					alien = [[Alien alloc] initWithPixelLocation:CGPointMake(x+(j*horizontalSpace), y+(i*verticalSpace))
															  dx:alienSpeed
															  dy:0.0
														position:alienCount+1
														 canFire:TRUE
													chanceToFire:arc4random() % chanceToFire + 1];
					[aliens_ addObject:alien];
					[alien release];
					break;
				}
				case 1:
				{
					alien = [[Alien alloc] initWithPixelLocation:CGPointMake(x+(j*horizontalSpace), y+(i*verticalSpace))
															  dx:alienSpeed
															  dy:0.0
														position:alienCount+1
														 canFire:FALSE
													chanceToFire:arc4random() % chanceToFire + 1];
					[aliens_ addObject:alien];
					[alien release];
					break;
				}
				case 2:
				case 3:
				{
					alien = [[Alien2 alloc] initWithPixelLocation:CGPointMake(x+(j*horizontalSpace), y+(i*verticalSpace))
															   dx:alienSpeed
															   dy:0.0
														 position:alienCount+1
														  canFire:FALSE
													 chanceToFire:arc4random() % chanceToFire + 1];
					[aliens_ addObject:alien];
					[alien release];
					break;
				}
				case 4:
				{
					alien = [[Alien3 alloc] initWithPixelLocation:CGPointMake(x+(j*horizontalSpace), y+(i*verticalSpace))
															   dx:alienSpeed
															   dy:0.0
														 position:alienCount+1
														  canFire:FALSE
													 chanceToFire:arc4random() % chanceToFire + 1];
					[aliens_ addObject:alien];
					[alien release];
					break;
				}
				default:
					break;
			}
			++alienCount;
		}
	}
	//NSLog(@"%@", aliens_);
}

- (void)initPlayerShots {
	for (int i = 0; i < numberOfPlayerShots_; ++i) {
		Shot *shot = [[Shot alloc] initWithPixelLocation:CGPointMake(0,0)];
		[playerShots_ addObject:shot];
	}
	//NSLog(@"%@", playerShots_);
}

- (void)loadGameState {

}

- (void)initSound {

    // Set the listener to the middle of the screen by default.  This will be changed as the player moves around the map
    [sharedSoundManager_ setListenerPosition:CGPointMake(240, 160)];

	//    // Initialize the sound effects
	//    [sharedSoundManager loadSoundWithKey:@"doorSlam" soundFile:@"doorSlam.caf"];
	//    [sharedSoundManager loadSoundWithKey:@"doorOpen" soundFile:@"doorOpen.caf"];
	//    [sharedSoundManager loadSoundWithKey:@"pop" soundFile:@"pop.caf"];
	//    [sharedSoundManager loadSoundWithKey:@"hitWall" soundFile:@"hitwall.caf"];
	//    [sharedSoundManager loadSoundWithKey:@"eatfood" soundFile:@"eatfood.caf"];
	//	[sharedSoundManager loadSoundWithKey:@"scream" soundFile:@"scream.caf"];
	//	[sharedSoundManager loadSoundWithKey:@"spell" soundFile:@"spell.caf"];
	//
	//    // Initialize the background music
	//    [sharedSoundManager loadMusicWithKey:@"ingame" musicFile:@"ingame.mp3"];
	//	[sharedSoundManager loadMusicWithKey:@"loseIntro" musicFile:@"loseIntro.mp3"];
	//	[sharedSoundManager loadMusicWithKey:@"loseLoop" musicFile:@"loseLoop.mp3"];
	//	[sharedSoundManager loadMusicWithKey:@"winIntro" musicFile:@"winIntro.mp3"];
	//	[sharedSoundManager loadMusicWithKey:@"winLoop" musicFile:@"winLoop.mp3"];
	//	[sharedSoundManager addToPlaylistNamed:@"win" track:@"winIntro"];
	//	[sharedSoundManager addToPlaylistNamed:@"win" track:@"winLoop"];
	//	[sharedSoundManager addToPlaylistNamed:@"lose" track:@"loseIntro"];
	//	[sharedSoundManager addToPlaylistNamed:@"lose" track:@"loseLoop"];
	//	sharedSoundManager.usePlaylist = NO;
	//	sharedSoundManager.loopLastPlaylistTrack = NO;
}

- (void)deallocResources {

	[aliens_ release];
	[background_ release];

	// Release fonts
	[smallFont_ release];
	[largeFont_ release];

	// Release sounds
	[sharedSoundManager_ removeSoundWithKey:@"doorSlam"];
	[sharedSoundManager_ removeSoundWithKey:@"doorOpen"];
	[sharedSoundManager_ removeSoundWithKey:@"pop"];
	[sharedSoundManager_ removeSoundWithKey:@"hitWall"];
	[sharedSoundManager_ removeSoundWithKey:@"eatfood"];
	[sharedSoundManager_ removeSoundWithKey:@"scream"];
	[sharedSoundManager_ removeSoundWithKey:@"spell"];
	[sharedSoundManager_ removeMusicWithKey:@"ingame"];
	[sharedSoundManager_ removeMusicWithKey:@"winIntro"];
	[sharedSoundManager_ removeMusicWithKey:@"winLoop"];
	[sharedSoundManager_ removeMusicWithKey:@"loseIntro"];
	[sharedSoundManager_ removeMusicWithKey:@"loseLoop"];
	[sharedSoundManager_ removePlaylistNamed:@"win"];
	[sharedSoundManager_ removePlaylistNamed:@"lose"];
}
@end

#pragma mark -
#pragma mark Public implementation

@implementation GameScene

@synthesize screenSidePadding_;
@synthesize isAlienLogicNeeded_;
@synthesize playerBaseHeight_;

- (void)updateSceneWithDelta:(GLfloat)aDelta {

	int touchBoxWidth = 65;
	switch (state_) {
		case SceneState_TransitionIn:
			playerBaseHeight_ = 35;
			aliens_ = [[NSMutableArray alloc] init];
			[self initAliensWithSpeed:50 chanceToFire:10];
			player_ = [[Player alloc] initWithPixelLocation:CGPointMake((screenBounds_.size.height - (43*.85)) / 2, playerBaseHeight_+1)];
			numberOfPlayerShots_ = 10;
			playerShots_ = [[NSMutableArray alloc] initWithCapacity:numberOfPlayerShots_];
			[self initPlayerShots];

			PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png" controlFile:@"pss_coordinates" imageFilter:GL_LINEAR];
			background_ = [[pss imageForKey:@"background.png"] retain];

			leftTouchControlBounds_ = CGRectMake(1, 1, touchBoxWidth, playerBaseHeight_);
			rightTouchControlBounds_ = CGRectMake(415, 1, touchBoxWidth, playerBaseHeight_);
			fireTouchControlBounds_ = CGRectMake(touchBoxWidth+1, 1, 479-touchBoxWidth*2, playerBaseHeight_);
			screenSidePadding_ = 10.0f;

			state_ = SceneState_Running;

			break;

		case SceneState_Running:

			for(Alien *alien in aliens_) {
				if (alien.active_) {
					[alien updateWithDelta:aDelta scene:self];
					[alien movement:aDelta];
				}
			}

			[player_ updateWithDelta:aDelta scene:self];
			[player_ movement:aDelta];

			for (Shot *shot in playerShots_) {
				[shot updateWithDelta:aDelta scene:self];
				[shot movement:aDelta];
			}

			for (Alien *alien in aliens_) {
				if (alien.active_) {
					for (Shot *shot in playerShots_) {
						if (shot.active_) {
							[alien checkForCollisionWithEntity:shot];
						}
					}
				}
			}

			if (isAlienLogicNeeded_) {
				//NSLog(@"inside alien logic");
				for (Alien *alien in aliens_) {
					[alien doAlienLogic];
				}
				isAlienLogicNeeded_ = FALSE;
			}

			break;

		default:
			break;
	}

}

- (void)renderScene {

	// Clear the screen before rendering
	//glClear(GL_COLOR_BUFFER_BIT);
	[background_ renderAtPoint:CGPointMake(0, 0)];
	for(Alien *alien in aliens_) {
		if (alien.active_) {
			[alien render];
		}
	}
	[player_ render];
	for (Shot *shot in playerShots_) {
		if (shot.active_) {
			[shot render];
		}
	}

	[sharedImageRenderManager_ renderImages];
	drawBox(leftTouchControlBounds_);
	drawBox(rightTouchControlBounds_);
	drawBox(fireTouchControlBounds_);
	//	for(Alien *alien in aliens_) {
	//		drawBox(CGRectMake(alien.pixelLocation_.x + alien.collisionXOffset_, alien.pixelLocation_.y + alien.collisionYOffset_,
	//						   alien.collisionWidth_, alien.collisionHeight_));
	//	}

}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

	for (UITouch *touch in touches) {
        // Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:nil];
		//NSLog(@"x: %f", originalTouchLocation.x);
		//NSLog(@"y: %f", originalTouchLocation.y);

        // As we have the game in landscape mode we need to switch the touches
        // x and y coordinates
		CGPoint touchLocation = [sharedGameController_ adjustTouchOrientationForTouch:originalTouchLocation];

		if (CGRectContainsPoint(fireTouchControlBounds_, touchLocation)) {
			NSLog(@"fire shot");
			[self playerFireShot];
		}

		if (CGRectContainsPoint(leftTouchControlBounds_, touchLocation)) {
			NSLog(@"left touch");
			isLeftTouchActive = TRUE;
			if (isLeftTouchActive && !isRightTouchActive) {
				player_.dx_ = -playerSpeed;
			}
			if (isLeftTouchActive && isRightTouchActive) {
				player_.dx_ = 0;
			}
		}
		if (CGRectContainsPoint(rightTouchControlBounds_, touchLocation)) {
			NSLog(@"right touch");
			isRightTouchActive = TRUE;
			if (isRightTouchActive && !isLeftTouchActive) {
				player_.dx_ = playerSpeed;
			}
			if (isLeftTouchActive && isRightTouchActive) {
				player_.dx_ = 0;
			}
		}
		//NSLog(@"x: %f", touchLocation.x);
		//NSLog(@"y: %f", touchLocation.y);
	}
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

	for (UITouch *touch in touches) {
        // Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:nil];
		//NSLog(@"x: %f", originalTouchLocation.x);
		//NSLog(@"y: %f", originalTouchLocation.y);

        // As we have the game in landscape mode we need to switch the touches
        // x and y coordinates
        CGPoint touchLocation = [sharedGameController_ adjustTouchOrientationForTouch:originalTouchLocation];

		if (CGRectContainsPoint(leftTouchControlBounds_, touchLocation)) {
			NSLog(@"left touch release");
			isLeftTouchActive = FALSE;
			if (isRightTouchActive) {
				player_.dx_ = playerSpeed;
			} else {
				player_.dx_ = 0;
			}
		}
		if (CGRectContainsPoint(rightTouchControlBounds_, touchLocation)) {
			NSLog(@"right touch release");
			isRightTouchActive = FALSE;
			if (isLeftTouchActive) {
				player_.dx_ = -playerSpeed;
			} else {
				player_.dx_ = 0;
			}
		}
		//NSLog(@"x: %f", touchLocation.x);
		//NSLog(@"y: %f", touchLocation.y);
	}

}

- (void)transitionToSceneWithKey:(NSString*)theKey {
    state_ = kSceneState_TransitionOut;
}

- (void)transitionIn {
    state_ = kSceneState_TransitionIn;
}


- (void)saveGameState {

}

- (void)dealloc {

    // Remove observers that have been set up
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hidingSettings" object:nil];

	// Dealloc resources this scene has created
	[self deallocResources];

    [super dealloc];
}

- (id)init {

    if(self = [super init]) {

		// Name of this scene
        self.name_ = @"game";

        // Grab an instance of our singleton classes
        sharedImageRenderManager_ = [ImageRenderManager sharedImageRenderManager];
        sharedTextureManager_ = [TextureManager sharedTextureManager];
        sharedSoundManager_ = [SoundManager sharedSoundManager];
        sharedGameController_ = [GameController sharedGameController];

        // Grab the bounds of the screen
        screenBounds_ = [[UIScreen mainScreen] bounds];
	}

    return self;
}

@end


