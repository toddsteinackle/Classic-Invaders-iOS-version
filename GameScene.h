//
//  GameScene.h
//  SLQTSOR
//
//  Created by Michael Daley on 31/05/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "AbstractScene.h"

@class ImageRenderManager;
@class TextureManager;
@class SoundManager;
@class GameController;
@class AbstractEntity;
@class Image;
@class SpriteSheet;
@class Animation;
@class TiledMap;
@class BitmapFont;
@class ParticleEmitter;
@class Primatives;
@class Alien;
@class Alien2;
@class Alien3;
@class Player;
@class Shot;

// This class is the core game scene.  It is responsible for game rendering, logic, user
// input etc.
//
@interface GameScene : AbstractScene {

	//////////////////////// Singleton Classes
    ImageRenderManager *sharedImageRenderManager;	// Reference to the ImageRenderManager needed to render images
    TextureManager *sharedTextureManager;			// Reference to the TextureManager that allows for reuse of textures
    SoundManager *sharedSoundManager;				// Reference to the SoundManager that handles all sounds in the game
	GameController *sharedGameController;			// Reference to the GameController which handles global game state

	//////////////////////// Fonts
	BitmapFont *largeFont;							// Font used to display the loading message
	BitmapFont *smallFont;							// Font used for the HUD

	//////////////////////// Time Map
	TiledMap *castleTileMap;						// Tile map used in the game
	int screenTilesWide;							// Number of tiles to fill the screen width
	int screenTilesHeight;							// Number of tiles to fill the screen height
	int tileMapWidth, tileMapHeight;				// Width and height of the tilemap in tiles
    int bottomOffsetInTiles, leftOffsetInTiles;		// Number of tiles from the center of the screen to the bottom and left

	//////////////////////// Player
//    Player *player;									// Player
//	int playerTileX;								// Rounded x tile position
//	int playerTileY;								// Rounded y tile position
//	int playerTileOffsetX;							// Rounded number of x tiles to put player in the center of the screen
//	int playerTileOffsetY;							// Rounded number of x tiles to put player in the center of the screen
//	CGPoint playersLastLocation;					// Last location of the player so we can tell if they moved between updates

	//////////////////////// Arrays
	NSMutableArray *portals;						// Portal objects defined in the tile map
	NSMutableArray *gameObjects;					// Game objects defined in the tile map
	NSMutableArray *gameEntities;					// Entities running arounf the game
    NSMutableArray *doors;							// Doors defined in the tile map
	NSMutableArray *localDoors;						// Doors that are within a screens distance of the player
    //BOOL blocked[kMax_Map_Width][kMax_Map_Height];	// Collision map based on the collision layer in the tile map
													// If the map size changes then the constants in Global.h need to change

	//////////////////////// Axe
    //Axe *axe;										// The axe that is thrown by the player

	//////////////////////// Bounds
	CGRect pauseButtonBounds;						// Pausebutton image
	CGRect pickupButtonBounds;						// Holds the bounds used to check for a touch of the pause button
	CGRect invItem1Bounds;							// Inventory 1 button bounds
	CGRect invItem2Bounds;							// Inventory 2 button bounds
	CGRect invItem3Bounds;							// Inventory 3 button bounds
	CGRect joypadBounds;							// Bounds of the rectangle in which a touch is classed as activating the joypad
	CGRect firepadBounds;							// Bounds of the rectangle in which a touch is classed as activating the firepad
	CGRect settingsBounds;							// Bounds for the settings button
	CGRect exitBounds;								// If the player collides with this rectangle they have completed the game.  They
													// will only be able to collide with it if the main door is open and then walk through

	//////////////////////// Images/Sprite Sheets
	Image *healthBar;								// Bar that represents how much energy the player has
	Image *healthBarBackground;						// Image that is displayed behind the healthbar
	Image *playerHead;								// Used to display the number of lives left
	Image *grabButton;								// Pickup button
	Image *play;									// Play button in HUD
	Image *pause;									// Pause button in HUD
	Image *gameOver;								// Game over screen
	Image *torchMask;								// Alpha image placed over scene to look like torch light
	Image *fadeImage;								// Used to draw over the scene to fade it in and out
	Image *hud;										// HUD image used at the top of the screen
	Image *joypad;									// Image rendered for the joypad
	Image *settings;								// Gear image for the settings button
	Image *pauseButton;								// Holds the bounds used to check for a touch of the pickup/drop button
	Image *avatar[5];								// Array that holds the different avatars taken from the avatarSpriteSheet
	Image *pickupButton;							// Pickup/Drop button image
	Image *openMainDoor;							// Open main door rendered ontop of the tile map
	Image *closedMainDoor;							// As above just closed
	Image *gameComplete;							// Game completed image
	SpriteSheet *avatarSheet;						// Holds the different avatar images used for the player

	//////////////////////// Game ivars
	CFTimeInterval gameStartTime;					// Time the game started
	int gameMinutes, gameSeconds;					// Minutes and seconds calculated for game time
	CFTimeInterval timeSinceGameStarted;			// Amount of time since the game started in ms
	NSString *gameTimeToDisplay;					// Game time in MMM:SS format that is rendered in game
	int score;										// Game score
	CGPoint joypadCenter;							// Center of the joypad
	CGSize joypadRectangleSize;						// Height and Width of the joypad touch rectangle
	int joypadTouchHash;							// Holds the unique hash value given to a touch on the joypad.
													// This allows us to track the same touch during touchesMoved events
	CGPoint settingsButtonCenter;					// Center of the settings button
	CGSize settingsButtonSize;						// Height and Width of the settings button bounds
	NSString *playersName;							// Players name entered when they complete a game of die
	GLfloat musicVolume;							// Used to control the music volume for fading

	//////////////////////// Flags
	BOOL isJoypadTouchMoving;						// YES if a touch is being tracked for the joypad
	BOOL isPlayerOverObject;						// YES if the player is over a collectable object
	BOOL isLoadingScreenVisible;					// YES if the loading screen is visible
	BOOL isSceneInitialized;						// YES if the scene has been initialized
	BOOL isGameInitialized;							// YES if the game has been initialized
	BOOL isMainDoorOpen;							// YES if the main door is open
	BOOL isMusicFading;								// YES if music is being faded i.e. during a transition
	BOOL isLoseMusicPlaying;						// YES if the lose music is playing
	BOOL isWinMusicPlaying;							// YES if the win music is playing

    NSMutableArray *aliens_;
    Player *player_;
    Shot *shot_;
    Image *background_;
    CGRect leftTouchControlBounds_;
    CGRect rightTouchControlBounds_;
    CGRect fireTouchControlBounds_;
}

//@property (nonatomic, retain) TiledMap *castleTileMap;
//@property (nonatomic, retain) Player *player;
//@property (nonatomic, retain) NSMutableArray *doors;
@property (nonatomic, retain) NSMutableArray *gameEntities;
@property (nonatomic, retain) NSMutableArray *gameObjects;
//@property (nonatomic, retain) Axe *axe;
@property (nonatomic, assign) CFTimeInterval gameStartTime;
@property (nonatomic, assign) CFTimeInterval timeSinceGameStarted;
@property (nonatomic, assign) int score;
@property (nonatomic, retain) NSString *gameTimeToDisplay;

// Returns a boolean which identifies if the coordinates provided are on a blocked
// tile on the tilemap
//- (BOOL)isBlocked:(float)x y:(float)y;

// Sets the map location within the blocked array to the provided state
//- (void)setBlocked:(float)aX y:(float)aY blocked:(BOOL)aState;

// Checks all entities currently in the game to see if they are in the tilemap location
// file specified
//- (BOOL)isEntityInTileAtCoords:(CGPoint)aPoint;

// Saves the current state of the game to be resumed later
- (void)saveGameState;

- (void)initAliensWithSpeed:(int)alienSpeed chanceToFire:(int)chanceToFire;

@end
