//
//  Sword.m
//  GLGamev2
//
//  Created by Michael Daley on 15/07/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "Axe.h"
#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "Image.h"
#import "Player.h"
#import "Ghost.h"
#import "PackedSpriteSheet.h"

@implementation Axe

@synthesize throwAngle;

- (void)dealloc {
	[image release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithTileLocation:(CGPoint)aLocation {
    self = [super init];
	if (self != nil) {
        
        // Set up the image for the weapon
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"atlas.png" controlFile:@"coordinates" imageFilter:GL_LINEAR];
		image = [[pss imageForKey:@"axe.png"] retain];
		
        // Set the center of rotation for the image
        image.rotationPoint = CGPointMake(6, 10);
        
        // Set the actors location to the vector location which was passed in
        tileLocation.x = aLocation.x;
        tileLocation.y = aLocation.y;
        
        // Set the speed of the axe and its timer
        speed = 6;
        lifeSpanTimer = 0;
        
        // Set the default direction of the player
        throwAngle = 0;
        
        // Set the entitu state to idle when it is created
        state = kEntityState_Idle;
    }
    return self;
}

#pragma mark -
#pragma mark Update

#define SWORD_LIFE_SPAN 2.0f

- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {
    
	// Record the current position of the axe
	CGPoint oldLocation;
	
    switch (state) {
        case kEntityState_Alive:
			// Take a copy of the current location so that we can move the axe back to this
			// location if there is a collision
			oldLocation = tileLocation;
		
            // Grab the scene that has been passed in
            scene = (GameScene*)aScene;
			
            // Update the x position of the sword
			tileLocation.x -= (speed * cosf(throwAngle)) * aDelta;
			
			// Convert the tile position to the pixel position ready for the collision checks
			pixelLocation = tileMapPositionToPixelPosition(tileLocation);
			CGRect bRect = [self movementBounds];
			BoundingBoxTileQuad bbtq = getTileCoordsForBoundingRect(bRect, CGSizeMake(kTile_Width, kTile_Height));
			
			// Check to see if moving the axe in along the a-axis causes it to collide with a blocked tile
            if([scene isBlocked:bbtq.x1 y:bbtq.y1] ||
               [scene isBlocked:bbtq.x2 y:bbtq.y2] ||
               [scene isBlocked:bbtq.x3 y:bbtq.y3] || 
               [scene isBlocked:bbtq.x4 y:bbtq.y4]) {
				// Check to see if the axe is moving up or down the screen and reflect the
				// angle as necessary in the x-axis.  The values below are radians
				if (throwAngle < 0) {
					throwAngle = -3.141f - throwAngle;
				}
				if (throwAngle >= 0) {
					throwAngle = 3.141f - throwAngle;
				}
				// Put the axe back to the pre-collision location
				tileLocation = oldLocation;
				
				[sharedSoundManager playSoundWithKey:@"hitWall"	location:CGPointMake(pixelLocation.x, pixelLocation.y)];

            } else {
				// Moving along the x-axis did not cause a collision so now do the same along the y-axis
				tileLocation.y -= (speed * sinf(throwAngle)) * aDelta;
				pixelLocation = tileMapPositionToPixelPosition(tileLocation);
				CGRect bRect = [self movementBounds];
				BoundingBoxTileQuad bbtq = getTileCoordsForBoundingRect(bRect, CGSizeMake(kTile_Width, kTile_Height));
				if([scene isBlocked:bbtq.x1 y:bbtq.y1] ||
				   [scene isBlocked:bbtq.x2 y:bbtq.y2] ||
				   [scene isBlocked:bbtq.x3 y:bbtq.y3] || 
				   [scene isBlocked:bbtq.x4 y:bbtq.y4]) {
					// Reflect the angle being travelled and put the axe back to the pre-collision location
					throwAngle *= -1;
					tileLocation = oldLocation;
					
					[sharedSoundManager playSoundWithKey:@"hitWall"	location:CGPointMake(pixelLocation.x, pixelLocation.y)];

				}
			}
			
            // Update the timer and rotate the axe image
            lifeSpanTimer += aDelta;
			image.rotation -= 720 * aDelta;
        
            // If the timer exceeds the defined time then set the entity state
            // to idle
            if(lifeSpanTimer > SWORD_LIFE_SPAN) {
                state = kEntityState_Idle;
                tileLocation = CGPointMake(0, 0);
                lifeSpanTimer = 0;                
            }
			
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Rendering

- (void)render {
    if(state == kEntityState_Alive) {
		[super render];
        [image renderCenteredAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
	}
}

#pragma mark -
#pragma mark Collision & Bounding

- (CGRect)collisionBounds {
	return CGRectMake(pixelLocation.x - 7, pixelLocation.y - 8, 14, 16);	
}

- (CGRect)movementBounds {
	return CGRectMake(pixelLocation.x - 13, pixelLocation.y - 15, 26, 30);
}

#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	[self initWithTileLocation:CGPointMake(0, 0)];
	tileLocation = [aDecoder decodeCGPointForKey:@"position"];
	throwAngle = [aDecoder decodeFloatForKey:@"direction"];
	lifeSpanTimer = [aDecoder decodeFloatForKey:@"lifeSpanTimer"];
	state = [aDecoder decodeIntForKey:@"state"];

	// Calculate the pixel position of the weapon
	pixelLocation.x = tileLocation.x * kTile_Width;
	pixelLocation.y = tileLocation.y * kTile_Height;
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeCGPoint:tileLocation forKey:@"position"];
	[aCoder encodeFloat:throwAngle forKey:@"direction"];
	[aCoder encodeFloat:lifeSpanTimer forKey:@"lifeSpanTimer"];
	[aCoder encodeInt:state forKey:@"state"];
	[aCoder encodeFloat:image.rotation forKey:@"imageRotation"];
}

@end
