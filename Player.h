//
//  Player.h
//  Tutorial1
//
//  Created by Michael Daley on 14/06/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "AbstractEntity.h"

@class GameController;
@class AbstractObject;

@interface Player : AbstractEntity {
	
	//////////////////// Animation
    Animation *leftAnimation;
    Animation *rightAnimation;
    Animation *downAnimation;
    Animation *upAnimation;
    Animation *currentAnimation;
	
	///////////////// Instance variables
    float playerSpeed;			// Speed at which the player moves
	float energy;				// Energy level of the player
	float angleOfMovement;		// Angle at which the player will move
	float speedOfMovement;		// Speed accelerator added to the players speed.  Provided by the joypad
	float energyTimer;			// Increments over time to reduce players energy steadily
	float deathTimer;			// Increments over time to time how long the player should stay dead
	int lives;					// Number of player lives
	float stayDeadTime;			// How long the player should stay dead before reappearing
	CGPoint beamLocation;		// Location to which the player is being beamed by a portal
	
	///////////////// Inventory
	AbstractObject *inventory1, *inventory2, *inventory3;	// Reference to Objects held in the players inventory
	
	///////////////// Flags
	BOOL hasParchmentTop, hasParchmentMiddle, hasParchmentBottom; // A flag for each parchment piece collected
}

@property (nonatomic, assign) float angleOfMovement;
@property (nonatomic, assign) float speedOfMovement;
@property (nonatomic, assign) float energy;
@property (nonatomic, assign) int lives;
@property (nonatomic, assign) CGPoint beamLocation;
@property (nonatomic, retain) AbstractObject *inventory1;
@property (nonatomic, retain) AbstractObject *inventory2;
@property (nonatomic, retain) AbstractObject *inventory3;
@property (nonatomic, assign) BOOL hasParchmentTop;
@property (nonatomic, assign) BOOL hasParchmentMiddle;
@property (nonatomic, assign) BOOL hasParchmentBottom;

// Creates an instance of the player class with the given tilemap location
- (id)initWithTileLocation:(CGPoint)aLocation;

// Sets the player direction and speed.  This information is provided by the joypad
- (void)setDirectionWithAngle:(float)aAngle speed:(float)aSpeed;

// Adds the supplied object to the players inventory
- (void)placeInInventoryObject:(AbstractObject*)aObject;

// Drops the selected inventory item
- (void)dropInventoryFromSlot:(int)aInventorySlot;

// Checks to see if the object passed in has collided with the player and if so takes
// the necessary action
- (void)checkForCollisionWithObject:(AbstractObject*)aObject;

// Checks to see if the entity passed in has collided with the player and if so takes
// the necessary action
- (void)checkForCollisionWithEntity:(AbstractEntity*)aEntity;

@end
