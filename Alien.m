//
//  Alien.m
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/14/10.
//  Copyright 2010 Todd Steinackle. All rights reserved.
//

#import "Alien.h"
#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "SpriteSheet.h"
#import "Animation.h"
//#import "Player.h"
//#import "ParticleEmitter.h"
//#import "BitmapFont.h"
#import "PackedSpriteSheet.h"

@implementation Alien

- (void)movement:(float)aDelta {
    pixelLocation.x += aDelta * dx;
    if (pixelLocation.x < 0) {
        dx = -dx;
    } else if (pixelLocation.x > 480 - (45*.75)) {
        dx = -dx;
    }
}

#pragma mark -
#pragma mark Initialization

- (id)initWithLocation:(CGPoint)aLocation dx:(float)hspeed dy:(float)vspeed position:(int)pos fire_chance:(int)chance {

    self = [super init];
	if (self != nil) {
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png" controlFile:@"pss_coordinates" imageFilter:GL_LINEAR];
		Image *SpriteSheetImage = [[pss imageForKey:@"aliens.png"] retain];
        SpriteSheetImage.scale = Scale2fMake(0.75f, 0.75f);
        spriteSheet = [SpriteSheet spriteSheetForImage:SpriteSheetImage sheetKey:@"aliens.png" spriteSize:CGSizeMake(45, 30) spacing:1 margin:0];

        animation = [[Animation alloc] init];
		float delay = 0.2;
		[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        [animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:delay];
		[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:delay];
        [animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 3)] delay:delay];
        animation.state = kAnimationState_Running;
        animation.type = kAnimationType_PingPong;

		[SpriteSheetImage release];

        // Set the actors location to the CGPoint location which was passed in
//        tileLocation = aLocation;
//        angle = (int)(360 * RANDOM_0_TO_1()) % 360;
//        speed = (float)(RANDOM_0_TO_1() * MOVEMENT_SPEED);
        pixelLocation.x = aLocation.x;
        pixelLocation.y = aLocation.y;
        dx = hspeed;
        dy = vspeed;
        position = pos;
        fire_chance = chance;

		// Set up the particle emitter used when the ghost dies, in a metaphysical kinda way of course
//		dyingEmitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"dyingGhostEmitter" ofType:@"xml"];
//		appearingEmitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"appearingEmitter" ofType:@"xml"];
//
//		state = kEntityState_Dead;
//		energyDrain = 10;
    }
    //NSLog(@"Alien init");
    return self;
}

#pragma mark -
#pragma mark Updating

- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {

    //scene = (GameScene*)aScene;
    [animation updateWithDelta:aDelta];
    //NSLog(@"Alien delta update");
}

#pragma mark -
#pragma mark Rendering

- (void)render {
    [super render];
    [animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
    //NSLog(@"Alien render");
}

#pragma mark -
#pragma mark Bounds & collision

//- (CGRect)movementBounds {
//	// Calculate the pixel position and return a CGRect that defines the bounds
//	pixelLocation = tileMapPositionToPixelPosition(tileLocation);
//	return CGRectMake(pixelLocation.x - 20, pixelLocation.y - 10, 40, 20);
//
//}

//- (CGRect)collisionBounds {
//	// Calculate the pixel position and return a CGRect that defines the bounds
//	pixelLocation = tileMapPositionToPixelPosition(tileLocation);
//	return CGRectMake(pixelLocation.x - 19, pixelLocation.y - 7, 39, 14);
//}

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity {
}

- (void)dealloc {
    [animation release];
	//[dyingEmitter release];
	//[appearingEmitter release];
    [super dealloc];
}

@end
