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
#import "BigBonusShip.h"
#import "SmallBonusShip.h"

#include <stdlib.h>

// Scene States
enum {
	SceneState_WaveMessage,
	SceneState_WaveOver,
	SceneState_PlayerRebirth,
	SceneState_TransitionIn,
	SceneState_TransitionOut,
	SceneState_Running,
	SceneState_Paused,
	SceneState_GameOver
};

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
- (void)initAlienShots;
- (void)initNewGame;
- (void)initWave;
- (void)alienFire;

@end

#pragma mark -
#pragma mark Private implementation

@implementation GameScene (Private)

- (void)initWave {
	++wave_;
	lastTimeInLoop_ = 0;

	[aliens_ removeAllObjects];
	[self initAliensWithSpeed:25 chanceToFire:10];
	alienOddRange_ = 10;
	[alienShots_ removeAllObjects];
	[self initAlienShots];

	[player_ initWithPixelLocation:CGPointMake((screenBounds_.size.width - (43*.85)) / 2, playerBaseHeight_+1)];
	[bigBonus_ initWithPixelLocation:CGPointMake(0, 290)];
	[smallBonus_ initWithPixelLocation:CGPointMake(380, 290)];

	[playerShots_ removeAllObjects];
	[self initPlayerShots];
}

- (void)initNewGame {
	aliens_ = [[NSMutableArray alloc] init];
	numberOfAlienShots_ = 25;
	alienShots_ = [[NSMutableArray alloc] initWithCapacity:numberOfAlienShots_];
	numberOfPlayerShots_ = 10;
	playerShots_ = [[NSMutableArray alloc] initWithCapacity:numberOfPlayerShots_];

	player_ = [Player alloc];
	bigBonus_ = [BigBonusShip alloc];
	smallBonus_ = [SmallBonusShip alloc];

	PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png" controlFile:@"pss_coordinates" imageFilter:GL_LINEAR];
	background_ = [[pss imageForKey:@"background.png"] retain];

	playerBaseHeight_ = 35;
	int touchBoxWidth = 65;
	leftTouchControlBounds_ = CGRectMake(1, 1, touchBoxWidth, playerBaseHeight_);
	rightTouchControlBounds_ = CGRectMake(415, 1, touchBoxWidth-1, playerBaseHeight_);
	fireTouchControlBounds_ = CGRectMake(touchBoxWidth+1, 1, 479-touchBoxWidth*2, playerBaseHeight_);
	screenSidePadding_ = 10.0f;

	smallFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"bookAntiqua32" ofType:@"png" controlFile:@"bookAntiqua32" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
	statusFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"franklin16" ofType:@"png" controlFile:@"franklin16" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
	playerSpeed_ = 115.0f;
	waveMessageInterval_ = 2.0f;
	wave_ = 0;
	playerLives_ = 3;
}

- (void)alienFire {
	// check that aliens have waited long enough to fire
	static double alienShotDelay = 2.0f;
	static double lastShot = 0.0f;
	static int alienShotCounter = 0;
	// check that player has waited long enough to fire
	if (CACurrentMediaTime() - lastShot < alienShotDelay) {
		return;
	}
	// record time and fire
	lastShot = CACurrentMediaTime();
	static int alienToFire = 0;
	++alienToFire;
	for (Alien *alien in aliens_) {
		if (alien.active_ && alien.canFire_ && alien.fireChance_ == alienToFire) {
			Shot *shot = [alienShots_ objectAtIndex:alienShotCounter];
			shot.pixelLocation_ = CGPointMake(alien.pixelLocation_.x + alien.alienInitialXShotPostion_,
											  alien.pixelLocation_.y - alien.alienInitialYShotPostion_);
			shot.active_ = TRUE;
			if (++alienShotCounter == numberOfAlienShots_) {
				alienShotCounter = 0;
			}
		}
	}
	if (alienToFire >= alienOddRange_) {
		alienToFire = 0;
	}
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
	alienCount_ = 50;
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
														position:alienCount_
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
														position:alienCount_
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
														 position:alienCount_
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
														 position:alienCount_
														  canFire:FALSE
													 chanceToFire:arc4random() % chanceToFire + 1];
					[aliens_ addObject:alien];
					[alien release];
					break;
				}
				default:
					break;
			}
			--alienCount_;
		}
	}
	//NSLog(@"%@", aliens_);
}

- (void)initPlayerShots {
	for (int i = 0; i < numberOfPlayerShots_; ++i) {
		Shot *shot = [[Shot alloc] initWithPixelLocation:CGPointMake(0,0)];
		[playerShots_ addObject:shot];
		[shot release];
	}
	//NSLog(@"%@", playerShots_);
}

- (void)initAlienShots {
	for (int i = 0; i < numberOfAlienShots_; ++i) {
		Shot *shot = [[Shot alloc] initWithPixelLocation:CGPointMake(0,0)];
		shot.dy_ = -60.0f;
		[alienShots_ addObject:shot];
		[shot release];
	}
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
	[statusFont_ release];

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

#pragma mark -
- (void)updateSceneWithDelta:(GLfloat)aDelta {

	switch (state_) {

#pragma mark TransitionIn
		case SceneState_TransitionIn:

			[self initNewGame];
			state_ = SceneState_WaveMessage;
			break;

#pragma mark PlayerRebirth
		case SceneState_PlayerRebirth:
			if (CACurrentMediaTime() - lastTimeInLoop_ < 2.0f) {
				return;
			}
			if (lastTimeInLoop_) {
				[player_ initWithPixelLocation:CGPointMake((screenBounds_.size.width - (43*.85)) / 2, playerBaseHeight_+1)];
				state_ = SceneState_Running;
				lastTimeInLoop_ = 0;
				return;
			}
			lastTimeInLoop_ = CACurrentMediaTime();
			break;

#pragma mark WaveMessage
		case SceneState_WaveMessage:
			if (CACurrentMediaTime() - lastTimeInLoop_ < waveMessageInterval_) {
				return;
			}
			if (lastTimeInLoop_) {
				[self initWave];
				state_ = SceneState_Running;
				lastTimeInLoop_ = 0;
				return;
			}
			lastTimeInLoop_ = CACurrentMediaTime();
			break;

#pragma mark WaveOver
		case SceneState_WaveOver:
			NSLog(@"Wave Over");
			//lastTimeInLoop_ = 0;
			state_ = SceneState_WaveMessage;
			break;

#pragma mark Running
		case SceneState_Running:

			[self alienFire];
			for(Alien *alien in aliens_) {
				if (alien.active_) {
					[alien updateWithDelta:aDelta scene:self];
					[alien movementWithDelta:aDelta];
				}
			}

			[player_ updateWithDelta:aDelta scene:self];
			[player_ movementWithDelta:aDelta];

			[bigBonus_ updateWithDelta:aDelta scene:self];
			[smallBonus_ updateWithDelta:aDelta scene:self];

			for (Shot *shot in playerShots_) {
				[shot updateWithDelta:aDelta scene:self];
				[shot movementWithDelta:aDelta];
			}

			for (Shot *shot in alienShots_) {
				[shot updateWithDelta:aDelta scene:self];
				[shot movementWithDelta:aDelta];
			}

			for (Alien *alien in aliens_) {
				if (alien.active_) {
					for (Shot *shot in playerShots_) {
						if (shot.active_) {
							[alien checkForCollisionWithEntity:shot];
						}
					}
					if (player_.active_) {
						[player_ checkForCollisionWithEntity:alien];
					}
				}
			}
			for (Shot *shot in alienShots_) {
				if (shot.active_ && player_.active_) {
					[player_ checkForCollisionWithEntity:shot];
				}

			}

			if (isAlienLogicNeeded_) {
				for (Alien *alien in aliens_) {
					[alien doAlienLogic];
				}
				isAlienLogicNeeded_ = FALSE;
			}

			break;

#pragma mark GameOver
		case SceneState_GameOver:
			break;

		default:
			break;
	}

}

#pragma mark -
- (void)renderScene {

	switch (state_) {

#pragma mark WaveMessage
		case SceneState_WaveMessage:
			glClear(GL_COLOR_BUFFER_BIT);
			[smallFont_ renderStringJustifiedInFrame:screenBounds_
									   justification:BitmapFontJustification_MiddleCentered
												text:[NSString stringWithFormat:@"Prepare for wave %i", wave_+1]];
			[sharedImageRenderManager_ renderImages];
			break;

#pragma mark Running
		case SceneState_Running:
			[background_ renderAtPoint:CGPointMake(0, 0)];

			for (Shot *shot in playerShots_) {
				if (shot.active_) {
					[shot render];
				}
			}
			for (Shot *shot in alienShots_) {
				if (shot.active_) {
					[shot render];
				}
			}

			for(Alien *alien in aliens_) {
				if (alien.active_) {
					[alien render];
				}
			}

			if (player_.active_) {
				[player_ render];
			}
			[bigBonus_ render];
			[smallBonus_ render];
			[statusFont_ renderStringJustifiedInFrame:fireTouchControlBounds_
										justification:BitmapFontJustification_MiddleLeft
												 text:[NSString stringWithFormat:@"  Wave: %i", wave_]];
			[statusFont_ renderStringJustifiedInFrame:fireTouchControlBounds_
										justification:BitmapFontJustification_MiddleCentered
												 text:[NSString stringWithFormat:@"Score: %i", score_]];
			[statusFont_ renderStringJustifiedInFrame:fireTouchControlBounds_
										justification:BitmapFontJustification_MiddleRight
												 text:[NSString stringWithFormat:@"Lives: %i  ", playerLives_]];
			[sharedImageRenderManager_ renderImages];
			drawBox(leftTouchControlBounds_);
			drawBox(rightTouchControlBounds_);
			drawBox(fireTouchControlBounds_);
			break;

#pragma mark GameOver
		case SceneState_GameOver:
			[background_ renderAtPoint:CGPointMake(0, 0)];
			[smallFont_ renderStringJustifiedInFrame:screenBounds_
									   justification:BitmapFontJustification_MiddleCentered
												text:@"Game Over"];
			[sharedImageRenderManager_ renderImages];
			break;

#pragma mark PlayerRebirth
		case SceneState_PlayerRebirth:
			[background_ renderAtPoint:CGPointMake(0, 0)];
			for(Alien *alien in aliens_) {
				if (alien.active_) {
					[alien render];
				}
			}
			[statusFont_ renderStringJustifiedInFrame:fireTouchControlBounds_
										justification:BitmapFontJustification_MiddleLeft
												 text:[NSString stringWithFormat:@"  Wave: %i", wave_]];
			[statusFont_ renderStringJustifiedInFrame:fireTouchControlBounds_
										justification:BitmapFontJustification_MiddleCentered
												 text:[NSString stringWithFormat:@"Score: %i", score_]];
			[statusFont_ renderStringJustifiedInFrame:fireTouchControlBounds_
										justification:BitmapFontJustification_MiddleRight
												 text:[NSString stringWithFormat:@"Lives: %i  ", playerLives_]];
			[sharedImageRenderManager_ renderImages];
			drawBox(leftTouchControlBounds_);
			drawBox(rightTouchControlBounds_);
			drawBox(fireTouchControlBounds_);
			break;

		default:
			break;
	}
	//	for(Alien *alien in aliens_) {
	//		drawBox(CGRectMake(alien.pixelLocation_.x + alien.collisionXOffset_, alien.pixelLocation_.y + alien.collisionYOffset_,
	//						   alien.collisionWidth_, alien.collisionHeight_));
	//	}

}

#pragma mark -

- (void)aliensHaveLanded {
	state_ = SceneState_GameOver;
}

- (void)playerKilledWithAlienFlag:(bool)killedByAlien {
	--playerLives_;
	NSLog(@"player killed: %i lives left", playerLives_);

	if (killedByAlien) {
		++alienCount_;
		NSLog(@"%i", alienCount_);
	}
	if (!playerLives_) {
		state_ = SceneState_GameOver;
		return;
	}
	state_ = SceneState_PlayerRebirth;
}

- (void)alienKilledWithPosition:(int)position points:(int)points {

	score_ += points;
	++alienCount_;
	NSLog(@"%i", alienCount_);
	if (alienCount_ == 50) {
		state_ = SceneState_WaveOver;
		return;
	}

	for (Alien *alien in aliens_) {
		if (alien.position_ == position - 10) {
			alien.canFire_ = TRUE;
		}
		alien.dx_ *= 1.027f;
		switch (alienCount_) {
			case 4:
				alien.dx_ *= 1.15f;
				break;
			case 3:
				break;
			case 2:
				alien.dx_ *= 1.15f;
				break;
			case 1:
				alien.dx_ *= 1.15f;
				break;
			default:
				break;
		}
	}
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

	for (UITouch *touch in touches) {
        // Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:nil];

        // As we have the game in landscape mode we need to switch the touches
        // x and y coordinates
		CGPoint touchLocation = [sharedGameController_ adjustTouchOrientationForTouch:originalTouchLocation];

		if (CGRectContainsPoint(fireTouchControlBounds_, touchLocation)) {
			[self playerFireShot];
		}

		if (CGRectContainsPoint(leftTouchControlBounds_, touchLocation)) {
			isLeftTouchActive_ = TRUE;
			if (isLeftTouchActive_ && !isRightTouchActive_) {
				player_.dx_ = -playerSpeed_;
			}
			if (isLeftTouchActive_ && isRightTouchActive_) {
				player_.dx_ = 0;
			}
		}
		if (CGRectContainsPoint(rightTouchControlBounds_, touchLocation)) {
			isRightTouchActive_ = TRUE;
			if (isRightTouchActive_ && !isLeftTouchActive_) {
				player_.dx_ = playerSpeed_;
			}
			if (isLeftTouchActive_ && isRightTouchActive_) {
				player_.dx_ = 0;
			}
		}
	}
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

	for (UITouch *touch in touches) {
        // Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:nil];

        // As we have the game in landscape mode we need to switch the touches
        // x and y coordinates
        CGPoint touchLocation = [sharedGameController_ adjustTouchOrientationForTouch:originalTouchLocation];

		if (CGRectContainsPoint(leftTouchControlBounds_, touchLocation)) {
			isLeftTouchActive_ = FALSE;
			if (isRightTouchActive_) {
				player_.dx_ = playerSpeed_;
			} else {
				player_.dx_ = 0;
			}
		}
		if (CGRectContainsPoint(rightTouchControlBounds_, touchLocation)) {
			isRightTouchActive_ = FALSE;
			if (isLeftTouchActive_) {
				player_.dx_ = -playerSpeed_;
			} else {
				player_.dx_ = 0;
			}
		}
	}
}

- (void)transitionToSceneWithKey:(NSString*)theKey {
    state_ = kSceneState_TransitionOut;
}

- (void)transitionIn {
    state_ = SceneState_TransitionIn;
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
		screenBounds_ = CGRectMake(0, 0, 480, 320);
	}

    return self;
}

@end


