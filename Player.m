//
//  Player.m
//  Tutorial1
//
//  Created by Michael Daley on 14/06/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "GameController.h"
#import "SoundManager.h"
#import "Player.h"
#import "Ghost.h"
#import "Witch.h"
#import "Vampire.h"
#import "Bat.h"
#import "Pumpkin.h"
#import "Frank.h"
#import "Zombie.h"
#import "GameScene.h"
#import "Image.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "Primatives.h"
#import "BitmapFont.h"
#import "PackedSpriteSheet.h"
#import "AbstractObject.h"
#import "MapObject.h"
#import "EnergyObject.h"

#pragma mark -
#pragma mark Private implementation

@interface Player (Private)
// Updates the players location with the given delta
- (void)updateLocationWithDelta:(float)aDelta;

// Checks to see if the supplied object is part of the parchment
- (void)checkForParchment:(AbstractObject*)aObject pickup:(BOOL)aPickup;
@end

#pragma mark -
#pragma mark Public implementation

@implementation Player

@synthesize angleOfMovement;
@synthesize speedOfMovement;
@synthesize energy;
@synthesize lives;
@synthesize beamLocation;
@synthesize inventory1;
@synthesize inventory2;
@synthesize inventory3;
@synthesize hasParchmentTop;
@synthesize hasParchmentMiddle;
@synthesize hasParchmentBottom;

- (void)dealloc {
    [leftAnimation release];
    [rightAnimation release];
    [downAnimation release];
    [upAnimation release];
    [super dealloc];
}

#pragma mark -
#pragma mark Init

- (id)initWithTileLocation:(CGPoint)aLocation {
    self = [super init];
	if (self != nil) {
		
		// The players position is held in terms of tiles on the map
        tileLocation.x = aLocation.x;
        tileLocation.y = aLocation.y;
		
		// Set up the initial pixel position based on the players tile position
		pixelLocation = tileMapPositionToPixelPosition(tileLocation);
		
        // Set up the spritesheets that will give us out player animation
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"atlas.png" controlFile:@"coordinates" imageFilter:GL_LINEAR];
		Image *embededSpriteSheetImage = [[pss imageForKey:@"spritesheet_lamorak2.png"] retain];

		spriteSheet = [SpriteSheet spriteSheetForImage:embededSpriteSheetImage sheetKey:@"spritesheet_lamorak.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];

        // Set up the animations for our player for different directions
        leftAnimation = [[Animation alloc] init];
        rightAnimation = [[Animation alloc] init];
        downAnimation = [[Animation alloc] init];
		upAnimation = [[Animation alloc] init];
        
		// Delay to be used between frames in the players animation
        float animationDelay = 0.1f;
        
        // Right animation
		[rightAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 2)] delay:animationDelay];
		[rightAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 2)] delay:animationDelay];
		[rightAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 2)] delay:animationDelay];
		[rightAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(3, 2)] delay:animationDelay];
		[rightAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:animationDelay];
		rightAnimation.type = kAnimationType_Repeating;
		rightAnimation.state = kAnimationState_Running;
		rightAnimation.bounceFrame = 4;
        
        // Left animation
		[leftAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 3)] delay:animationDelay];
		[leftAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 3)] delay:animationDelay];
		[leftAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 3)] delay:animationDelay];
		[leftAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(3, 3)] delay:animationDelay];
		[leftAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 3)] delay:animationDelay];
		leftAnimation.type = kAnimationType_Repeating;
		leftAnimation.state = kAnimationState_Running;
		leftAnimation.bounceFrame = 4;
        
        // Down animation
		[downAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:animationDelay];
		[downAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:animationDelay];
		[downAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:animationDelay];
		[downAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(3, 0)] delay:animationDelay];
		[downAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:animationDelay];
		downAnimation.type = kAnimationType_Repeating;
		downAnimation.state = kAnimationState_Running;
		downAnimation.bounceFrame = 4;
        
        // Up animation
		[upAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 1)] delay:animationDelay];
		[upAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 1)] delay:animationDelay];
		[upAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 1)] delay:animationDelay];
		[upAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(3, 1)] delay:animationDelay];
		[upAnimation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:animationDelay];
		upAnimation.type = kAnimationType_Repeating;
		upAnimation.state = kAnimationState_Running;
		upAnimation.bounceFrame = 4;
		
		[embededSpriteSheetImage release];
        
        // Set the default animation to be facing the right with the selected frame
        // showing the player standing
        currentAnimation = rightAnimation;
        [currentAnimation setCurrentFrame:4];
        
        // Speed at which the player moves
        playerSpeed = 0.5f;
        
        // Set the players state to alive
        state = kEntityState_Alive;
		
		// Default player values
		energy = 100;
		lives = 3;

		// Number of seconds the player stays dead before reappearing
		stayDeadTime = 4;
		deathTimer = 0;
		
		// Init the parchment flags
		hasParchmentTop = NO;
		hasParchmentMiddle = NO;
		hasParchmentBottom = NO;
    }
    return self;
}

#pragma mark -
#pragma mark Update

- (void)updateWithDelta:(GLfloat)aDelta scene:(GameScene*)aScene {

    // Check the state of the player and update them accordingly
    switch (state) {
        case kEntityState_Alive:
            // Update the players position
            [self updateLocationWithDelta:aDelta];
			
			// Update the players energy.  The energy is always dropping even when the 
			// player is not doing anything.
			energyTimer += aDelta;
			if (energyTimer > 3) {
				energy -= 2;
				energyTimer = 0;
			}
			
			// If the players energy reaches 0 then set their state to
			// dead
			if (energy <= 0) {
				state = kEntityState_Dead;
				
				// Set the energy to 0 else a small amount of energy could be left
				// showing even though the player is dead
				energy = 0;
				
				// As the player is dead we need to add a grave stone to the gameObejcts  array in
				// the game scene
				MapObject *grave = [[MapObject alloc] initWithTileLocation:tileLocation type:kObjectType_General subType:kObjectSubType_Grave];
				[aScene.gameObjects addObject:grave];
				[grave release];
				
				// Reduce the number of lives the player has.  If the player is then below the minimum number of lives
				// they are dead, for good, so we set the game scene state to game over.
				lives -= 1;
				if (lives < 1) {
					aScene.state = kSceneState_GameOver;
				}
				
				// The player has died so play a suitable scream
				[sharedSoundManager playSoundWithKey:@"scream" location:pixelLocation];
			}
            break;
			
		case kEntityState_Dead:

			// The player should stay dead for the time defined in stayDeadTime.  After this time has passed
			// the players state is set back to alive and their energy is reset
			deathTimer += aDelta;
			if (deathTimer >= stayDeadTime) {
				deathTimer = 0;
				state = kEntityState_Alive;
				energy = 100;
			}
			break;
			
        default:
            break;
    }

}

- (void)setState:(uint)aState {
	state = aState;
}

#pragma mark -
#pragma mark Render

- (void)render {

	if (state == kEntityState_Alive) {
		[super render];
		[currentAnimation renderCenteredAtPoint:CGPointMake((int)pixelLocation.x, (int)pixelLocation.y)];
	}
}

#pragma mark -
#pragma mark Bounds & Collision

- (CGRect)movementBounds { 
	// Calculate the pixel position and return a CGRect that defines the bounds
	pixelLocation = tileMapPositionToPixelPosition(tileLocation);
	return CGRectMake(pixelLocation.x - 15, pixelLocation.y - 19, 30, 37);
}

- (CGRect)collisionBounds {
	// Calculate the pixel position and return a CGRect that defines the bounds
	pixelLocation = tileMapPositionToPixelPosition(tileLocation);
	return CGRectMake(pixelLocation.x - 10, pixelLocation.y - 20, 20, 35);
}

- (void)checkForCollisionWithEntity:(AbstractEntity*)aEntity {
	
	if (CGRectIntersectsRect([self collisionBounds], [aEntity collisionBounds])) {
		if(([aEntity isKindOfClass:[Ghost class]] ||
		   [aEntity isKindOfClass:[Frank class]] ||
		   [aEntity isKindOfClass:[Witch class]] ||
		   [aEntity isKindOfClass:[Pumpkin class]] ||
		   [aEntity isKindOfClass:[Bat class]] ||
		   [aEntity isKindOfClass:[Vampire class]] ||
		   [aEntity isKindOfClass:[Zombie class]]) && state == kEntityState_Alive) {
			energy -= aEntity.energyDrain;
		}
	}
}

- (void)checkForCollisionWithObject:(AbstractObject*)aObject {
		
	if (CGRectIntersectsRect([self collisionBounds], [aObject collisionBounds])) {
		if ([aObject isKindOfClass:[EnergyObject class]]) {
					energy += aObject.energy;
					if (energy > 100) {
						energy = 100;
					}
		}
	}
}


#pragma mark -
#pragma mark Inventory

- (void)placeInInventoryObject:(AbstractObject*)aObject {
	
	if (aObject.state == kObjectState_Active) {
		if (!self.inventory1) {
			self.inventory1 = aObject;
			aObject.state = kObjectState_Inventory;
			aObject.isCollectable = NO;
			aObject.pixelLocation = CGPointMake(180, 303);
			[self checkForParchment:aObject pickup:YES];
		} else if (!self.inventory2) {
			aObject.state = kObjectState_Inventory;
			aObject.isCollectable = NO;
			aObject.pixelLocation = CGPointMake(240, 303);
			self.inventory2 = aObject;
			[self checkForParchment:aObject pickup:YES];
		} else if (!self.inventory3) {
			aObject.state = kObjectState_Inventory;
			aObject.isCollectable = NO;
			aObject.pixelLocation = CGPointMake(300, 303);
			self.inventory3 = aObject;
			[self checkForParchment:aObject pickup:YES];
		}
	}
}

- (void)dropInventoryFromSlot:(int)aInventorySlot {

	AbstractObject *invObject = nil;
	
	// Associate the dropped inventory item to invObject
	if (aInventorySlot == 0) {
		invObject = self.inventory1;
	} else if (aInventorySlot == 1) {
		invObject = self.inventory2;
	} else if (aInventorySlot == 2) {
		invObject = self.inventory3;
	}
	
	// Change the properties of invObject so that the object is placed
	// back into the map
	if (invObject) {
		invObject.pixelLocation = pixelLocation;
		invObject.tileLocation = tileLocation;
		invObject.state = kObjectState_Active;
	}
	
	// Empty the inventory slot
	if (aInventorySlot == 0) {
		self.inventory1 = nil;
	} else if (aInventorySlot == 1) {
		self.inventory2 = nil;
	} else if (aInventorySlot == 2) {
		self.inventory3 = nil;
	}
	
	// Check to see if we have just dropped a parchment piece
	[self checkForParchment:invObject pickup:NO];
}

#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	// Initialize the player
	[self initWithTileLocation:CGPointMake(0, 0)];
	
	// Load in the important variables from the decoder
	self.tileLocation = [aDecoder decodeCGPointForKey:@"position"];
	self.angleOfMovement = [aDecoder decodeFloatForKey:@"directionAngle"];
	self.energy = [aDecoder decodeFloatForKey:@"energy"];
	self.lives = [aDecoder decodeFloatForKey:@"lives"];
	self.inventory1 = [aDecoder decodeObjectForKey:@"inventory1"];
	self.inventory2 = [aDecoder decodeObjectForKey:@"inventory2"];
	self.inventory3 = [aDecoder decodeObjectForKey:@"inventory3"];
	
	// Set up the initial pixel position based on the players tile position
	pixelLocation = tileMapPositionToPixelPosition(tileLocation);
	
	// Make sure that the inventory items are rotated correctly.

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	// Encode the important variables to save the players state
	[aCoder encodeCGPoint:tileLocation forKey:@"position"];
	[aCoder encodeFloat:angleOfMovement forKey:@"directionAngle"];
	[aCoder encodeFloat:energy forKey:@"energy"];
	[aCoder encodeFloat:lives forKey:@"lives"];
	[aCoder encodeObject:inventory1 forKey:@"inventory1"];
	[aCoder encodeObject:inventory2 forKey:@"inventory2"];
	[aCoder encodeObject:inventory3 forKey:@"inventory3"];
}

#pragma mark -
#pragma mark Setters

- (void)setDirectionWithAngle:(float)aAngle speed:(float)aSpeed {
	self.angleOfMovement = aAngle;
	self.speedOfMovement = aSpeed;
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation Player (Private)

- (void)updateLocationWithDelta:(float)aDelta {
    
	// Holds the bounding box verticies in tile map coordinates
	BoundingBoxTileQuad bbtq;
	
	CGPoint oldPosition = tileLocation;
	if (speedOfMovement != 0) {
		
		// Move the player in the x-axis based on the angle of the joypad
		tileLocation.x -= (aDelta * (playerSpeed * speedOfMovement)) * cosf(angleOfMovement);
		
		// Check to see if any of the players bounds are in a blocked tile.  If they are
		// then set the x location back to its original location
		CGRect bRect = [self movementBounds];
		bbtq = getTileCoordsForBoundingRect(bRect, CGSizeMake(kTile_Width, kTile_Height));
		if ([scene isBlocked:bbtq.x1 y:bbtq.y1] ||
			[scene isBlocked:bbtq.x2 y:bbtq.y2] ||
			[scene isBlocked:bbtq.x3 y:bbtq.y3] ||
			[scene isBlocked:bbtq.x4 y:bbtq.y4]) {
			tileLocation.x = oldPosition.x;
		}
		
		// Move the player in the y-axis based on the angle of the joypad
		tileLocation.y -= (aDelta * (playerSpeed * speedOfMovement)) * sinf(angleOfMovement);
		
		// Check to see if any of the players bounds are in a blocked tile.  If they are
		// then set the x location back to its original location
		bRect = [self movementBounds];
		bbtq = getTileCoordsForBoundingRect(bRect, CGSizeMake(kTile_Width, kTile_Height));
		if ([scene isBlocked:bbtq.x1 y:bbtq.y1] ||
			[scene isBlocked:bbtq.x2 y:bbtq.y2] ||
			[scene isBlocked:bbtq.x3 y:bbtq.y3] ||
			[scene isBlocked:bbtq.x4 y:bbtq.y4]) {
			tileLocation.y = oldPosition.y;
		}
		
		// Based on the players current direction angle in radians, decide
		// which is the best animation to be using
		if (angleOfMovement > 0.785 && angleOfMovement < 2.355) {
			currentAnimation = downAnimation;
		} else if (angleOfMovement < -0.785 && angleOfMovement > -2.355) {
			currentAnimation = upAnimation;
		} else if (angleOfMovement < -2.355 || angleOfMovement > 2.355) {
			currentAnimation = rightAnimation;
		} else  {
			currentAnimation = leftAnimation;
		}
		
		[currentAnimation setState:kAnimationState_Running];
        [currentAnimation updateWithDelta:aDelta];
		
		// Set the OpenAL listener position within the sound manager to the location of the player
		[sharedSoundManager setListenerPosition:CGPointMake(pixelLocation.x, pixelLocation.y)];
	} else {
        [currentAnimation setState:kAnimationState_Stopped];
        [currentAnimation setCurrentFrame:4];
    }

}

- (void)checkForParchment:(AbstractObject*)aObject pickup:(BOOL)aPickup {

	// Check to see if the object just picked up was part of the parchment needed to escape from the
	// castle.  If pickup was YES then and the object was a parchment piece, then we set the approprite
	// parchment variable to YES.  If we were putting it down, then we set the appropriate variable to NO
	if (aPickup) {
		if (aObject.subType == kObjectSubType_ParchmentTop) {
			hasParchmentTop = YES;
		} else if (aObject.subType == kObjectSubType_ParchmentMiddle) {
			hasParchmentMiddle = YES;
		} else if (aObject.subType == kObjectSubType_ParchmentBottom) {
			hasParchmentBottom = YES;
		}
	} else {
		if (aObject.subType == kObjectSubType_ParchmentTop) {
			hasParchmentTop = NO;
		} else if (aObject.subType == kObjectSubType_ParchmentMiddle) {
			hasParchmentMiddle = NO;
		} else if (aObject.subType == kObjectSubType_ParchmentBottom) {
			hasParchmentBottom = NO;
		}
	}
	
	// If the player now has all three pieces of parchment then play the spell sound
	if (hasParchmentTop && hasParchmentMiddle && hasParchmentBottom) {
		[sharedSoundManager playSoundWithKey:@"spell" location:pixelLocation];
	}
}

@end

