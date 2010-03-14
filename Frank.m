//
//  Frank.m
//  SLQTSOR
//
//  Created by Mike Daley on 10/11/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "Frank.h"
#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "Player.h"
#import "Axe.h"
#import "ParticleEmitter.h"
#import "BitmapFont.h"
#import "PackedSpriteSheet.h"

@implementation Frank

#define MOVEMENT_SPEED 1.0f

- (void)dealloc {
    [animation release];
	[dyingEmitter release];
	[appearingEmitter release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithTileLocation:(CGPoint)aLocation {
    self = [super init];
	if (self != nil) {
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"atlas.png" controlFile:@"coordinates" imageFilter:GL_LINEAR];
		Image *embededSpriteSheetImage = [[pss imageForKey:@"spritesheet_frank.png"] retain];
        spriteSheet = [SpriteSheet spriteSheetForImage:embededSpriteSheetImage sheetKey:@"spritesheet_frank.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
		
        animation = [[Animation alloc] init];
		float delay = 0.2f;
		[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:delay];
        [animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
		[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:delay];
        animation.state = kAnimationState_Running;
        animation.type = kAnimationType_PingPong;
		
		[embededSpriteSheetImage release];
        
        // Set the actors location to the CGPoint location which was passed in
        tileLocation = aLocation;
        angle = (int)(360 * RANDOM_0_TO_1()) % 360;
        speed = (float)(RANDOM_0_TO_1() * MOVEMENT_SPEED);
		
		// Set up the particle emitter used when the ghost dies, in a metaphysical kinda way of course
		dyingEmitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"dyingGhostEmitter" ofType:@"xml"];		
		appearingEmitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"appearingEmitter" ofType:@"xml"];

		state = kEntityState_Dead;
		energyDrain = 20;
    }
    return self;
}

#pragma mark -
#pragma mark Updating

- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {
    
    scene = (GameScene*)aScene;
	int changeDirSpeed;
	
	switch (state) {
			
		case kEntityState_Appearing:
			// If the particle count for the appearing emitter is 0 then it has not been started and
			// we can start it now
			if(appearingEmitter.particleCount == 0) {
				appearingEmitter.sourcePosition = Vector2fMake(pixelLocation.x, pixelLocation.y);
				[appearingEmitter setDuration:-1];
				[appearingEmitter setActive:YES];
			}
			
			// Update the appearing emitter.
			[appearingEmitter updateWithDelta:aDelta];
			
			// Only start timing the appearance of the entity once the appearing
			// emitter is active
			if (appearingEmitter.active) {
				// Update the appearing timer and update the emitter
				appearingTimer += aDelta;
				
				// Check to see if we have exceeded the appearing timer.  If so then set it to inactive,
				// mark the ghost as alive and reset the appearing timer to 0
				if (appearingTimer >= 3.0f) {
					[appearingEmitter setActive:NO];
					state = kEntityState_Alive;
					appearingTimer = 0;
				}
			}
			break;
			
		case kEntityState_Alive:
			
			// If there are any particles alive from appearing update them
			if(appearingEmitter.particleCount > 0)
				[appearingEmitter updateWithDelta:aDelta];
			
			// Calculate the manhatten distance from the player so that we can re-spawn the enetity
			// should the player move too far away.
			distanceFromPlayer = ((scene.player.tileLocation.x - tileLocation.x) + (scene.player.tileLocation.y - tileLocation.y));
			
			if(distanceFromPlayer > kMax_Player_Distance || distanceFromPlayer < -kMax_Player_Distance) {
				offScreenTimer += aDelta;
			} else {
				offScreenTimer = 0;
			}
			
			//  If the ghost has been off screen for more than defined period, set the entity to dead
			// and reset the offScreenTimer
			if(offScreenTimer >= 1) {
				state = kEntityState_Dead;
				offScreenTimer = 0;
				break;
			}
			
			// To make the ghost move in a random manner it randomly decides to change direction
			// and speed.
			changeDirSpeed = (int)(99 * RANDOM_0_TO_1());
			if(changeDirSpeed == 1) {
				angle = (int)(360 * RANDOM_0_TO_1()) % 360;
				speed = (float)(RANDOM_0_TO_1() * MOVEMENT_SPEED);
			}
			
			// Based on the new direction and speed move the ghost.  This also takes into account
			// the fixed time that has been passed in.  We also take a copy of the current 
			// position in case we need to back out this move if the way is blocked
			CGPoint oldPosition = tileLocation;
			tileLocation.x += (speed * cos(DEGREES_TO_RADIANS(angle))) * aDelta;
			tileLocation.y += (speed * sin(DEGREES_TO_RADIANS(angle))) * aDelta;
			
			// We have just moved the ghost, so we need to make sure that none of the vertices for its
			// bounding box are in a blocked tile.  First get the bounds for the ghost
			CGRect bRect = [self movementBounds];
			
			// ...and then convert them into tile map coordinates
			BoundingBoxTileQuad bbtq = getTileCoordsForBoundingRect(bRect, CGSizeMake(kTile_Width, kTile_Height));
			
			// ...and then check to see of any of the vertices are in a blocked tile.  If they are then we
			// reverse the ghost by reversing
			if([scene isBlocked:bbtq.x1 y:bbtq.y1] ||
			   [scene isBlocked:bbtq.x2 y:bbtq.y2] ||
			   [scene isBlocked:bbtq.x3 y:bbtq.y3] || 
			   [scene isBlocked:bbtq.x4 y:bbtq.y4]) {
				
				// The way is blocked so restore the old position and change the ghosts angle
				// to something in the oposite direction
				tileLocation = oldPosition;
				angle = (int)(angle + 180) * RANDOM_0_TO_1();
			}
			
			// Now that the ghosts logic has been updated we can render the current animation
			// frame
			[animation updateWithDelta:aDelta];
			
			break;
			
		case kEntityState_Dying:
			[dyingEmitter updateWithDelta:aDelta];
			if(dyingEmitter.particleCount == 0) {
				state = kEntityState_Dead;
				
				// Make sure that all the particles from the appearing emitter are
				// all dead before letting the ghost appear again.
				while (appearingEmitter.particleCount > 0) {
					[appearingEmitter updateWithDelta:aDelta];
				}
			}
			
			break;
			
		default:
			break;
	}
	
}

#pragma mark -
#pragma mark Rendering

- (void)render {
	
	switch (state) {
		case kEntityState_Appearing:
			[appearingEmitter renderParticles];
			break;
		case kEntityState_Alive:
			[super render];
			if (appearingEmitter.particleCount > 0)
				[appearingEmitter renderParticles];
			
			[animation renderCenteredAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
			break;
		case kEntityState_Dying:
			[dyingEmitter renderParticles];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark Bounds & collision

- (CGRect)movementBounds { 
	// Calculate the pixel position and return a CGRect that defines the bounds
	pixelLocation = tileMapPositionToPixelPosition(tileLocation);
	return CGRectMake(pixelLocation.x - 15, pixelLocation.y - 20, 30, 40);
}

- (CGRect)collisionBounds {
	// Calculate the pixel position and return a CGRect that defines the bounds
	pixelLocation = tileMapPositionToPixelPosition(tileLocation);
	return CGRectMake(pixelLocation.x - 9, pixelLocation.y - 19, 16, 38);
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity {
	if(([aEntity isKindOfClass:[Player class]] || [aEntity isKindOfClass:[Axe class]]) && aEntity.state == kEntityState_Alive) {
		if (CGRectIntersectsRect([self collisionBounds], [aEntity collisionBounds])) {
			[sharedSoundManager playSoundWithKey:@"pop" location:CGPointMake(tileLocation.x*kTile_Width, tileLocation.y*kTile_Height)];
			state = kEntityState_Dying;
			dyingEmitter.sourcePosition = Vector2fMake(pixelLocation.x, pixelLocation.y);
			[dyingEmitter setDuration:0.05f];
			[dyingEmitter setActive:YES];
			scene.score += 150;
		}
	}
}

@end

