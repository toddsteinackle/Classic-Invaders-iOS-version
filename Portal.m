//
//  Portal.m
//  SLQTSOR
//
//  Created by Mike Daley on 13/09/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "GameController.h"
#import "Portal.h"
#import "ParticleEmitter.h"
#import "GameScene.h"
#import "Player.h"

@implementation Portal

- (void)dealloc {
	[portalParticleEmitter release];
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithTileLocation:(CGPoint)aLocation beamLocation:(CGPoint)aBeamLocation {
    self = [super init];
	if (self != nil) {
		beamLocation = aBeamLocation;
		tileLocation = aLocation;
		state = kEntityState_Idle;

		// Calculate the pixel coordinates for the portal
		pixelLocation = tileMapPositionToPixelPosition(tileLocation);
		
		// Create a new particle emitter
		portalParticleEmitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"portalEmitter" ofType:@"xml"];
		portalParticleEmitter.sourcePosition = Vector2fMake(pixelLocation.x, pixelLocation.y);
    }
    return self;
}

#pragma mark -
#pragma mark Updating

#define kMaxPlayerDistance 6.0f

- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {
	
	switch (state) {
		case kEntityState_Alive:
				[portalParticleEmitter updateWithDelta:aDelta];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark Rendering

- (void)render {
		switch (state) {
			case kEntityState_Alive:
				[super render];
				[portalParticleEmitter renderParticles];
				break;
			default:
				break;
		}
}

#pragma mark -
#pragma mark Bounds & Collision

- (CGRect)collisionBounds { 
	// Calculate their location in pixels
	CGRect rect = CGRectMake(pixelLocation.x - 10, pixelLocation.y - 10, 20, 20);
	return rect;
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity {
	if (CGRectIntersectsRect([self collisionBounds], [aEntity collisionBounds])) {
		if([aEntity isKindOfClass:[Player class]]) {
			sharedGameController.currentScene.state = kSceneState_TransportingOut;
			Player *player = (Player*)aEntity;
			player.beamLocation = beamLocation;
		}
	}
}

@end
