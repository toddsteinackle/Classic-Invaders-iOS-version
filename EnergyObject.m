//
//  EnergyCake.m
//  SLQTSOR
//
//  Created by Mike Daley on 25/11/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "EnergyObject.h"
#import "PackedSpriteSheet.h"
#import "Image.h"
#import "AbstractEntity.h"
#import "SoundManager.h"
#import "Player.h"

@implementation EnergyObject

- (void)dealloc {
	[image release];
	[super dealloc];
}

- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType {
	self = [super init];
	if (self != nil) {
		type = aType;
		subType = aSubType;

		// Add 0.5 to the tile location so that the object is in the middle of the square
		// as defined in the tile map editor
		tileLocation.x = aTileLocaiton.x + 0.5f;
		tileLocation.y = aTileLocaiton.y + 0.5f;
		pixelLocation = tileMapPositionToPixelPosition(tileLocation);
		
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"atlas.png" controlFile:@"coordinates" imageFilter:GL_LINEAR];

		switch (subType) {
			case kObjectSubType_Cake:
				image = [[[pss imageForKey:@"item_cake.png"] imageCopy] retain];
				energy = 20;
				break;
				
			case kObjectSubType_Drink:
				image = [[[pss imageForKey:@"item_drink.png"] imageCopy] retain];
				energy = 10;
				break;

			case kObjectSubType_Candy:
				image = [[[pss imageForKey:@"item_chocolate.png"] imageCopy] retain];
				energy = 15;
				break;
				
			case kObjectSubType_Chicken:
				image = [[[pss imageForKey:@"item_chicken.png"] imageCopy] retain];
				energy = 25;
				break;

			case kObjectSubType_Ham:
				image = [[[pss imageForKey:@"item_ham.png"] imageCopy] retain];
				energy = 20;
				break;
				
			case kObjectSubType_LolliPop:
				image = [[[pss imageForKey:@"item_lollipop.png"] imageCopy] retain];				
				energy = 10;
				break;

			default:
				break;
		}
	}
	return self;
}

- (void)updateWithDelta:(float)aDelta scene:(AbstractScene *)aScene {
	
	if (state == kObjectState_Active) {
		Scale2f scale = image.scale;
		if (scaleUp) {
			scale.x += 0.75 * aDelta;
			scale.y += 0.75 * aDelta;
		} else {
			scale.x -= 0.75 * aDelta;
			scale.y -= 0.75 * aDelta;
		}
		
		image.scale = scale;
		if (scale.x > 1.35) {
			scaleUp = NO;
		}
		
		if (scale.x < 1) {
			scaleUp = YES;
		}
	}
}

- (void)render {
	// Only render the object if its state is active
	if (state == kObjectState_Active) {
		[image renderCenteredAtPoint:pixelLocation];
	}
	[super render];
}

- (void)checkForCollisionWithEntity:(AbstractEntity*)aEntity {

	// Only bother to check for collisions if the entity passed in is the player
	if ([aEntity isKindOfClass:[Player class]]) {

		if (CGRectIntersectsRect([self collisionBounds], [aEntity collisionBounds])) {
			// If we have collided with the player then set the state of the object to inactive
			// and plat the eatfood sound
			state = kObjectState_Inactive;
			
			// Play the sound to signify that the player has gained energy
			[sharedSoundManager playSoundWithKey:@"eatfood"	location:CGPointMake(aEntity.pixelLocation.x, aEntity.pixelLocation.y)];
		}
	}
}

- (CGRect)collisionBounds { 
	return CGRectMake(pixelLocation.x - 10, pixelLocation.y - 10, 20, 20);
}

@end
