//  GameScene.m

#import <QuartzCore/QuartzCore.h>
#import <stdlib.h>
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
#import "Score.h"

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
- (void)freeGuyCheck;
- (void)getPlayerName;

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

- (void)getPlayerName {
	// The game is over and we want to get the players name for the score board.  We are going to a UIAlertview
	// to do this for us.  The message which is defined as "anything" cannot be blank else the buttons on the
	// alertview will overlap the textfield.
	UIAlertView *playersNameAlertView = [[UIAlertView alloc] initWithTitle:@"Enter Your Name" message:@"anything"
																  delegate:self cancelButtonTitle:@"Dismiss"
														 otherButtonTitles:@"OK", nil];

	// A normal alterview is in the middle of the screen, so we move it up else the keyboard for the textfield
	// will be rendered over the alert view
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 80);
	playersNameAlertView.transform = transform;

	// Now we have moved the view we need to create a UITextfield to add to the view
	UITextField *playersNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 20)];

	// We set the background to white and the tag to 99.  This allows us to reference the text field in the alert
	// view later on to get the text that is typed in.  We also set it to becomeFirstResponder so that the keyboard
	// automatically shows
	playersNameTextField.backgroundColor = [UIColor whiteColor];
	playersNameTextField.tag = 99;
	[playersNameTextField becomeFirstResponder];

	// Add the textfield to the alert view
	[playersNameAlertView addSubview:playersNameTextField];

	// Show the alert view and then release it and the textfield.  As they are shown a retain is held.  If
	// we do not release then we will leak memory when the view is dismissed.
	[playersNameAlertView show];
	[playersNameAlertView release];
	[playersNameTextField release];
}
- (void)freeGuyCheck {
	if (score_ >= nextFreeGuy_) {
		[sharedSoundManager_ playSoundWithKey:@"free_guy" gain:0.7f];
		++playerLives_;
		nextFreeGuy_ += freeGuyValue_;
	}
}

- (void)initWave {
	++wave_;
	canPlayerFire_ = FALSE;
	player_.pixelLocation_ = CGPointMake((screenBounds_.size.width - (player_.width_*player_.scaleFactor_)) / 2, playerBaseHeight_+1);
	player_.dx_ = 0;

	[bigBonus_ release];
	bigBonus_ = [[BigBonusShip alloc] initWithPixelLocation:CGPointMake(0, 0)];
	[smallBonus_ release];
	smallBonus_ = [[SmallBonusShip alloc] initWithPixelLocation:CGPointMake(0, 0)];

	[aliens_ removeAllObjects];

	[bonusSelection_ removeAllObjects];
	[bonusDirection_ removeAllObjects];
	[additionalBonusDelay_ removeAllObjects];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		for (int i = 0; i < randomListLength_; ++i) {
			[bonusSelection_ addObject:[NSNumber numberWithInt:arc4random() % 2]];
			[bonusDirection_ addObject:[NSNumber numberWithInt:arc4random() % 2]];
			[additionalBonusDelay_ addObject:[NSNumber numberWithInt:arc4random() % 4 + 1]];
		}
		alienShotDelay_ = 2.0f;
		numberOfAlienShots_ = 10;
		numberOfPlayerShots_ = 10;
		alienOddRange_ = 10;
		[alienShots_ removeAllObjects];
		[self initAlienShots];
		[playerShots_ removeAllObjects];
		[self initPlayerShots];
		[self initAliensWithSpeed:50 chanceToFire:10];
	} else {
		[shields_ removeAllObjects];
		[self initShields];

#pragma mark iPhone waves
		switch (wave_) {
			case 1:
				for (int i = 0; i < randomListLength_; ++i) {
					[bonusSelection_ addObject:[NSNumber numberWithInt:arc4random() % 6 + 1]];
					[bonusDirection_ addObject:[NSNumber numberWithInt:arc4random() % 2]];
					[additionalBonusDelay_ addObject:[NSNumber numberWithInt:arc4random() % 5 + 1]];
				}
				alienShotDelay_ = 1.0f;
				alienOddRange_ = 10;
				alienSpeed_ = 30 + (arc4random() % 5 + 1);
				[self initAliensWithSpeed:alienSpeed_ chanceToFire:alienOddRange_];

				[alienShots_ removeAllObjects];
				numberOfAlienShots_ = 10;
				[self initAlienShots];

				[playerShots_ removeAllObjects];
				numberOfPlayerShots_ = 10;
				[self initPlayerShots];

				break;

			case 2:
				for (int i = 0; i < randomListLength_; ++i) {
					[bonusSelection_ addObject:[NSNumber numberWithInt:arc4random() % 5 + 1]];
					[bonusDirection_ addObject:[NSNumber numberWithInt:arc4random() % 2]];
					[additionalBonusDelay_ addObject:[NSNumber numberWithInt:arc4random() % 4 + 1]];
				}
				alienShotDelay_ = 1.0f;
				alienOddRange_ = 8;
				alienSpeed_ += arc4random() % 5 + 1;
				[self initAliensWithSpeed:alienSpeed_ chanceToFire:alienOddRange_];

				[alienShots_ removeAllObjects];
				numberOfAlienShots_ = 10;
				[self initAlienShots];

				[playerShots_ removeAllObjects];
				numberOfPlayerShots_ = 10;
				[self initPlayerShots];
				break;

			case 3:
				for (int i = 0; i < randomListLength_; ++i) {
					[bonusSelection_ addObject:[NSNumber numberWithInt:arc4random() % 4 + 1]];
					[bonusDirection_ addObject:[NSNumber numberWithInt:arc4random() % 2]];
					[additionalBonusDelay_ addObject:[NSNumber numberWithInt:arc4random() % 3 + 1]];
				}
				alienShotDelay_ = 0.8f;
				alienOddRange_ = 7;
				alienSpeed_ += arc4random() % 5 + 1;
				[self initAliensWithSpeed:alienSpeed_ chanceToFire:alienOddRange_];

				[alienShots_ removeAllObjects];
				numberOfAlienShots_ = 10;
				[self initAlienShots];

				[playerShots_ removeAllObjects];
				numberOfPlayerShots_ = 10;
				[self initPlayerShots];
				break;

			case 4:
				for (int i = 0; i < randomListLength_; ++i) {
					[bonusSelection_ addObject:[NSNumber numberWithInt:arc4random() % 3 + 1]];
					[bonusDirection_ addObject:[NSNumber numberWithInt:arc4random() % 2]];
					[additionalBonusDelay_ addObject:[NSNumber numberWithInt:arc4random() % 3 + 1]];
				}
				alienShotDelay_ = 0.8f;
				alienOddRange_ = 7;
				alienSpeed_ += arc4random() % 5 + 1;
				[self initAliensWithSpeed:alienSpeed_ chanceToFire:alienOddRange_];

				[alienShots_ removeAllObjects];
				numberOfAlienShots_ = 10;
				[self initAlienShots];

				[playerShots_ removeAllObjects];
				numberOfPlayerShots_ = 10;
				[self initPlayerShots];
				break;

			case 5:
				for (int i = 0; i < randomListLength_; ++i) {
					[bonusSelection_ addObject:[NSNumber numberWithInt:arc4random() % 3 + 1]];
					[bonusDirection_ addObject:[NSNumber numberWithInt:arc4random() % 2]];
					[additionalBonusDelay_ addObject:[NSNumber numberWithInt:arc4random() % 2 + 1]];
				}
				alienShotDelay_ = 0.7f;
				alienOddRange_ = 6;
				alienSpeed_ += arc4random() % 5 + 1;
				[self initAliensWithSpeed:alienSpeed_ chanceToFire:alienOddRange_];

				[alienShots_ removeAllObjects];
				numberOfAlienShots_ = 10;
				[self initAlienShots];

				[playerShots_ removeAllObjects];
				numberOfPlayerShots_ = 10;
				[self initPlayerShots];
				break;


			default:
				for (int i = 0; i < randomListLength_; ++i) {
					[bonusSelection_ addObject:[NSNumber numberWithInt:arc4random() % 2 + 1]];
					[bonusDirection_ addObject:[NSNumber numberWithInt:arc4random() % 2]];
					[additionalBonusDelay_ addObject:[NSNumber numberWithInt:arc4random() % 2 + 1]];
				}
				if (alienShotDelay_ > .4f) {
					alienShotDelay_ -= .1f;
				}
#ifdef MYDEBUG
				NSLog(@"alienShotDelay_ -- %f", alienShotDelay_);
#endif
				alienOddRange_ = 6;
				alienSpeed_ += arc4random() % 3 + 1;
				[self initAliensWithSpeed:alienSpeed_ chanceToFire:alienOddRange_];

				[alienShots_ removeAllObjects];
				numberOfAlienShots_ = 15;
				[self initAlienShots];

				[playerShots_ removeAllObjects];
				numberOfPlayerShots_ = 10;
				[self initPlayerShots];
				break;
		}

	}
#ifdef MYDEBUG
	for (int i = 0; i < randomListLength_; ++i) {
		NSLog(@"%i", [[bonusSelection_ objectAtIndex:i] intValue]);
	}
	NSLog(@"==========================");
	for (int i = 0; i < randomListLength_; ++i) {
		NSLog(@"%i", [[bonusDirection_ objectAtIndex:i] intValue]);
	}
	NSLog(@"==========================");
	for (int i = 0; i < randomListLength_; ++i) {
		NSLog(@"%i", [[additionalBonusDelay_ objectAtIndex:i] intValue]);
	}
	NSLog(@"==========================");
	NSLog(@"wave -- %i", wave_);
	NSLog(@"alienSpeed -- %i", alienSpeed_);
#endif
}

- (void)initNewGame {

	int touchBoxWidth;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		playerBaseHeight_ = 150;
		bonusShipTop_ = 700.0f;
		touchBoxWidth = 200;
		bonusSpeed_ = 125;
		bonusLaunchDelay_ =  baseLaunchDelay_ = 11.0f;
		playerSpeed_ = 200.0f;
		screenSidePadding_ = 25.0f;
		smallFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"bookAntiqua32"
														 ofType:@"png"
													controlFile:@"bookAntiqua32"
														  scale:Scale2fMake(2.0f, 2.0f)
														 filter:GL_LINEAR];

		statusFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"franklin16"
														  ofType:@"png"
													 controlFile:@"franklin16"
														   scale:Scale2fMake(2.0f, 2.0f)
														  filter:GL_LINEAR];
	} else {
		playerBaseHeight_ = 35;
		bonusShipTop_ = 295.0f;
		touchBoxWidth = 70;
		bonusSpeed_ = 80;
		bonusLaunchDelay_ =  baseLaunchDelay_ = 10.0f;
		playerSpeed_ = 120.0f;
		screenSidePadding_ = 10.0f;
		smallFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"bookAntiqua32"
														 ofType:@"png"
													controlFile:@"bookAntiqua32"
														  scale:Scale2fMake(1.0f, 1.0f)
														 filter:GL_LINEAR];

		statusFont_ = [[BitmapFont alloc] initWithFontImageNamed:@"franklin16"
														  ofType:@"png"
													 controlFile:@"franklin16"
														   scale:Scale2fMake(1.0f, 1.0f)
														  filter:GL_LINEAR];

		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
																	   controlFile:@"pss_coordinates"
																	   imageFilter:GL_LINEAR];
		background_ = [[pss imageForKey:@"background.png"] retain];
	}

	player_ = [[Player alloc] initWithPixelLocation:CGPointMake((screenBounds_.size.width - (player_.width_*player_.scaleFactor_)) / 2, playerBaseHeight_+1)];
	bigBonus_ = [[BigBonusShip alloc] initWithPixelLocation:CGPointMake(0, 0)];
	smallBonus_ = [[SmallBonusShip alloc] initWithPixelLocation:CGPointMake(0, 0)];

	leftTouchControlBounds_ = CGRectMake(1, 1, touchBoxWidth, playerBaseHeight_);
	rightTouchControlBounds_ = CGRectMake(screenBounds_.size.width - touchBoxWidth, 1, touchBoxWidth-1, playerBaseHeight_);
	fireTouchControlBounds_ = CGRectMake(touchBoxWidth+1, 1, screenBounds_.size.width - 1 - touchBoxWidth*2, playerBaseHeight_);

	randomListLength_ = 15;
	bonusDirection_ = [[NSMutableArray alloc] initWithCapacity:randomListLength_];
	bonusSelection_ = [[NSMutableArray alloc] initWithCapacity:randomListLength_];
	additionalBonusDelay_ = [[NSMutableArray alloc] initWithCapacity:randomListLength_];

	aliens_ = [[NSMutableArray alloc] init];
	alienShots_ = [[NSMutableArray alloc] init];
	playerShots_ = [[NSMutableArray alloc] init];
	shields_ = [[NSMutableArray alloc] initWithCapacity:66];

	waveMessageInterval_ = 2.0f;
	wave_ = 0;
	lastTimeInLoop_ = 0;
	playerLives_ = 3;
	nextFreeGuy_ = freeGuyValue_ = 10000;
	score_ = 0;
	for (Score *s in sharedGameController_.highScores) {
		s.isMostRecentScore_ = FALSE;
	}

	[self initSound];
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

	if (CACurrentMediaTime() - lastBonusLaunch_ < bonusLaunchDelay_) {
		return;
	}
	lastBonusLaunch_ = CACurrentMediaTime();
	static int randomListCount = 0;

	if (bonus_.state_ == EntityState_Alive) {
#ifdef MYDEBUG
		NSLog(@"attempt to launch bonus while one is active -- increase baseLaunchDelay_ wave -- %i", wave_);
#endif
	} else {

		if ([[bonusSelection_ objectAtIndex:randomListCount] intValue] == 1) {
			bonus_ = smallBonus_;
		} else {
			bonus_ = bigBonus_;
		}

		if ([[bonusDirection_ objectAtIndex:randomListCount] intValue] == 1) {
			bonus_.pixelLocation_ = CGPointMake(0 - bonus_.scaleFactor_ * bonus_.width_, bonusShipTop_);
			bonus_.dx_ = bonusSpeed_;
			bonus_.state_ = EntityState_Alive;
		} else {
			bonus_.pixelLocation_ = CGPointMake(screenBounds_.size.width, bonusShipTop_);
			bonus_.dx_ = -bonusSpeed_;
			bonus_.state_ = EntityState_Alive;
		}
	}

	[sharedSoundManager_ playSoundWithKey:@"active_bonus" gain:0.25f pitch:1.0 location:CGPointMake(0, 0) shouldLoop:TRUE];
	bonusLaunchDelay_ = baseLaunchDelay_ + [[additionalBonusDelay_ objectAtIndex:randomListCount] intValue];
	if (++randomListCount == randomListLength_) {
		randomListCount = 0;
	}
}

- (void)alienFire {
	// check that aliens have waited long enough to fire
	static int alienShotCounter = 0;
	// check that player has waited long enough to fire
	if (CACurrentMediaTime() - lastAlienShot_ < alienShotDelay_) {
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
#ifdef MYDEBUG
				NSLog(@"no inactive alien shot available -- increase numberOfAlienShots_ wave -- %i", wave_);
#endif
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
	static double playerShotDelay = 0.3f;
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
		[sharedSoundManager_ playSoundWithKey:@"shot" gain:0.075f];
	} else {
#ifdef MYDEBUG
		NSLog(@"no inactive player shot available -- increase numberOfPlayerShots_ wave -- %i", wave_);
#endif
	}
	if (++playerShotCounter == numberOfPlayerShots_) {
		playerShotCounter = 0;
	}
}

- (void)initAliensWithSpeed:(int)alienSpeed chanceToFire:(int)chanceToFire {
	Alien *alien;
	alienCount_ = 50;
	CGFloat x;
	CGFloat y;
	CGFloat horizontalSpace;
	CGFloat verticalSpace;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		x = 130.0f;
		y = 340.0f;
		horizontalSpace = 70;
		verticalSpace = 50;
	} else {
		x = 65.0f;
		y = 170.0f;
		horizontalSpace = 35;
		verticalSpace = 25;
	}
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
#ifdef MYDEBUG
	//NSLog(@"%@", aliens_);
#endif

}

- (void)initPlayerShots {
	for (int i = 0; i < numberOfPlayerShots_; ++i) {
		Shot *shot = [[Shot alloc] initWithPixelLocation:CGPointMake(0,0)];
		[playerShots_ addObject:shot];
		[shot release];
	}
#ifdef MYDEBUG
	//NSLog(@"%@", playerShots_);
#endif

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
	[sharedSoundManager_ loadSoundWithKey:@"explosion" soundFile:@"explosion.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"player_rebirth" soundFile:@"player_rebirth.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"active_bonus" soundFile:@"BuzzyLp.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"shot_collision" soundFile:@"Impact3.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"big_bonus" soundFile:@"small_bonus.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"small_bonus" soundFile:@"PowerUp3.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"start_wave" soundFile:@"Transform1.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"alien_birth" soundFile:@"Transform4.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"wave_end" soundFile:@"LevelUp2.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"aliens_landed" soundFile:@"Lost2.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"bg" soundFile:@"bg.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"bg_1" soundFile:@"bg_1.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"bg_2" soundFile:@"bg_2.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"bg_3" soundFile:@"bg_3.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"bg_4" soundFile:@"bg_4.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"game_over" soundFile:@"Lost3.caf"];
	[sharedSoundManager_ loadSoundWithKey:@"free_guy" soundFile:@"Flourish3.caf"];
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
	[sharedSoundManager_ removeSoundWithKey:@"explosion"];
	[sharedSoundManager_ removeSoundWithKey:@"active_bonus"];
	[sharedSoundManager_ removeSoundWithKey:@"player_rebirth"];
	[sharedSoundManager_ removeSoundWithKey:@"shot_collision"];
	[sharedSoundManager_ removeSoundWithKey:@"big_bonus"];
	[sharedSoundManager_ removeSoundWithKey:@"small_bonus"];
	[sharedSoundManager_ removeSoundWithKey:@"start_wave"];
	[sharedSoundManager_ removeSoundWithKey:@"alien_birth"];
	[sharedSoundManager_ removeSoundWithKey:@"wave_end"];
	[sharedSoundManager_ removeSoundWithKey:@"aliens_landed"];
	[sharedSoundManager_ removeSoundWithKey:@"bg"];
	[sharedSoundManager_ removeSoundWithKey:@"bg_1"];
	[sharedSoundManager_ removeSoundWithKey:@"bg_2"];
	[sharedSoundManager_ removeSoundWithKey:@"bg_3"];
	[sharedSoundManager_ removeSoundWithKey:@"bg_4"];
	[sharedSoundManager_ removeSoundWithKey:@"game_over"];
	[sharedSoundManager_ removeSoundWithKey:@"free_guy"];
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
				if (alienCount_ >= 50) {
					state_ = SceneState_WaveOver;
					[sharedSoundManager_ stopSoundWithKey:@"bg_1"];
				} else {
					state_ = SceneState_Running;
				}
				canPlayerFire_ = TRUE;
				player_.state_ = EntityState_Alive;
				if (alienCount_ != 50) {
					switch (alienCount_) {
						case 46:
							[sharedSoundManager_ playSoundWithKey:@"bg_4" gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:TRUE];
#ifdef MYDEBUG
							NSLog(@"player rebirth 46");
#endif
							break;
						case 47:
							[sharedSoundManager_ playSoundWithKey:@"bg_3" gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:TRUE];
#ifdef MYDEBUG
							NSLog(@"player rebirth 47");
#endif
							break;
						case 48:
							[sharedSoundManager_ playSoundWithKey:@"bg_2" gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:TRUE];
#ifdef MYDEBUG
							NSLog(@"player rebirth 48");
#endif
							break;
						case 49:
							[sharedSoundManager_ playSoundWithKey:@"bg_1" gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:TRUE];
#ifdef MYDEBUG
							NSLog(@"player rebirth 49");
#endif
							break;
						default:
							[sharedSoundManager_ playSoundWithKey:@"bg" gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:TRUE];
#ifdef MYDEBUG
							NSLog(@"player rebirth default");
#endif
							break;
					}
				}
				if (bonus_.state_ == EntityState_Alive) {
					[sharedSoundManager_ playSoundWithKey:@"active_bonus" gain:0.25f pitch:1.0 location:CGPointMake(0, 0) shouldLoop:TRUE];
				}
				return;
			}
			[sharedSoundManager_ playSoundWithKey:@"player_rebirth" gain:0.3f];
			lastTimeInLoop_ = CACurrentMediaTime();
			player_.pixelLocation_ = CGPointMake((screenBounds_.size.width - (player_.width_*player_.scaleFactor_)) / 2, playerBaseHeight_+1);
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
				if (alienCount_ >= 50 && !playerLives_) {
					state_ = SceneState_GameOver;
					[sharedSoundManager_ stopSoundWithKey:@"bg_1"];
					[sharedSoundManager_ playSoundWithKey:@"game_over" gain:.75f];
					return;
				}
				if (alienCount_ >= 50) {
					state_ = SceneState_PlayerRebirth;
					[sharedSoundManager_ stopSoundWithKey:@"bg_1"];
					player_.state_ = EntityState_Appearing;
					return;
				}
				if (!playerLives_) {
					state_ = SceneState_GameOver;
					[sharedSoundManager_ playSoundWithKey:@"game_over" gain:.75f];
					return;
				}
				state_ = SceneState_PlayerRebirth;
				player_.state_ = EntityState_Appearing;
				return;
			}
			lastTimeInLoop_ = CACurrentMediaTime();
			switch (alienCount_) {
				case 46:
					[sharedSoundManager_ stopSoundWithKey:@"bg_4"];
#ifdef MYDEBUG
					NSLog(@"player death 46");
#endif
					break;
				case 47:
					[sharedSoundManager_ stopSoundWithKey:@"bg_3"];
#ifdef MYDEBUG
					NSLog(@"player death 47");
#endif
					break;
				case 48:
					[sharedSoundManager_ stopSoundWithKey:@"bg_2"];
#ifdef MYDEBUG
					NSLog(@"player death 48");
#endif
					break;
				case 49:
					[sharedSoundManager_ stopSoundWithKey:@"bg_1"];
#ifdef MYDEBUG
					NSLog(@"player death 49");
#endif
					break;
				default:
					[sharedSoundManager_ stopSoundWithKey:@"bg"];
#ifdef MYDEBUG
					NSLog(@"player death default");
#endif
					break;
			}
			if (bonus_.state_ == EntityState_Alive) {
				[sharedSoundManager_ stopSoundWithKey:@"active_bonus"];
			}
			canPlayerFire_ = FALSE;
			bonusLaunchDelay_ += 2.0f;
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
			if (CACurrentMediaTime() - lastTimeInLoop_ < 2.75f) {
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
				[sharedSoundManager_ playSoundWithKey:@"bg" gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:TRUE];
				return;
			}
			[sharedSoundManager_ playSoundWithKey:@"alien_birth" gain:0.5f];
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
			[sharedSoundManager_ playSoundWithKey:@"start_wave" gain:0.6f];
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

#pragma mark WaveCleanup Collision Detection
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
#ifdef MYDEBUG
				NSLog(@"everything is idle");
#endif
				[sharedSoundManager_ playSoundWithKey:@"wave_end" gain:0.6f];
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
						[alien checkForCollisionWithEntity:player_];
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
			canPlayerFire_ = FALSE;
			if (bonus_.state_ == EntityState_Alive) {
				[sharedSoundManager_ stopSoundWithKey:@"active_bonus"];
			}
			switch (alienCount_) {
				case 46:
					[sharedSoundManager_ stopSoundWithKey:@"bg_4"];
					break;
				case 47:
					[sharedSoundManager_ stopSoundWithKey:@"bg_3"];
					break;
				case 48:
					[sharedSoundManager_ stopSoundWithKey:@"bg_2"];
					break;
				case 49:
					[sharedSoundManager_ stopSoundWithKey:@"bg_1"];
					break;
				default:
					[sharedSoundManager_ stopSoundWithKey:@"bg"];
					break;
			}
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
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				glClear(GL_COLOR_BUFFER_BIT);
			} else {
				[background_ renderAtPoint:CGPointMake(0, 0)];
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
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				glClear(GL_COLOR_BUFFER_BIT);
			} else {
				[background_ renderAtPoint:CGPointMake(0, 0)];
			}
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
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				glClear(GL_COLOR_BUFFER_BIT);
			} else {
				[background_ renderAtPoint:CGPointMake(0, 0)];
			}
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
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				glClear(GL_COLOR_BUFFER_BIT);
			} else {
				[background_ renderAtPoint:CGPointMake(0, 0)];
			}
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
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				glClear(GL_COLOR_BUFFER_BIT);
			} else {
				[background_ renderAtPoint:CGPointMake(0, 0)];
			}
			[smallFont_ renderStringJustifiedInFrame:screenBounds_
									   justification:BitmapFontJustification_TopCentered
												text:@"Game Over"];
			[smallFont_ renderStringJustifiedInFrame:screenBounds_
									   justification:BitmapFontJustification_MiddleCentered
												text:[NSString stringWithFormat:@"Score:%d		Wave:%d", score_, wave_]];
			if ([sharedGameController_.highScores count] < 10) {
				[smallFont_ renderStringJustifiedInFrame:screenBounds_
										   justification:BitmapFontJustification_BottomCentered
													text:@"Score is in top 10. Tap to enter Name."];
				[sharedImageRenderManager_ renderImages];
				return;
			} else {
				for (int i = 0; i < 10; ++i) {
					Score *s = [sharedGameController_.highScores objectAtIndex:i];
					if (score_ >= s.score_) {
						[smallFont_ renderStringJustifiedInFrame:screenBounds_
												   justification:BitmapFontJustification_BottomCentered
															text:@"Score is in top 10. Tap to enter Name."];
						[sharedImageRenderManager_ renderImages];
						return;
					}
				}
			}
			[smallFont_ renderStringJustifiedInFrame:screenBounds_
									   justification:BitmapFontJustification_BottomCentered
												text:@"Tap to continue."];
			[sharedImageRenderManager_ renderImages];
			break;

#pragma mark PlayerDeath
		case SceneState_PlayerDeath:
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				glClear(GL_COLOR_BUFFER_BIT);
			} else {
				[background_ renderAtPoint:CGPointMake(0, 0)];
			}
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
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				glClear(GL_COLOR_BUFFER_BIT);
			} else {
				[background_ renderAtPoint:CGPointMake(0, 0)];
			}
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
	[sharedSoundManager_ playSoundWithKey:@"aliens_landed" gain:0.6f];
	state_ = SceneState_GameOver;
}

- (void)bonusShipDestroyedWithPoints:(int)points {
	score_ += points;
	[self freeGuyCheck];
}

- (void)playerKilled {
	--playerLives_;
#ifdef MYDEBUG
	NSLog(@"player killed: %i lives left", playerLives_);
#endif
	state_ = SceneState_PlayerDeath;
}

- (void)alienKilledWithPosition:(int)position points:(int)points playerFlag:(bool)killedByPlayer {

	++alienCount_;
#ifdef MYDEBUG
	NSLog(@"%i", alienCount_);
#endif

	if (killedByPlayer) {
		[sharedSoundManager_ playSoundWithKey:@"explosion" gain:0.6f];
		--playerLives_;
#ifdef MYDEBUG
		NSLog(@"player killed: %i lives left", playerLives_);
#endif
		state_ = SceneState_PlayerDeath;
		if (alienCount_ >= 50) {
			[sharedSoundManager_ stopSoundWithKey:@"bg_1"];
		}
	} else {
		score_ += points;
		[self freeGuyCheck];
		[sharedSoundManager_ playSoundWithKey:@"alien_death" gain:0.075f];
		if (alienCount_ >= 50) {
			[sharedSoundManager_ stopSoundWithKey:@"bg_1"];
			if (state_ != SceneState_PlayerDeath) {
				state_ = SceneState_WaveOver;
			}
			return;
		}
	}

	for (Alien *alien in aliens_) {
		if (alien.position_ == position - 10) {
			alien.canFire_ = TRUE;
		}
		alien.dx_ *= 1.027f;
		switch (alienCount_) {
			case 46:
				alien.dx_ *= 1.15f;
				break;
			case 47:
				alien.dx_ *= 1.15f;
				break;
			case 48:
				alien.dx_ *= 1.15f;
				break;
			case 49:
				alien.dx_ *= 1.15f;
				break;
			default:
				break;
		}
	}
	switch (alienCount_) {
		case 46:
			[sharedSoundManager_ stopSoundWithKey:@"bg"];
			if (!killedByPlayer) {
				[sharedSoundManager_ playSoundWithKey:@"bg_4" gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:TRUE];
			}
#ifdef MYDEBUG
			NSLog(@"alienKilledWithPosition 46");
#endif
			break;
		case 47:
			[sharedSoundManager_ stopSoundWithKey:@"bg_4"];
			if (!killedByPlayer) {
				[sharedSoundManager_ playSoundWithKey:@"bg_3" gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:TRUE];
			}
#ifdef MYDEBUG
			NSLog(@"alienKilledWithPosition 47");
#endif
			break;
		case 48:
			[sharedSoundManager_ stopSoundWithKey:@"bg_3"];
			if (!killedByPlayer) {
				[sharedSoundManager_ playSoundWithKey:@"bg_2" gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:TRUE];
			}
#ifdef MYDEBUG
			NSLog(@"alienKilledWithPosition 48");
#endif
			break;
		case 49:
			[sharedSoundManager_ stopSoundWithKey:@"bg_2"];
			if (!killedByPlayer) {
				[sharedSoundManager_ playSoundWithKey:@"bg_1" gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:TRUE];
			}
#ifdef MYDEBUG
			NSLog(@"alienKilledWithPosition 49");
#endif
			break;
		default:
			break;
	}
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

	for (UITouch *touch in touches) {
        // Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:nil];

        // As we have the game in landscape mode we need to switch the touches
        // x and y coordinates
		CGPoint touchLocation = [sharedGameController_ adjustTouchOrientationForTouch:originalTouchLocation];

		if (state_ == SceneState_GameOver) {
			if ([sharedGameController_.highScores count] < 10) {
				[self getPlayerName];
				return;
			} else {
				for (int i = 0; i < 10; ++i) {
					Score *s = [sharedGameController_.highScores objectAtIndex:i];
					if (score_ >= s.score_) {
						[self getPlayerName];
						return;
					}
				}
			}
			[sharedGameController_ transitionToSceneWithKey:@"menu"];
		}

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
    state_ = SceneState_TransitionOut;
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
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			screenBounds_ = CGRectMake(0, 0, 1024, 768);
		} else {
			screenBounds_ = CGRectMake(0, 0, 480, 320);
		}
	}
    return self;
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	// First off grab a refernce to the textfield on the alert view.  This is done by hunting
	// for tag 99
	UITextField *nameField = (UITextField *)[alertView viewWithTag:99];

	// If the OK button is pressed then set the playersname
	NSString * playersName;
	if (buttonIndex == 1) {
		playersName = nameField.text;
		if ([playersName length] == 0)
			playersName = @"----------------------";

		// Save the games info to the high scores table only if a players name has been entered
		if (playersName) {
			[sharedGameController_ addToHighScores:score_ name:playersName wave:wave_];
		}
	}

	// We must remember to resign the textfield before this method finishes.  If we don't then an error
	// is reported e.g. "wait_fences: failed to receive reply:"
	[nameField resignFirstResponder];

	// Delete the old gamestate file
	[sharedGameController_ deleteGameState];

	[sharedGameController_ transitionToSceneWithKey:@"menu"];
}

@end


