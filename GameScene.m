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
#import "ShieldPiece.h"

#include <stdlib.h>

// Scene States
enum {
	SceneState_WaveMessage,
	SceneState_WaveOver,
	SceneState_WaveCleanup,
	SceneState_WaveIntro,
	SceneState_PlayerDeath,
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
- (void)launchBonusShip;
- (void)initShields;
- (bool)noneAliveWithEntityArray:(NSMutableArray *)entityArray;

@end

#pragma mark -
#pragma mark Private implementation

@implementation GameScene (Private)

- (bool)noneAliveWithEntityArray:(NSMutableArray *)entityArray {
	for (AbstractEntity *entity in entityArray) {
		if (entity.state_ == EntityState_Alive) {
			return FALSE;
		}
	}
	return TRUE;
}

- (void)initWave {
	++wave_;
	canPlayerFire_ = FALSE;

	[aliens_ removeAllObjects];
	[self initAliensWithSpeed:20 chanceToFire:10];
	alienOddRange_ = 10;
	[alienShots_ removeAllObjects];
	[self initAlienShots];

	player_.pixelLocation_ = CGPointMake((screenBounds_.size.width - (43*.85)) / 2, playerBaseHeight_+1);
	player_.dx_ = 0;

	[playerShots_ removeAllObjects];
	[self initPlayerShots];

	[shields_ removeAllObjects];
	[self initShields];

	for (int i = 0; i < randomListLength_; ++i) {
		[bonusSelection_ addObject:[NSNumber numberWithInt:arc4random() % 2]];
		[bonusDirection_ addObject:[NSNumber numberWithInt:arc4random() % 2]];
	    [additionalBonusDelay_ addObject:[NSNumber numberWithInt:arc4random() % 4 + 1]];
	}

//	for (int i = 0; i < randomListLength_; ++i) {
//		NSLog(@"%i", [[bonusSelection_ objectAtIndex:i] intValue]);
//	}
//	NSLog(@"==========================");
//	for (int i = 0; i < randomListLength_; ++i) {
//		NSLog(@"%i", [[bonusDirection_ objectAtIndex:i] intValue]);
//	}
//	NSLog(@"==========================");
//	for (int i = 0; i < randomListLength_; ++i) {
//		NSLog(@"%i", [[additionalBonusDelay_ objectAtIndex:i] intValue]);
//	}
//	NSLog(@"==========================");

}

- (void)initNewGame {

	[self initSound];
	randomListLength_ = 15;
	bonusDirection_ = [[NSMutableArray alloc] initWithCapacity:randomListLength_];
	bonusSelection_ = [[NSMutableArray alloc] initWithCapacity:randomListLength_];
	additionalBonusDelay_ = [[NSMutableArray alloc] initWithCapacity:randomListLength_];

	aliens_ = [[NSMutableArray alloc] init];
	numberOfAlienShots_ = 10;
	alienShots_ = [[NSMutableArray alloc] initWithCapacity:numberOfAlienShots_];
	numberOfPlayerShots_ = 10;
	playerShots_ = [[NSMutableArray alloc] initWithCapacity:numberOfPlayerShots_];
	shields_ = [[NSMutableArray alloc] initWithCapacity:66];

	playerBaseHeight_ = 35;
	player_ = [[Player alloc] initWithPixelLocation:CGPointMake((screenBounds_.size.width - (43*.85)) / 2, playerBaseHeight_+1)];
	bigBonus_ = [[BigBonusShip alloc] initWithPixelLocation:CGPointMake(0, 0)];
	smallBonus_ = [[SmallBonusShip alloc] initWithPixelLocation:CGPointMake(0, 0)];

	PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png" controlFile:@"pss_coordinates" imageFilter:GL_LINEAR];
	background_ = [[pss imageForKey:@"background.png"] retain];

	int touchBoxWidth = 65;
	leftTouchControlBounds_ = CGRectMake(1, 1, touchBoxWidth, playerBaseHeight_);
	rightTouchControlBounds_ = CGRectMake(415, 1, touchBoxWidth-1, playerBaseHeight_);
	fireTouchControlBounds_ = CGRectMake(touchBoxWidth+1, 1, 479-touchBoxWidth*2, playerBaseHeight_);
	screenSidePadding_ = 10.0f;

	smallFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"bookAntiqua32" ofType:@"png" controlFile:@"bookAntiqua32" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
	statusFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"franklin16" ofType:@"png" controlFile:@"franklin16" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
	playerSpeed_ = 110.0f;
	waveMessageInterval_ = 2.0f;
	wave_ = lastTimeInLoop_ = 0;
	playerLives_ = 3;
	bonusSpeed_ = 75;
	bonusLaunchDelay_ =  baseLaunchDelay_ = 8.0f;
}

- (void)initShields {

	ShieldPiece *shieldPiece = [[ShieldPiece alloc] initWithPixelLocation:CGPointMake(0, 0)];
	CGFloat dimension = shieldPiece.width_ * shieldPiece.scaleFactor_; // shield height and width
	[shieldPiece release];
	CGFloat space = (int)(screenBounds_.size.width / 7) * 2 + 5;
	CGFloat bottom = playerBaseHeight_ + 38;
	for (int j = 0; j < 2; ++j) {
		for (int i = 0; i < 6; ++i) {
			shieldPiece = [[ShieldPiece alloc] initWithPixelLocation:CGPointMake((j*space)+68+(i*dimension), bottom)];
			[shields_ addObject:shieldPiece];
			[shieldPiece release];
		}
		for (int i = 0; i < 6; ++i) {
			shieldPiece = [[ShieldPiece alloc] initWithPixelLocation:CGPointMake((j*space)+68+(i*dimension), bottom + dimension)];
			[shields_ addObject:shieldPiece];
			[shieldPiece release];
		}
		for (int i = 0; i < 6; ++i) {
			shieldPiece = [[ShieldPiece alloc] initWithPixelLocation:CGPointMake((j*space)+68+(i*dimension), bottom + dimension*2)];
			[shields_ addObject:shieldPiece];
			[shieldPiece release];
		}
		for (int i = 0; i < 4; ++i) {
			shieldPiece = [[ShieldPiece alloc] initWithPixelLocation:CGPointMake((j*space)+68+dimension+(i*dimension), bottom + dimension*3)];
			[shields_ addObject:shieldPiece];
			[shieldPiece release];
		}
	}
	//draw the last shield moved over a small amount
	for (int i = 0; i < 6; ++i) {
		shieldPiece = [[ShieldPiece alloc] initWithPixelLocation:CGPointMake((2*space)+73+(i*dimension), bottom)];
		[shields_ addObject:shieldPiece];
		[shieldPiece release];
	}
	for (int i = 0; i < 6; ++i) {
		shieldPiece = [[ShieldPiece alloc] initWithPixelLocation:CGPointMake((2*space)+73+(i*dimension), bottom + dimension)];
		[shields_ addObject:shieldPiece];
		[shieldPiece release];
	}
	for (int i = 0; i < 6; ++i) {
		shieldPiece = [[ShieldPiece alloc] initWithPixelLocation:CGPointMake((2*space)+73+(i*dimension), bottom + dimension*2)];
		[shields_ addObject:shieldPiece];
		[shieldPiece release];
	}
	for (int i = 0; i < 4; ++i) {
		shieldPiece = [[ShieldPiece alloc] initWithPixelLocation:CGPointMake((2*space)+73+dimension+(i*dimension), bottom + dimension*3)];
		[shields_ addObject:shieldPiece];
		[shieldPiece release];
	}

}

- (void)launchBonusShip {

	static CGFloat top = 295.0f;
	if (CACurrentMediaTime() - lastBonusLaunch_ < bonusLaunchDelay_) {
		return;
	}
	lastBonusLaunch_ = CACurrentMediaTime();
	static int randomListCount = 0;

	if (bonus_.state_ == EntityState_Alive) {

		NSLog(@"attempt to launch bonus while one is active -- increase baseLaunchDelay_");

	} else {

		if ([[bonusSelection_ objectAtIndex:randomListCount] intValue] == 1) {
			bonus_ = bigBonus_;
		} else {
			bonus_ = smallBonus_;
		}

		if ([[bonusDirection_ objectAtIndex:randomListCount] intValue] == 1) {
			bonus_.pixelLocation_ = CGPointMake(0 - bonus_.scaleFactor_ * bonus_.width_, top);
			bonus_.dx_ = bonusSpeed_;
			bonus_.state_ = EntityState_Alive;
		} else {
			bonus_.pixelLocation_ = CGPointMake(screenBounds_.size.width, top);
			bonus_.dx_ = -bonusSpeed_;
			bonus_.state_ = EntityState_Alive;
		}
	}

	//sound.play_bonus();
	bonusLaunchDelay_ = baseLaunchDelay_ + [[additionalBonusDelay_ objectAtIndex:randomListCount] intValue];
	if (++randomListCount == randomListLength_) {
		randomListCount = 0;
	}
}

- (void)alienFire {
	// check that aliens have waited long enough to fire
	static double alienShotDelay = 2.0f;
	static int alienShotCounter = 0;
	// check that player has waited long enough to fire
	if (CACurrentMediaTime() - lastAlienShot_ < alienShotDelay) {
		return;
	}
	// record time and fire
	lastAlienShot_ = CACurrentMediaTime();
	static int alienToFire = 0;
	++alienToFire;
	for (Alien *alien in aliens_) {
		if (alien.state_ == EntityState_Alive && alien.canFire_ && alien.fireChance_ == alienToFire) {
			Shot *shot = [alienShots_ objectAtIndex:alienShotCounter];
			if (shot.state_ == EntityState_Idle) {
				shot.pixelLocation_ = CGPointMake(alien.pixelLocation_.x + alien.alienInitialXShotPostion_,
												  alien.pixelLocation_.y - alien.alienInitialYShotPostion_);
				shot.state_ = EntityState_Alive;
				shot.hit_ = FALSE;
			} else {
				NSLog(@"no inactive alien shot available -- increase numberOfAlienShots_");
			}

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
	static double playerShotDelay = 0.4f;
	static double lastShot = 0.0f;
	static int playerShotCounter = 0;
	// check that player has waited long enough to fire
	if (CACurrentMediaTime() - lastShot < playerShotDelay) {
		return;
	}
	// record time and fire
	lastShot = CACurrentMediaTime();
	Shot *shot = [playerShots_ objectAtIndex:playerShotCounter];
	if (shot_.state_ == EntityState_Idle) {
		shot.pixelLocation_ = CGPointMake(player_.pixelLocation_.x + player_.playerInitialXShotPostion_,
										  player_.pixelLocation_.y + player_.playerInitialYShotPostion_ + 1);
		shot.state_ = EntityState_Alive;
		shot.hit_ = FALSE;
		[sharedSoundManager_ playSoundWithKey:@"shot" gain:0.3f];
	} else {
		NSLog(@"no inactive player shot available -- increase numberOfPlayerShots_");
	}
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

	sharedSoundManager_.fxVolume = 1.0f;
	// Initialize the sound effects
	[sharedSoundManager_ loadSoundWithKey:@"shot" soundFile:@"shot.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"alien_death" soundFile:@"alien_death.caf"];

}

- (void)deallocResources {

	[aliens_ release];
	[background_ release];

	// Release fonts
	[smallFont_ release];
	[statusFont_ release];

	// Release sounds
	[sharedSoundManager_ removeSoundWithKey:@"shot"];
	[sharedSoundManager_ removeSoundWithKey:@"alien_death"];
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
			[player_ updateWithDelta:aDelta scene:self];
			if (CACurrentMediaTime() - lastTimeInLoop_ < 2.0f) {
				return;
			}
			if (lastTimeInLoop_) {
				lastTimeInLoop_ = 0;
				lastAlienShot_ = CACurrentMediaTime();
				if (alienCount_ == 50) {
					state_ = SceneState_WaveOver;
				} else {
					state_ = SceneState_Running;
				}
				canPlayerFire_ = TRUE;
				player_.state_ = EntityState_Alive;
				return;
			}
			lastTimeInLoop_ = CACurrentMediaTime();
			player_.pixelLocation_ = CGPointMake((screenBounds_.size.width - (43*.85)) / 2, playerBaseHeight_+1);
			player_.dx_ = 0;
			break;

#pragma mark PlayerDeath
		case SceneState_PlayerDeath:
			[player_ updateWithDelta:aDelta scene:self];
			if (bonus_.state_ == EntityState_Dying) {
				[bonus_ updateWithDelta:aDelta scene:self];
			}
			for(Alien *alien in aliens_) {
				if (alien.state_ == EntityState_Dying) {
					[alien updateWithDelta:aDelta scene:self];
				}
			}
			if (CACurrentMediaTime() - lastTimeInLoop_ < 2.0f) {
				return;
			}
			if (lastTimeInLoop_) {
				lastTimeInLoop_ = 0;
				if (alienCount_ == 50 && !playerLives_) {
					state_ = SceneState_GameOver;
					return;
				}
				if (alienCount_ == 50) {
					state_ = SceneState_PlayerRebirth;
					player_.state_ = EntityState_Appearing;
					return;
				}
				if (!playerLives_) {
					state_ = SceneState_GameOver;
					return;
				}
				state_ = SceneState_PlayerRebirth;
				player_.state_ = EntityState_Appearing;
				return;
			}
			lastTimeInLoop_ = CACurrentMediaTime();
			canPlayerFire_ = FALSE;
			for (Shot *shot in playerShots_) {
				if (shot.state_ == EntityState_Alive) {
					if (bonus_.state_ == EntityState_Alive) {
						[bonus_	checkForCollisionWithEntity:shot];
					}
					for (ShieldPiece *shieldPiece in shields_) {
						if (shieldPiece.state_ == EntityState_Alive) {
							[shot checkForCollisionWithEntity:shieldPiece];
						}
					}
					for (Shot *alienShot in alienShots_) {
						if (alienShot.state_ == EntityState_Alive) {
							[alienShot checkForCollisionWithEntity:shot];
						}
					}
				}
			}
			for (Shot *shot in alienShots_) {
				if (shot.state_ == EntityState_Alive) {
					for (ShieldPiece *shieldPiece in shields_) {
						if (shieldPiece.state_ == EntityState_Alive) {
							[shot checkForCollisionWithEntity:shieldPiece];
						}
					}
				}
			}
			for (Alien *alien in aliens_) {
				if (alien.state_ == EntityState_Alive) {
					for (Shot *shot in playerShots_) {
						if (shot.state_ == EntityState_Alive) {
							[alien checkForCollisionWithEntity:shot];
						}
					}
					for (ShieldPiece *shieldPiece in shields_) {
						if (shieldPiece.state_ == EntityState_Alive) {
							[alien checkForCollisionWithEntity:shieldPiece];
						}
					}
				}
			}
			// deactiveate shots to give player a chance to recover
			for (Shot *shot in alienShots_) {
				shot.state_ = EntityState_Idle;
			}
			for (Shot *shot in playerShots_) {
				shot.state_ = EntityState_Idle;
			}
			break;

#pragma mark WaveIntro
		case SceneState_WaveIntro:
			[player_ updateWithDelta:aDelta scene:self];
			for(Alien *alien in aliens_) {
				[alien updateWithDelta:aDelta scene:self];
			}
			if (CACurrentMediaTime() - lastTimeInLoop_ < 3.25f) {
				return;
			}
			if (lastTimeInLoop_) {
				canPlayerFire_ = TRUE;
				for(Alien *alien in aliens_) {
					alien.state_ = EntityState_Alive;
				}
				state_ = SceneState_Running;
				lastBonusLaunch_ = lastAlienShot_ = CACurrentMediaTime();
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
				state_ = SceneState_WaveIntro;
				for(Alien *alien in aliens_) {
					alien.state_ = EntityState_Appearing;
				}
				lastTimeInLoop_ = 0;
				return;
			}
			lastTimeInLoop_ = CACurrentMediaTime();
			break;

#pragma mark WaveCleanup
		case SceneState_WaveCleanup:
			if (CACurrentMediaTime() - lastTimeInLoop_ < 3.0f) {
				for(Alien *alien in aliens_) {
					[alien updateWithDelta:aDelta scene:self];
				}
				[player_ movementWithDelta:aDelta];
				[bonus_ updateWithDelta:aDelta scene:self];
				[bonus_ movementWithDelta:aDelta];
				for (Shot *shot in playerShots_) {
					//[shot updateWithDelta:aDelta scene:self];
					[shot movementWithDelta:aDelta];
				}

				for (Shot *shot in alienShots_) {
					//[shot updateWithDelta:aDelta scene:self];
					[shot movementWithDelta:aDelta];
				}
				return;
			}
			state_ = SceneState_WaveMessage;
			lastTimeInLoop_ = 0;
			break;

#pragma mark WaveOver
		case SceneState_WaveOver:

			for(Alien *alien in aliens_) {
				[alien updateWithDelta:aDelta scene:self];
			}

			if (bonus_.state_ == EntityState_Dying || bonus_.state_ == EntityState_Idle) {
				canPlayerFire_ = FALSE;
			}
			if (bonus_.state_ == EntityState_Dying || bonus_.state_ == EntityState_Idle
				&& [self noneAliveWithEntityArray:alienShots_]
				&& [self noneAliveWithEntityArray:playerShots_]) {
				lastTimeInLoop_ = CACurrentMediaTime();
				state_ = SceneState_WaveCleanup;
				NSLog(@"everything is idle");
			}
			//[player_ updateWithDelta:aDelta scene:self];
			[player_ movementWithDelta:aDelta];

			[bonus_ updateWithDelta:aDelta scene:self];
			[bonus_ movementWithDelta:aDelta];

			for (Shot *shot in playerShots_) {
				//[shot updateWithDelta:aDelta scene:self];
				[shot movementWithDelta:aDelta];
			}

			for (Shot *shot in alienShots_) {
				//[shot updateWithDelta:aDelta scene:self];
				[shot movementWithDelta:aDelta];
			}

#pragma mark WaveOver Collision Detection
			for (Shot *shot in alienShots_) {
				if (shot.state_ == EntityState_Alive) {
					if (player_.state_ == EntityState_Alive) {
						[player_ checkForCollisionWithEntity:shot];
					}
					for (ShieldPiece *shieldPiece in shields_) {
						if (shieldPiece.state_ == EntityState_Alive) {
							[shot checkForCollisionWithEntity:shieldPiece];
						}
					}
				}
			}

			for (Shot *shot in playerShots_) {
				if (shot.state_ == EntityState_Alive) {
					if (bonus_.state_ == EntityState_Alive) {
						[bonus_	checkForCollisionWithEntity:shot];
					}
					for (ShieldPiece *shieldPiece in shields_) {
						if (shieldPiece.state_ == EntityState_Alive) {
							[shot checkForCollisionWithEntity:shieldPiece];
						}
					}
					for (Shot *alienShot in alienShots_) {
						if (alienShot.state_ == EntityState_Alive) {
							[alienShot checkForCollisionWithEntity:shot];
						}
					}
				}
			}
			break;

#pragma mark Running
		case SceneState_Running:

			[self alienFire];
			[self launchBonusShip];
			for(Alien *alien in aliens_) {
				[alien updateWithDelta:aDelta scene:self];
				if (alien.state_ == EntityState_Alive) {
					[alien movementWithDelta:aDelta];
				}
			}

			//[player_ updateWithDelta:aDelta scene:self];
			[player_ movementWithDelta:aDelta];

			[bonus_ updateWithDelta:aDelta scene:self];
			if (bonus_.state_ == EntityState_Alive) {
				[bonus_ movementWithDelta:aDelta];
			}

			for (Shot *shot in playerShots_) {
				if (shot.state_ == EntityState_Alive) {
					//[shot updateWithDelta:aDelta scene:self];
					[shot movementWithDelta:aDelta];
				}
			}

			for (Shot *shot in alienShots_) {
				if (shot.state_ == EntityState_Alive) {
					//[shot updateWithDelta:aDelta scene:self];
					[shot movementWithDelta:aDelta];
				}
			}

#pragma mark Running Collision Detection
			for (Shot *shot in playerShots_) {
				if (shot.state_ == EntityState_Alive) {
					if (bonus_.state_ == EntityState_Alive) {
						[bonus_	checkForCollisionWithEntity:shot];
					}
					for (ShieldPiece *shieldPiece in shields_) {
						if (shieldPiece.state_ == EntityState_Alive) {
							[shot checkForCollisionWithEntity:shieldPiece];
						}
					}
					for (Shot *alienShot in alienShots_) {
						if (alienShot.state_ == EntityState_Alive) {
							[alienShot checkForCollisionWithEntity:shot];
						}
					}
				}
			}
			for (Shot *shot in alienShots_) {
				if (shot.state_ == EntityState_Alive) {
					if (player_.state_ == EntityState_Alive) {
						[player_ checkForCollisionWithEntity:shot];
					}
					for (ShieldPiece *shieldPiece in shields_) {
						if (shieldPiece.state_ == EntityState_Alive) {
							[shot checkForCollisionWithEntity:shieldPiece];
						}
					}
				}
			}
			for (Alien *alien in aliens_) {
				if (alien.state_ == EntityState_Alive) {
					for (Shot *shot in playerShots_) {
						if (shot.state_ == EntityState_Alive) {
							[alien checkForCollisionWithEntity:shot];
						}
					}
					if (player_.state_ == EntityState_Alive) {
						[player_ checkForCollisionWithEntity:alien];
					}
					for (ShieldPiece *shieldPiece in shields_) {
						if (shieldPiece.state_ == EntityState_Alive) {
							[alien checkForCollisionWithEntity:shieldPiece];
						}
					}
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
			canPlayerFire_ = TRUE;
			[background_ renderAtPoint:CGPointMake(0, 0)];
			for (Shot *shot in playerShots_) {
				if (shot.state_ == EntityState_Alive) {
					[shot render];
				}
			}
			for (Shot *shot in alienShots_) {
				if (shot.state_ == EntityState_Alive) {
					[shot render];
				}
			}
			[sharedImageRenderManager_ renderImages];

			[player_ render];
			[bonus_	render];

			for (ShieldPiece *shieldPiece in shields_) {
				if (shieldPiece.state_ == EntityState_Alive) {
					[shieldPiece render];
				}
			}

			for(Alien *alien in aliens_) {
				[alien render];
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

#pragma mark WaveIntro
		case SceneState_WaveIntro:
			[background_ renderAtPoint:CGPointMake(0, 0)];
			[sharedImageRenderManager_ renderImages];

			[player_ render];
			for(Alien *alien in aliens_) {
				[alien render];
			}
			for (ShieldPiece *shieldPiece in shields_) {
				[shieldPiece render];
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

#pragma mark WaveCleanup
		case SceneState_WaveCleanup:
			[background_ renderAtPoint:CGPointMake(0, 0)];
			[sharedImageRenderManager_ renderImages];

			[player_ render];
			[bonus_ render];
			for(Alien *alien in aliens_) {
				[alien render];
			}
			for (ShieldPiece *shieldPiece in shields_) {
				if (shieldPiece.state_ == EntityState_Alive) {
					[shieldPiece render];
				}
			}
			for (Shot *shot in playerShots_) {
				if (shot.state_ == EntityState_Alive) {
					[shot render];
				}
			}
			for (Shot *shot in alienShots_) {
				if (shot.state_ == EntityState_Alive) {
					[shot render];
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

#pragma mark WaveOver
		case SceneState_WaveOver:
			[background_ renderAtPoint:CGPointMake(0, 0)];
			[sharedImageRenderManager_ renderImages];

			[player_ render];
			[bonus_ render];
			for(Alien *alien in aliens_) {
				[alien render];
			}

			for (ShieldPiece *shieldPiece in shields_) {
				if (shieldPiece.state_ == EntityState_Alive) {
					[shieldPiece render];
				}
			}
			for (Shot *shot in playerShots_) {
				if (shot.state_ == EntityState_Alive) {
					[shot render];
				}
			}
			for (Shot *shot in alienShots_) {
				if (shot.state_ == EntityState_Alive) {
					[shot render];
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

#pragma mark GameOver
		case SceneState_GameOver:
			[background_ renderAtPoint:CGPointMake(0, 0)];
			[smallFont_ renderStringJustifiedInFrame:screenBounds_
									   justification:BitmapFontJustification_MiddleCentered
												text:@"Game Over"];
			[sharedImageRenderManager_ renderImages];
			break;

#pragma mark PlayerDeath
		case SceneState_PlayerDeath:
			[background_ renderAtPoint:CGPointMake(0, 0)];
			[sharedImageRenderManager_ renderImages];
			[player_ render];
			[bonus_ render];

			for(Alien *alien in aliens_) {
				[alien render];
			}
			for (ShieldPiece *shieldPiece in shields_) {
				if (shieldPiece.state_ == EntityState_Alive) {
					[shieldPiece render];
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

#pragma mark PlayerRebirth
		case SceneState_PlayerRebirth:
			[background_ renderAtPoint:CGPointMake(0, 0)];
			[sharedImageRenderManager_ renderImages];
			[player_ render];
			[bonus_ render];

			for(Alien *alien in aliens_) {
				[alien render];
			}
			for (ShieldPiece *shieldPiece in shields_) {
				if (shieldPiece.state_ == EntityState_Alive) {
					[shieldPiece render];
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

	}
//	for(Alien *alien in aliens_) {
//		drawBox(CGRectMake(alien.pixelLocation_.x + alien.collisionXOffset_, alien.pixelLocation_.y + alien.collisionYOffset_,
//						   alien.collisionWidth_, alien.collisionHeight_));
//	}
//	drawBox(CGRectMake(player_.pixelLocation_.x + player_.collisionXOffset_, player_.pixelLocation_.y + player_.collisionYOffset_,
//			player_.collisionWidth_, player_.collisionHeight_));

}

#pragma mark -

- (void)aliensHaveLanded {
	state_ = SceneState_GameOver;
}

- (void)bonusShipDestroyedWithPoints:(int)points {
	score_ += points;
}

- (void)playerKilledWithAlienFlag:(bool)killedByAlien {
	--playerLives_;
	NSLog(@"player killed: %i lives left", playerLives_);

	if (killedByAlien) {
		++alienCount_;
		NSLog(@"%i", alienCount_);

	}
	state_ = SceneState_PlayerDeath;
}

- (void)alienKilledWithPosition:(int)position points:(int)points {

	[sharedSoundManager_ playSoundWithKey:@"alien_death" gain:0.1f];
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
			if (canPlayerFire_) {
				[self playerFireShot];
			}
		}

		if (CGRectContainsPoint(leftTouchControlBounds_, touchLocation)) {
			player_.dx_ = -playerSpeed_;
		}
		if (CGRectContainsPoint(rightTouchControlBounds_, touchLocation)) {
			player_.dx_ = playerSpeed_;
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
			player_.dx_ = 0;
		}
		if (CGRectContainsPoint(rightTouchControlBounds_, touchLocation)) {
			player_.dx_ = 0;
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


