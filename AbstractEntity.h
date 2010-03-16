//
//  AbstractEntity.h
//  SLQTSOR
//
//  Created by Michael Daley on 04/03/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "Global.h"
#import "GameController.h"
#import "SoundManager.h"
#import "GameScene.h"

@class AbstractScene;
@class Image;
@class SpriteSheet;
@class Animation;
@class GameScene;
@class BitmapFont;
@class AbstractEntity;
@class AbstractObject;

@interface AbstractEntity : NSObject <NSCoding> {

	/////////////////// Singleton Managers
    SoundManager *sharedSoundManager;			// Sound Manager
    GameController *sharedGameController;		// Game Controller

	////////////////// Images
	Image *image;								// Base entity image
	SpriteSheet *spriteSheet;                   // Holds the animation frames we are going to be using for this entity
    Animation *animation;                       // Animation for this entity

	///////////////// Entity location
	CGPoint tileLocation;						// Entities location in tile map tiles
	CGPoint pixelLocation;						// Entities position in pixels

	///////////////// Entity state/ivars
	GameScene *scene;							// Reference to the game scene
	uint state;									// Entities state
	float energyDrain;							// Amount of energy to drain from the player when they hit this entity
    float speed;								// Speed at which the entity will move
    float angle;								// Angle at which entity will move
	ParticleEmitter *dyingEmitter;				// Particle emitter used when the entity dies
	ParticleEmitter *appearingEmitter;			// Particle emitter used when the entity appears
	float offScreenTimer;						// Used to calculate how long the entity has been off the screen
	float appearingTimer;						// Used to calculate how long the entity has been appearing for
	float distanceFromPlayer;					// Distance the entity is from the player in tiles

    float dx, dy;                               // velocity -- speed in pixels/sec and direction
    bool active;
    int coll_w, coll_h, coll_x_offset, coll_y_offset;
}

@property (nonatomic, readonly) Image *image;
@property (nonatomic, readonly) float energyDrain;
@property (nonatomic, readonly) CGPoint pixelLocation;

@property (nonatomic, assign) CGPoint tileLocation;
@property (nonatomic, assign) uint state;
@property (nonatomic, assign) bool active;

// Designated initializer which allows this actor to be placed on the tilemap using a
// tilemap grid locations.
- (id)initWithTileLocation:(CGPoint)aLocation;

- (id)initWithLocation:(CGPoint)aLocation;

// Selector that updates the entities logic i.e. location, collision status etc
- (void)updateWithDelta:(float)aDelta scene:(AbstractScene*)aScene;

// Selector that renders the entity
- (void)render;

// Check to see if any corners of the entities bounds are in the tile location
// provided
- (BOOL)isEntityInTileAtCoords:(CGPoint)aCoords;

// Returns a CGRect which defines the movement bounds of the entity.  The movement bounds are
// used then the entity moves on the map when checking if the the entity has entered a blocked
// map tile. This method must be subclassed so that an actual CGRect and be returned.
// By default a zero sized CGRect is returned.
- (CGRect)movementBounds;

// Returns a CGRect which defines the collision bounds of the entity.  These bounds are used when
// checking of the entity has collided with another entity.  This allows the tile map collision bounds
// to be different from the movement collision bounds allowing for a more realistic collision between
// entities.  This also helps when an entity is animated.
- (CGRect)collisionBounds;

// Returns an array of floats that hold the bounding rectangles vertices in
// tile coordinates rather than pixel coordinates.  Defined as a C function as
// its called a lot so this helps reduce the messaging overhead Objective-C introduces
BoundingBoxTileQuad getTileCoordsForBoundingRect(CGRect aRect, CGSize aTileSize);

// Checks to see if the entity has collided with the entity passed in.  This method is
// subclassed to provide the entity specific functions that should be carried out when
// checking for and identifying a collision with another entity
- (void)checkForCollisionWithEntity:(AbstractEntity*)aEntity;

// Checks to see if the entity has collided with the object passed in.  This method is
// subclassed to provide the entity specific functions that should be carried out when
// checking for and identifying a collision with an object
- (void)checkForCollisionWithObject:(AbstractObject*)aObject;

@end
