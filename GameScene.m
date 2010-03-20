//
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

const float playerSpeed = 115;
bool isLeftTouchActive = FALSE;
bool isRightTouchActive = FALSE;

#pragma mark -
#pragma mark Private interface

@interface GameScene (Private)
// Initialize the sound needed for this scene
- (void)initSound;

// Initialize/reset the game
- (void)initScene;

// Sets up the game from the previously saved game.  If any of the data files are
// missing then the resume will not take place and the initial game state will be
// used instead
- (void)loadGameState;

// Initializes the games state
- (void)initNewGameState;

// Checks the game controller for the joypadPosition value. This is used to decide where the
// joypad should be rendered i.e. for left or right handed players.
//- (void)checkJoypadSettings;

// Initialize the game content e.g. tile map, collision array
- (void)initGameContent;

// Initializes portals defined in the tile map
//- (void)initPortals;

// Initializes items defined in the tile map
- (void)initItems;

// Initiaize the doors used in the map
//- (void)initCollisionMapAndDoors;

// Initializes the tile map
//- (void)initTileMap;

// Initializes the localDoor array before the update loop starts.  This means that doors will be
// rendered correctly when the scene fades in
//- (void)initLocalDoors;

// Calculate the players tile map location.  This inforamtion is used when rendering the tile map
// layers in the render method
//- (void)calculatePlayersTileMapLocation;

// Deallocates resources this scene has created
- (void)deallocResources;

@end

#pragma mark -
#pragma mark Public implementation

@implementation GameScene

//@synthesize castleTileMap;
//@synthesize player;
@synthesize gameEntities;
@synthesize gameObjects;
//@synthesize axe;
//@synthesize doors;
@synthesize gameStartTime;
@synthesize timeSinceGameStarted;
@synthesize score;
@synthesize gameTimeToDisplay;
@synthesize screenSidePadding_;

- (void)dealloc {

    // Remove observers that have been set up
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hidingSettings" object:nil];

	// Dealloc resources this scene has created
	[self deallocResources];

    [super dealloc];
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
	int x = 65;
	int y = 145;
	int hspace = 35;
	int vspace = 25;
	// create a block of aliens (5 rows, by 10 columns)
	for (int i = 0; i < 5; ++i) {
		for (int j = 0; j < 10; ++j) {
			switch (i) {
				case 0:
				{
					// initialize the bottom row of aliens to fire
					alien = [[Alien alloc] initWithPixelLocation:CGPointMake(x+(j*hspace), y+(i*vspace))
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
					alien = [[Alien alloc] initWithPixelLocation:CGPointMake(x+(j*hspace), y+(i*vspace))
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
					alien = [[Alien2 alloc] initWithPixelLocation:CGPointMake(x+(j*hspace), y+(i*vspace))
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
					alien = [[Alien3 alloc] initWithPixelLocation:CGPointMake(x+(j*hspace), y+(i*vspace))
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
- (id)init {

    if(self = [super init]) {

		// Name of this scene
        self.name = @"game";

        // Grab an instance of our singleton classes
        sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
        sharedTextureManager = [TextureManager sharedTextureManager];
        sharedSoundManager = [SoundManager sharedSoundManager];
        sharedGameController = [GameController sharedGameController];

        // Grab the bounds of the screen
        screenBounds = [[UIScreen mainScreen] bounds];

        // Set the scenes fade speed which is used when fading the scene in and out and also set
        // the default alpha value for the scene
//        fadeSpeed = 1.0f;
//        alpha = 0.0f;
//		musicVolume = 0.0f;

		// Add observations on notifications we are interested in.  When the settings view is hidden we
		// want to check to see if the joypad settings have changed.  For this reason we look for this
		// notification
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkJoypadSettings) name:@"hidingSettings" object:nil];

		int playerBaseHeight = 35;
		int touchBoxWidth = 65;
		aliens_ = [[NSMutableArray alloc] init];
		[self initAliensWithSpeed:0 chanceToFire:10];
		player_ = [[Player alloc] initWithPixelLocation:CGPointMake((screenBounds.size.height - (43*.85)) / 2, playerBaseHeight+1)];
		numberOfPlayerShots_ = 10;
		playerShots_ = [[NSMutableArray alloc] initWithCapacity:numberOfPlayerShots_];
		[self initPlayerShots];

		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png" controlFile:@"pss_coordinates" imageFilter:GL_LINEAR];
		background_ = [[pss imageForKey:@"background.png"] retain];

		leftTouchControlBounds_ = CGRectMake(1, 1, touchBoxWidth, playerBaseHeight);
		rightTouchControlBounds_ = CGRectMake(415, 1, touchBoxWidth, playerBaseHeight);
		fireTouchControlBounds_ = CGRectMake(touchBoxWidth+1, 1, 479-touchBoxWidth*2, playerBaseHeight);
		screenSidePadding_ = 20.0f;
		//NSLog(@"in init %f", screenSidePadding_);
    }

    return self;
}

- (void)initPlayerShots {
	for (int i = 0; i < numberOfPlayerShots_; ++i) {
		Shot *shot = [[Shot alloc] initWithPixelLocation:CGPointMake(0,0)];
		[playerShots_ addObject:shot];
	}
	//NSLog(@"%@", playerShots_);
}

#pragma mark -
#pragma mark Update scene logic

- (void)updateSceneWithDelta:(GLfloat)aDelta {

	for(Alien *alien in aliens_) {
		[alien updateWithDelta:aDelta scene:self];
		[alien movement:aDelta];
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
}

#pragma mark -
#pragma mark Tile map functions

//- (BOOL)isBlocked:(float)x y:(float)y {
//	// If we are asked for blocking information that is beyond the map border then by default
//	// return yes.  When the player is moving near the edge of the map coordinates may be passed
//	// that are beyond these bounds
//	if (x < 0 || y < 0 || x > kMax_Map_Width || y > kMax_Map_Height) {
//		return YES;
//	}
//
//	// Return the blocked status of the specified tile
//    return blocked[(int)x][(int)y];
//}
//
//- (void)setBlocked:(float)aX y:(float)aY blocked:(BOOL)aState {
//    blocked[(int)aX][(int)aY] = aState;
//}
//
//- (BOOL)isEntityInTileAtCoords:(CGPoint)aPoint {
//    // By default nothing is at the point provided
//    BOOL result = NO;
//
//    // Check to see if any of the entities are in the tile provided
//    for(AbstractEntity *entity in gameEntities) {
//        if([entity isEntityInTileAtCoords:aPoint]) {
//            result = YES;
//            break;
//        }
//    }
//
//    // Also check to see if the sword is in the tile provided
//    if([axe isEntityInTileAtCoords:aPoint])
//        result = YES;
//
//    return result;
//}

#pragma mark -
#pragma mark Touch events

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

	for (UITouch *touch in touches) {
        // Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:nil];
		//NSLog(@"x: %f", originalTouchLocation.x);
		//NSLog(@"y: %f", originalTouchLocation.y);

        // As we have the game in landscape mode we need to switch the touches
        // x and y coordinates
		CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation];

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

    // Loop through all the touches
	//for (UITouch *touch in touches) {
//
//		// If the scene is running then check to see if we have a running joypad touch
//        if (state == kSceneState_Running) {
//            if ([touch hash] == joypadTouchHash && isJoypadTouchMoving) {
//
//				// Get the point where the player has touched the screen
//                CGPoint originalTouchLocation = [touch locationInView:nil];
//
//                // As we have the game in landscape mode we need to switch the touches
//                // x and y coordinates
//				CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation];
//
//                // Calculate the angle of the touch from the center of the joypad
//                float dx = (float)joypadCenter.x - (float)touchLocation.x;
//                float dy = (float)joypadCenter.y - (float)touchLocation.y;
//
//				// Calculate the distance from the center of the joypad to the players touch using the manhatten
//				// distance algorithm
//				float distance = abs(touchLocation.x - joypadCenter.x) + abs(touchLocation.y - joypadCenter.y);
//
//                // Set the players joypadAngle causing the player to move in that direction
//                [player setDirectionWithAngle:atan2(dy, dx) speed:CLAMP(distance/4, 0, 8)];
//            }
//        }
//    }
}


- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

	for (UITouch *touch in touches) {
        // Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:nil];
		//NSLog(@"x: %f", originalTouchLocation.x);
		//NSLog(@"y: %f", originalTouchLocation.y);

        // As we have the game in landscape mode we need to switch the touches
        // x and y coordinates
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation];

		if (CGRectContainsPoint(fireTouchControlBounds_, touchLocation)) {
			NSLog(@"fire shot");
			[self playerFireShot];
		}

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

#pragma mark -
#pragma mark Alert View Delegates

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	// First off grab a refernce to the textfield on the alert view.  This is done by hunting
	// for tag 99
	UITextField *nameField = (UITextField *)[alertView viewWithTag:99];

	// If the OK button is pressed then set the playersname
	if (buttonIndex == 1) {
		playersName = nameField.text;
		if ([playersName length] == 0)
			playersName = @"No Name Given";

		// Save the games info to the high scores table only if a players name has been entered
		if (playersName) {
			BOOL won = NO;
			if (state == kSceneState_GameCompleted)
				won = YES;
			[sharedGameController addToHighScores:score gameTime:gameTimeToDisplay playersName:playersName didWin:won];
		}
	}

	// We must remember to resign the textfield before this method finishes.  If we don't then an error
	// is reported e.g. "wait_fences: failed to receive reply:"
	[nameField resignFirstResponder];

	// Delete the old gamestate file
	[sharedGameController deleteGameState];

	// Finally set the state to transition out of the scene
	state = kSceneState_TransitionOut;
}

#pragma mark -
#pragma mark Transition

- (void)transitionToSceneWithKey:(NSString*)theKey {
    state = kSceneState_TransitionOut;
}

- (void)transitionIn {
    state = kSceneState_TransitionIn;
}

#pragma mark -
#pragma mark Render scene

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

	[sharedImageRenderManager renderImages];
	drawBox(leftTouchControlBounds_);
	drawBox(rightTouchControlBounds_);
	drawBox(fireTouchControlBounds_);

	// If we are transitioning into the scene and we have initialized the scene then display the loading
	// screen.  This will be displayed until the rest of the game content has been loaded.
//	if (state == kSceneState_TransitionIn && isSceneInitialized) {
//		largeFont.fontColor = Color4fMake(1, 1, 1, 1);
//		[largeFont renderStringJustifiedInFrame:CGRectMake(0, 0, 480, 320) justification:BitmapFontJustification_MiddleCentered text:@"Entering Egremont Castle..."];
//		[sharedImageRenderManager renderImages];
//		isLoadingScreenVisible = YES;
//	}

	// Only render if the game has been initialized
//	if (isGameInitialized) {
//		switch (state) {
//
//			case kSceneState_Loading:
//			case kSceneState_TransitionOut:
//			case kSceneState_TransportingOut:
//			case kSceneState_TransportingIn:
//			case kSceneState_Paused:
//			case kSceneState_Running:
//			{
//			// Clear the screen before rendering
//			glClear(GL_COLOR_BUFFER_BIT);
//
//
//				// Save the current Matrix
//				glPushMatrix();
//
//				// Translate the world coordinates so that the player is rendered in the middle of the screen
//				glTranslatef(240 - (int)(player.tileLocation.x * kTile_Width),
//							 160 - (int)(player.tileLocation.y * kTile_Height), 0.0f);
//
//				// Render the Map tilemap layer
//				[castleTileMap renderLayer:0
//									  mapx:playerTileX - leftOffsetInTiles - 1
//									  mapy:playerTileY - bottomOffsetInTiles - 1
//									 width:screenTilesWide + 2
//									height:screenTilesHeight + 2
//							   useBlending:NO];
//
//				// Render the Objects tilemap layer
//				[castleTileMap renderLayer:1
//									  mapx:playerTileX - leftOffsetInTiles - 1
//									  mapy:playerTileY - bottomOffsetInTiles - 1
//									 width:screenTilesWide + 2
//									height:screenTilesHeight + 2
//							   useBlending:YES];
//
//				[sharedImageRenderManager renderImages];
//
//				// Render the players sword if its state is alive
//				if(axe.state == kEntityState_Alive)
//					[axe render];
//
//				// Render the game objects
//				for(AbstractObject *gameObject in gameObjects) {
//					if (gameObject.state == kObjectState_Active) {
//						[gameObject render];
//					}
//				}
//
//				// Render the player
//				[player render];
//				[myFirstAlien render];
//
//				// Render entities
//				for(AbstractEntity *entity in gameEntities) {
//					[entity render];
//				}
//
//				// Render what we have so far so that everything else rendered is drawn over it
//				[sharedImageRenderManager renderImages];
//
//				// Render the doors onto the map.  The localDoors array holds all doors
//				// that have been found to be close to the player during the scenes update
//				for (int index=0; index < [localDoors count]; index++) {
//					Door *door = [doors objectAtIndex:[[localDoors objectAtIndex:index] intValue]];
//					[door render];
//				}
//
//				// Render the portals
//				for(AbstractEntity *portal in portals) {
//					[portal render];
//				}
//
//				// Render the main door
//				if (isMainDoorOpen) {
//					[openMainDoor renderAtPoint:CGPointMake(3960, 80)];
//				} else {
//					[closedMainDoor renderAtPoint:CGPointMake(3960, 80)];
//				}
//
//				// Render all queued images at this point
//				[sharedImageRenderManager renderImages];
//
//				// Pop the old matrix off the stack ready for the next frame.  We need to make sure that the modelview
//				// is using the origin 0, 0 again so that the images for the HUD below are rendered in view.
//				glPopMatrix();
//
//				// Render the torch mask over the scene.  This is done behind the hud and controls
//				[torchMask renderCenteredAtPoint:CGPointMake(240, 160)];
//
//				// If we are transporting the player then the fade panel should be drawn under
//				// the HUD
//				if (state == kSceneState_TransportingIn || state == kSceneState_TransportingOut) {
//					[fadeImage renderAtPoint:CGPointMake(0, 0)];
//
//					// To make sure that this gets rendered UNDER the following images we need to get the
//					// render manager to render what is currently in the queue.
//					[sharedImageRenderManager renderImages];
//				}
//
//				// Render the hud background
//				[hud renderAtPoint:CGPointMake(0, 285)];
//
//				// Render the joypad
//				[joypad renderCenteredAtPoint:joypadCenter];
//
//				// Render the players avatar
//				if (player.energy > 80)
//					[avatar[0] renderAtPoint:CGPointMake(0, 285)];
//				else if (player.energy > 60)
//					[avatar[1] renderAtPoint:CGPointMake(0, 285)];
//				else if (player.energy > 40)
//					[avatar[2] renderAtPoint:CGPointMake(0, 285)];
//				else if (player.energy > 20)
//					[avatar[3] renderAtPoint:CGPointMake(0, 285)];
//				else if (player.energy > 0)
//					[avatar[4] renderAtPoint:CGPointMake(0, 285)];
//
//				// Render the players lives
//				CGPoint lifeLocation = CGPointMake(40, 290);
//				for (int lives=0; lives<3; lives++) {
//					if (lives >= player.lives) {
//						playerHead.color = Color4fMake(0, 0, 0, 0.35f);
//						[playerHead renderAtPoint:lifeLocation];
//						lifeLocation.x += 28;
//					} else {
//						playerHead.color = Color4fMake(1, 1, 1, 1);
//						[playerHead renderAtPoint:lifeLocation];
//						lifeLocation.x += 28;
//					}
//				}
//
//				// Render the health bar
//				[healthBarBackground renderAtPoint:CGPointMake(40, 310)];
//				[healthBar renderAtPoint:CGPointMake(40, 310)];
//
//				// Render inventory items
//				if (player.inventory1)
//					[player.inventory1 render];
//				if (player.inventory2)
//					[player.inventory2 render];
//				if (player.inventory3)
//					[player.inventory3 render];
//
//				// Render the pickup button
//				if (isPlayerOverObject) {
//					grabButton.color = Color4fMake(1, 0, 0, 1);
//				} else {
//					grabButton.color = Color4fMake(1, 1, 1, 1);
//				}
//				[grabButton renderCenteredAtPoint:CGPointMake(240, 25)];
//
//				// Render the settings button
//				[settings renderCenteredAtPoint:settingsButtonCenter];
//
//				// Render the score and game time
//				[smallFont renderStringJustifiedInFrame:CGRectMake(404, 280, 76, 35) justification:BitmapFontJustification_MiddleRight text:[NSString stringWithFormat:@"S:%06d", score]];
//				[smallFont renderStringJustifiedInFrame:CGRectMake(404, 295, 76, 35) justification:BitmapFontJustification_MiddleRight text:[NSString stringWithFormat:@"T: %@", gameTimeToDisplay]];
//
//				// Render the puse button
//				if (state == kSceneState_Running) {
//					[pause renderCenteredAtPoint:CGPointMake(386, 303)];
//				}
//
//				// If the game is paused then render a transparent quad over the game scene and the word
//				// paused in the middle.  Also render the play button rather than the pause button
//				if (state == kSceneState_Paused) {
//					fadeImage.color = Color4fMake(1, 1, 1, 0.55f);
//					[fadeImage renderCenteredAtPoint:CGPointMake(240, 160)];
//					[largeFont renderStringJustifiedInFrame:CGRectMake(0, 0, 480, 320) justification:BitmapFontJustification_MiddleCentered text:@"Paused"];
//					fadeImage.color = Color4fMake(1, 1, 1, 1);
//					[play renderCenteredAtPoint:CGPointMake(386, 303)];
//				}
//
//				// We only draw the black overlay when we are fading into or out of this scene
//				if (state == kSceneState_Loading || state == kSceneState_TransitionOut) {
//					[fadeImage renderAtPoint:CGPointMake(0, 0)];
//				}
//
//				// Render all queued images at this point
//				[sharedImageRenderManager renderImages];
//
//// Debug info
//#ifdef SCB
//				drawBox(pickupButtonBounds);
//				drawBox(invItem1Bounds);
//				drawBox(invItem2Bounds);
//				drawBox(invItem3Bounds);
//				drawBox(joypadBounds);
//				drawBox(settingsBounds);
//				drawBox(pauseButtonBounds);
//#endif
//				break;
//			}
//
//			case kSceneState_GameCompleted:
//			{
//				// Render the game complete background
//				[gameComplete renderCenteredAtPoint:CGPointMake(240, 160)];
//
//				// Render the game stats
//				CGRect textRectangle = CGRectMake(55, 42, 216, 160);
//				NSString *finalScore = [NSString stringWithFormat:@"%06d", score];
//				NSString *scoreStat = [NSString stringWithFormat:@"Final Score: %@", finalScore];
//				NSString *timeStat = [NSString stringWithFormat:@"Final Time: %@", gameTimeToDisplay];
//				[smallFont renderStringJustifiedInFrame:textRectangle justification:BitmapFontJustification_TopLeft text:scoreStat];
//				[smallFont renderStringJustifiedInFrame:textRectangle justification:BitmapFontJustification_MiddleLeft text:timeStat];
//				[sharedImageRenderManager renderImages];
//				break;
//			}
//
//			case kSceneState_GameOver:
//			{
//				// Render the game over background
//				[gameOver renderCenteredAtPoint:CGPointMake(240, 160)];
//
//				// Render the game stats
//				CGRect textRectangle = CGRectMake(55, 42, 216, 150);
//				NSString *finalScore = [NSString stringWithFormat:@"%06d", score];
//				NSString *scoreStat = [NSString stringWithFormat:@"Final Score: %@", finalScore];
//				NSString *timeStat = [NSString stringWithFormat:@"Final Time: %@", gameTimeToDisplay];
//				[smallFont renderStringJustifiedInFrame:textRectangle justification:BitmapFontJustification_TopLeft text:scoreStat];
//				[smallFont renderStringJustifiedInFrame:textRectangle justification:BitmapFontJustification_MiddleLeft text:timeStat];
//				[sharedImageRenderManager renderImages];
//				break;
//			}
//
//			default:
//				break;
//		}
//
//	}
}

#pragma mark -
#pragma mark Save game state

- (void)saveGameState {

//	SLQLOG(@"INFO - GameScene: Saving game state.");
//
//	// Set up the game state path to the data file that the game state will be saved too.
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	NSString *gameStatePath = [documentsDirectory stringByAppendingPathComponent:@"gameState.dat"];
//
//	// Set up the encoder and storage for the game state data
//	NSMutableData *gameData;
//	NSKeyedArchiver *encoder;
//	gameData = [NSMutableData data];
//	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:gameData];
//
//	// Archive the entities
//	[encoder encodeObject:gameEntities forKey:@"gameEntities"];
//
//	// Archive the player
//	[encoder encodeObject:player forKey:@"player"];
//
//	// Archive the players weapon
//	[encoder encodeObject:axe forKey:@"weapon"];
//
//	// Archive the games doors
//	[encoder encodeObject:doors forKey:@"doors"];
//
//	// Archive the game objects
//	[encoder encodeObject:gameObjects forKey:@"gameObjects"];
//
//	// Archive the games timer settings
//	NSNumber *savedGameStartTime = [NSNumber numberWithFloat:gameStartTime];
//	NSNumber *savedTimeSinceGameStarted = [NSNumber numberWithFloat:timeSinceGameStarted];
//	NSNumber *savedScore = [NSNumber numberWithFloat:score];
//	[encoder encodeObject:savedGameStartTime forKey:@"gameStartTime"];
//	[encoder encodeObject:savedTimeSinceGameStarted forKey:@"timeSinceGameStarted"];
//	[encoder encodeObject:savedScore forKey:@"score"];
//
//	// Finish encoding and write the contents of gameData to file
//	[encoder finishEncoding];
//	[gameData writeToFile:gameStatePath atomically:YES];
//	[encoder release];
//
//	// Tell the game controller that a resumed game is available
//	sharedGameController.resumedGameAvailable = YES;
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation GameScene (Private)

#pragma mark -
#pragma mark Initialize new game state

- (void)initNewGameState {

//	[self initGameContent];
//
//	// Set up the players initial locaiton
//	player = [[Player alloc] initWithTileLocation:CGPointMake(100, 6)];
//
//	// Now we have loaded the player we need to set up their position in the tilemap
//	[self calculatePlayersTileMapLocation];
//
//    // Create an instance of the sword which the player is going to through
//    axe = [[Axe alloc] initWithTileLocation:CGPointMake(0, 0)];
//
//    // Setup ghosts.  The value below defines the total number of ghosts that will spawn anywhere in
//    // the map.
//    for(int i=0; i<3;i++) {
//        Ghost *ghost = [[Ghost alloc] initWithTileLocation:CGPointMake(0, 0)];
//        [gameEntities addObject:ghost];
//        [ghost release];
//    }
//
//    for(int i=0; i<3;i++) {
//        Pumpkin *pumpkin = [[Pumpkin alloc] initWithTileLocation:CGPointMake(0, 0)];
//        [gameEntities addObject:pumpkin];
//        [pumpkin release];
//    }
//
//    for(int i=0; i<1;i++) {
//        Vampire *vampire = [[Vampire alloc] initWithTileLocation:CGPointMake(0, 0)];
//        [gameEntities addObject:vampire];
//        [vampire release];
//    }
//
//    for(int i=0; i<3;i++) {
//        Bat *bat = [[Bat alloc] initWithTileLocation:CGPointMake(0, 0)];
//        [gameEntities addObject:bat];
//        [bat release];
//    }
//
//    for(int i=0; i<3;i++) {
//        Zombie *zombie = [[Zombie alloc] initWithTileLocation:CGPointMake(0, 0)];
//        [gameEntities addObject:zombie];
//        [zombie release];
//    }
//
//    for(int i=0; i<3;i++) {
//        Witch *witch = [[Witch alloc] initWithTileLocation:CGPointMake(0, 0)];
//        [gameEntities addObject:witch];
//        [witch release];
//    }
//
//    for(int i=0; i<1;i++) {
//        Frank *frank = [[Frank alloc] initWithTileLocation:CGPointMake(0, 0)];
//        [gameEntities addObject:frank];
//        [frank release];
//    }
//
//	// Initialize the game items.  This is only done when initializing a new game as
//	// this information is loaded when a resumed game is started.
//	[self initItems];
//
//	// Init the localDoors array
//	[self initLocalDoors];
}


- (void)loadGameState {

//	[self initGameContent];
//
//    // Set up the file manager and documents path
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//
//    NSMutableData *gameData;
//    NSKeyedUnarchiver *decoder;
//
//    // Check to see if the ghosts.dat file exists and if so load the contents into the
//    // entities array
//    NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"gameState.dat"];
//    gameData = [NSData dataWithContentsOfFile:documentPath];
//
//    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:gameData];
//
//    SLQLOG(@"INFO - GameScene: Loading saved player data.");
//    player = [[decoder decodeObjectForKey:@"player"] retain];
//	[self calculatePlayersTileMapLocation];
//
//	SLQLOG(@"INFO - GameScene: Loading saved weapon data.");
//    axe = [[decoder decodeObjectForKey:@"weapon"] retain];
//
//	SLQLOG(@"INFO - GameScene: Loading saved entity data.");
//	if (gameEntities)
//		[gameEntities release];
//    gameEntities = [[decoder decodeObjectForKey:@"gameEntities"] retain];
//
//	SLQLOG(@"INFO - GameScene: Loading saved game object data.");
//	if (gameObjects)
//		[gameObjects release];
//	gameObjects = [[decoder decodeObjectForKey:@"gameObjects"] retain];
//
//	SLQLOG(@"INFO - GameScene: Loading saved door data.");
//	if (doors)
//		[doors release];
//    doors = [[decoder decodeObjectForKey:@"doors"] retain];
//
//	SLQLOG(@"INFO - GameScene: Loading saved game duration.");
//    timeSinceGameStarted = [[decoder decodeObjectForKey:@"timeSinceGameStarted"] floatValue];
//
//	SLQLOG(@"INGO - GameScene: Loading saved game score.");
//	score = [[decoder decodeObjectForKey:@"score"] floatValue];
//
//    SLQLOG(@"INFO - GameScene: Loading game time data.");
//
//	// We have finishd decoding the objects and retained them so we can now release the
//	// decoder object
//	[decoder release];
//
//	// Init the localDoors array
//	[self initLocalDoors];
}

- (void)initScene {

//	// Game objects
//	doors = [[NSMutableArray alloc] init];
//	gameEntities = [[NSMutableArray alloc] init];
//	portals = [[NSMutableArray alloc] init];
//	gameObjects = [[NSMutableArray alloc] init];
//	localDoors = [[NSMutableArray alloc] init];
//
//    // Get the master sprite sheet we are going to get all of our other graphical items from.  Having a single texture with all
//    // the graphics will help reduce the number of textures bound per frame and therefor performance
//    PackedSpriteSheet *masterSpriteSheet = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"atlas.png" controlFile:@"coordinates" imageFilter:GL_LINEAR];
//
//    // Initialize the fonts needed for the game
//    smallFont = [[BitmapFont alloc] initWithFontImageNamed:@"franklin16" ofType:@"png" controlFile:@"franklin16" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
//	largeFont = [[BitmapFont alloc] initWithFontImageNamed:@"bookAntiqua32" ofType:@"png" controlFile:@"bookAntiqua32" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
//
//    // In game GUI graphics
//    hud = [[masterSpriteSheet imageForKey:@"hudbar.png"] retain];
//	hud.color = Color4fMake(1, 1, 1, 0.25f);
//
//    // In game avatar that shows the players health
//    avatarSheet = [SpriteSheet spriteSheetForImage:[masterSpriteSheet imageForKey:@"UIface_horizontal.png"] sheetKey:@"UIface_horizontal.png" spriteSize:CGSizeMake(35, 35) spacing:0 margin:0];
//    avatar[0] = [avatarSheet spriteImageAtCoords:CGPointMake(0, 0)];
//    avatar[1] = [avatarSheet spriteImageAtCoords:CGPointMake(1, 0)];
//    avatar[2] = [avatarSheet spriteImageAtCoords:CGPointMake(2, 0)];
//    avatar[3] = [avatarSheet spriteImageAtCoords:CGPointMake(3, 0)];
//    avatar[4] = [avatarSheet spriteImageAtCoords:CGPointMake(4, 0)];
//
//	// Players lives image
//	playerHead = [[masterSpriteSheet imageForKey:@"playerHead.png"] retain];
//
//	// Main door images and exit rectangle
//	openMainDoor = [[masterSpriteSheet imageForKey:@"mainDoorOpen.png"] retain];
//	closedMainDoor = [[masterSpriteSheet imageForKey:@"mainDoorClosed.png"] retain];
//	exitBounds = CGRectMake(3960, 0, 80, 40);
//	gameComplete = [[Image alloc] initWithImageNamed:@"ending" ofType:@"png" filter:GL_LINEAR];
//
//    // In game pause button and pickup/drop buttons.  The bounds for the pickup/drop button
//	// are defined when checking the joypad as the button is calculated based on the location
//	// of the joypad
//	pickupButtonBounds = CGRectMake(200, 0, 75, 50);
//	invItem1Bounds = CGRectMake(155, 273, 50, 50);
//	invItem2Bounds = CGRectMake(215, 273, 50, 50);
//	invItem3Bounds = CGRectMake(275, 273, 50, 50);
//
//	// Play button
//	play = [[masterSpriteSheet imageForKey:@"play.png"] retain];
//	play.color = Color4fMake(1, 1, 1, 1);
//
//	// Pause button
//	pause = [[masterSpriteSheet imageForKey:@"pause.png"] retain];
//	pause.color = Color4fMake(0, 0, 0, 0.35f);
//    pauseButtonBounds = CGRectMake(360, 280, 50, 40);
//
//	// Settings button
//	settings = [[masterSpriteSheet imageForKey:@"gear.png"] retain];
//	settings.color = Color4fMake(1, 1, 1, 0.25f);
//	settingsButtonCenter = CGPointMake(430, 15);
//	settingsButtonSize = CGSizeMake(25, 25);
//
//    // In game torch overlay
//    torchMask = [[masterSpriteSheet imageForKey:@"torch.png"] retain];
//    [torchMask setColor:Color4fMake(1.0f, 1.0f, 1.0f, 1.0f)];
//
//    // Overlay used to fade the game scene
//    fadeImage = [[Image alloc] initWithImageNamed:@"allBlack" ofType:@"png" filter:GL_NEAREST];
//
//	// healthbar
//	healthBar = [[masterSpriteSheet imageForKey:@"healthbar.png"] retain];
//	healthBarBackground = [[healthBar imageCopy] retain];
//	[healthBar setImageSizeToRender:CGSizeMake(100, 75)];
//	[healthBarBackground setImageSizeToRender:CGSizeMake(100, 75)];
//	healthBarBackground.color = Color4fMake(0, 0, 0, 0.35);
//
//	// Grab button image
//	grabButton = [[masterSpriteSheet imageForKey:@"grabButton.png"] retain];
//
//    // Joypad setup
//	joypadCenter = CGPointMake(50, 50);
//	joypadRectangleSize = CGSizeMake(40, 40);
//
//    joypad = [[masterSpriteSheet imageForKey:@"joypad1.png"] retain];
//    joypad.color = Color4fMake(1.0f, 1.0f, 1.0f, 0.10f);
//
//	// Game Over & loading image
//	gameOver = [[Image alloc] initWithImageNamed:@"GameOver" ofType:@"png" filter:GL_LINEAR];
//
//	// Set up the game score and timers
//	score = 0;
//	timeSinceGameStarted = 0;
//    gameStartTime = CACurrentMediaTime();
//	gameTimeToDisplay = @"000.00";
//
//	// Set up flags
//	isWinMusicPlaying = NO;
//	isLoseMusicPlaying = NO;
//
//	// Set the players last position to 0 so that in the update method the local doors are calculated when the game
//	// first starts
//	playersLastLocation = CGPointMake(0,0);
}

- (void)initGameContent {
	// Initialize the scenes tile map
//	[self initTileMap];
//    [self initCollisionMapAndDoors];
//    [self initPortals];
}

- (void)initSound {

    // Set the listener to the middle of the screen by default.  This will be changed as the player moves around the map
    [sharedSoundManager setListenerPosition:CGPointMake(240, 160)];

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


- (void)checkJoypadSettings {

    // If the joypad is marked as being on the left the set the joypads center left, otherwise,
	// you guessed it, set the joypad center to the right.  This also adjusts the location of
	// the settings button which needs to also be moved
//	if (sharedGameController.joypadPosition == 0) {
//        joypadCenter.x = 50;
//		settingsButtonCenter.x = 465;
//		settingsBounds = CGRectMake(430, 0, 50, 50);
//    } else if (sharedGameController.joypadPosition == 1) {
//	    joypadCenter.x = 430;
//		settingsButtonCenter.x = 15;
//		settingsBounds = CGRectMake(0, 0, 50, 50);
//    }
//
//	// Calculate the rectangle that we check for touches to know someone has touched the joypad
//	joypadBounds = CGRectMake(joypadCenter.x - joypadRectangleSize.width,
//						joypadCenter.y - joypadRectangleSize.height,
//						joypadRectangleSize.width * 2,
//						joypadRectangleSize.height * 2);
}

- (void)initPortals {

//    // Get the object groups that were found in the tilemap
//    NSMutableDictionary *portalObjects = castleTileMap.objectGroups;
//
//    // Calculate the height of the tilemap in pixels.  We also add an extra tile to the height
//    // so that objects pixel location is correct.  This is needed as the tile map has a zero
//    // index which means we actually loose a tile when calculating a pixel position within the
//    // map
//    float tileMapPixelHeight = (kTile_Height * (castleTileMap.mapHeight - 1));
//
//    // Loop through all objects in the object group called Portals
//    NSMutableDictionary *objects = [[portalObjects objectForKey:@"Portals"] objectForKey:@"Objects"];
//    for (NSString *objectKey in objects) {
//
//        // Get the location of the portal
//        float portal_x = [[[[objects objectForKey:objectKey]
//                            objectForKey:@"Attributes"]
//                           objectForKey:@"x"] floatValue] / kTile_Width;
//
//        // As the tilemap coordinates have been reversed on the y-axis, we need to also reverse
//        // y-axis pixel locaiton for objects.  This is done by subtracting the objects current
//        // y value from the full pixel height of the tilemap
//        float portal_y = (tileMapPixelHeight - [[[[objects objectForKey:objectKey]
//                                                  objectForKey:@"Attributes"]
//                                                 objectForKey:@"y"] floatValue]) / kTile_Height;
//
//        // Get the location to where the portal will transport the player
//        float dest_x = [[[[objects objectForKey:objectKey]
//                          objectForKey:@"Properties"]
//                         objectForKey:@"dest_x"] floatValue];
//
//        float dest_y = [[[[objects objectForKey:objectKey]
//                          objectForKey:@"Properties"]
//                         objectForKey:@"dest_y"] floatValue];
//
//        // Create a portal instance and add it to the portals array
//        Portal *portal = [[Portal alloc] initWithTileLocation:CGPointMake(portal_x, portal_y) beamLocation:CGPointMake(dest_x, dest_y)];
//        portal.state = kEntityState_Alive;
//        [portals addObject:portal];
//        [portal release];
//        portal = nil;
//    }
}

- (void)initItems {
    // Get the object groups that were found in the tilemap
//    NSMutableDictionary *objectGroups = castleTileMap.objectGroups;
//
//    // Calculate the height of the tilemap in pixels.  All tile locations are zero indexed
//	// so we need to reduce the mapHeight by 1 to calculate the pixels correctly.
//    // so that objects pixel location is correct.
//    float tileMapPixelHeight = (kTile_Height * (castleTileMap.mapHeight - 1));
//
//    // Loop through all objects in the object group called Game Objects
//    NSMutableDictionary *objects = [[objectGroups objectForKey:@"Game Objects"] objectForKey:@"Objects"];
//
//    for (NSString *objectKey in objects) {
//
//        // Get the x location of the object
//        float object_x = [[[[objects objectForKey:objectKey]
//                            objectForKey:@"Attributes"]
//                           objectForKey:@"x"] floatValue] / kTile_Width;
//
//        // As the tilemap coordinates have been reversed on the y-axis, we need to also reverse
//        // y-axis pixel location for objects.  This is done by subtracting the objects current
//        // y value from the full pixel height of the tilemap
//        float object_y = (tileMapPixelHeight - [[[[objects objectForKey:objectKey]
//                                                  objectForKey:@"Attributes"]
//                                                 objectForKey:@"y"] floatValue]) / kTile_Height;
//
//        // Get the type of the object
//        uint type = [[[[objects objectForKey:objectKey]
//                          objectForKey:@"Attributes"]
//                         objectForKey:@"type"] intValue];
//
//        // Get the subtype of the object
//        uint subType = [[[[objects objectForKey:objectKey]
//                       objectForKey:@"Properties"]
//                      objectForKey:@"subtype"] intValue];
//
//        // Based on the type and subtype of the object in the map create the correct object instance
//        // and add it to the game objects array
//        switch (type) {
//            case kObjectType_Energy:
//            {
//				EnergyObject *object = [[EnergyObject alloc] initWithTileLocation:CGPointMake(object_x, object_y) type:type subType:subType];
//				[gameObjects addObject:object];
//				[object release];
//				break;
//            }
//
//            case kObjectType_Key:
//			{
//				KeyObject *key = [[KeyObject alloc] initWithTileLocation:CGPointMake(object_x, object_y) type:type subType:subType];
//				[gameObjects addObject:key];
//				[key release];
//                break;
//			}
//
//            case kObjectType_General:
//			{
//				switch (subType) {
//					case kObjectSubType_ParchmentTop:
//					case kObjectSubType_ParchmentMiddle:
//					case kObjectSubType_ParchmentBottom:
//					{
//						ParchmentObject *object = [[ParchmentObject alloc] initWithTileLocation:CGPointMake(object_x,object_y) type:type subType:subType];
//						[gameObjects addObject:object];
//						[object release];
//						break;
//					}
//
//					case kObjectSubType_Grave:
//					case kObjectSubType_TopLamp:
//					case kObjectSubType_LeftLamp:
//					case kObjectSubType_BottomLamp:
//					case kObjectSubType_RightLamp:
//					{
//						MapObject *object = [[MapObject alloc] initWithTileLocation:CGPointMake(object_x, object_y) type:type subType:subType];
//						[gameObjects addObject:object];
//						[object release];
//						break;
//					}
//
//					default:
//						break;
//				}
//             }
//
//            default:
//                break;
//        }
//    }
}

- (void)initTileMap {

    // Create a new instance of TiledMap
//    castleTileMap = [[TiledMap alloc] initWithFileName:@"slqtsor" fileExtension:@"tmx"];
//
//    // Grab the map width and height in tiles
//    tileMapWidth = [castleTileMap mapWidth];
//    tileMapHeight = [castleTileMap mapHeight];
//
//    // Calculate how many tiles it takes to fill the screen for width and height
//    screenTilesWide = screenBounds.size.height / kTile_Width;
//    screenTilesHeight = screenBounds.size.width / kTile_Height;
//
//    // The player is going to be in the middle of the screen, so calculate the offset in tiles from the player
//    // to the left edge and bottom of the screen.
//    bottomOffsetInTiles = screenTilesHeight / 2;
//    leftOffsetInTiles = screenTilesWide / 2;
}

- (void)initCollisionMapAndDoors {

    // Build a map of blocked locations within the tilemap.  This information is held on a layer called Collision
    // within the tilemap
//    SLQLOG(@"INFO - GameScene: Creating tilemap collision array and doors.");
//
//    // Grab the layer index for the layer in the tile map called Collision
//    int collisionLayerIndex = [castleTileMap layerIndexWithName:@"Collision"];
//    Door *door = nil;
//
//    // Loop through the map tile by tile
//    Layer *collisionLayer = [[castleTileMap layers] objectAtIndex:collisionLayerIndex];
//    for(int yy=0; yy < castleTileMap.mapHeight; yy++) {
//        for(int xx=0; xx < castleTileMap.mapWidth; xx++) {
//
//            // Grab the global tile id from the tile map for the current location
//            int globalTileID = [collisionLayer globalTileIDAtTile:CGPointMake(xx, yy)];
//
//            // If the global tile ID is the blocking tile image then this location is blocked.  If it is a door object
//            // then a door is created and placed in the doors array.  The value below is the tileid from the tileset used in the
//			// tile map.  If this tile is present in the collision layer then we mark that tile as blocked.
//            if(globalTileID == 160) {
//                blocked[xx][yy] = YES;
//            } else  {
//
//                // If the game is being resumed, then we do not need to load the doors array
//                if (!sharedGameController.shouldResumeGame) {
//                    // Check to see if the tileid for the current tile is a door tile.  If not then move on else check the type
//					// of the door and create a door instance.  If the tile map sprite sheet changes then these numbers need to be
//					// checked.  Also this assumes that the door tile are contiguous in the sprite sheet
//					if (globalTileID >= 162 && globalTileID <= 195) {
//						int doorType = [[castleTileMap tilePropertyForGlobalTileID:globalTileID key:@"type" defaultValue:@"-1"] intValue];
//						if (doorType != -1) {
//							// Create a new door instance of the correct type.  As we create the door we set the doors array
//							// index to be its index in the doors array.  At this point we have not actually added the door to
//							// the array so we can use the current array count which will give us the correct number
//							door = [[Door alloc] initWithTileLocation:CGPointMake(xx, yy) type:doorType arrayIndex:[doors count]];
//							[doors addObject:door];
//							[door release];
//						}
//					}
//                }
//            }
//        }
//    }
//	SLQLOG(@"INFO - GameScene: Finished constructing collision array and doors.");
}

- (void)calculatePlayersTileMapLocation {
	// Round the players tile location
//	playerTileX = (int) player.tileLocation.x;
//    playerTileY = (int) player.tileLocation.y;
//
//    // Calculate the players tile x and y offset.  This allows us to keep the player in the middle of
//	// the screen and have the map render correctly under the player.  This information is used when
//	// rendering the tile map layers in the render method
//	playerTileOffsetX = (int) ((playerTileX - player.tileLocation.x) * kTile_Width);
//    playerTileOffsetY = (int) ((playerTileY - player.tileLocation.y) * kTile_Height);
//}
//
//- (void)initLocalDoors {
//	// Calculate the tile bounds around the player. We clamp the possbile values to between
//	// 0 and the width/height of the tile map.  We remove 1 from the width and height
//	// as the tile map is zero indexed in the game.  These values can then be used when
//	// checking if objects, portals or doors should be updated
//	int minScreenTile_x = CLAMP(player.tileLocation.x - 8, 0, kMax_Map_Width-1);
//	int maxScreenTile_x = CLAMP(player.tileLocation.x + 8, 0, kMax_Map_Width-1);
//	int minScreenTile_y = CLAMP(player.tileLocation.y - 6, 0, kMax_Map_Height-1);
//	int maxScreenTile_y = CLAMP(player.tileLocation.y + 6, 0, kMax_Map_Height-1);
//
//	// Populate the localDoors array with any doors that are found around the player.  This allows
//	// us to reduce the number of doors we are rendering and updating in any single frame.  We only
//	// perform this check if the player has moved from one tile to another on the tile map to save cycles
//	if ((int)player.tileLocation.x != (int)playersLastLocation.x || (int)player.tileLocation.y != (int)playersLastLocation.y) {
//
//		// Clear the localDoors array as we are about to populate it again based on the
//		// players new position
//		[localDoors removeAllObjects];
//
//		// Find doors that are close to the player and add them to the localDoors loop.  Layer 3 in the
//		// tile map holds the door information
//		Layer *layer = [[castleTileMap layers] objectAtIndex:2];
//		for (int yy=minScreenTile_y; yy < maxScreenTile_y; yy++) {
//			for (int xx=minScreenTile_x; xx < maxScreenTile_x; xx++) {
//
//				// If the value property for this tile is not -1 then this must be a door and
//				// we should add it to the localDoors array
//				if ([layer valueAtTile:CGPointMake(xx, yy)] > -1) {
//					int index = [layer valueAtTile:CGPointMake(xx, yy)];
//					[localDoors addObject:[NSNumber numberWithInt:index]];
//				}
//			}
//		}
//	}
}

- (void)deallocResources {

	// Release the images
	[fadeImage release];
	[gameOver release];
	[gameComplete release];
	[pauseButton release];
	[pickupButton release];
	[torchMask release];
	[openMainDoor release];
	[closedMainDoor release];
	[hud release];
	[healthBar release];
	[healthBarBackground release];
	[joypad release];
	[play release];
	[pause release];

	// Release fonts
	[smallFont release];
	[largeFont release];

	// Release game entities
	[doors release];
	[gameEntities release];
	//	[axe release];
	[localDoors release];
	[gameObjects release];
	[portals release];
	[castleTileMap release];

	//	[player release];
	[aliens_ release];
	[background_ release];

	// Release sounds
	[sharedSoundManager removeSoundWithKey:@"doorSlam"];
	[sharedSoundManager removeSoundWithKey:@"doorOpen"];
	[sharedSoundManager removeSoundWithKey:@"pop"];
	[sharedSoundManager removeSoundWithKey:@"hitWall"];
	[sharedSoundManager removeSoundWithKey:@"eatfood"];
	[sharedSoundManager removeSoundWithKey:@"scream"];
	[sharedSoundManager removeSoundWithKey:@"spell"];
	[sharedSoundManager removeMusicWithKey:@"ingame"];
	[sharedSoundManager removeMusicWithKey:@"winIntro"];
	[sharedSoundManager removeMusicWithKey:@"winLoop"];
	[sharedSoundManager removeMusicWithKey:@"loseIntro"];
	[sharedSoundManager removeMusicWithKey:@"loseLoop"];
	[sharedSoundManager removePlaylistNamed:@"win"];
	[sharedSoundManager removePlaylistNamed:@"lose"];
}
@end

