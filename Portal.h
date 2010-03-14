//
//  Portal.h
//  SLQTSOR
//
//  Created by Mike Daley on 13/09/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "AbstractEntity.h"

@class ParticleEmitter;

@interface Portal : AbstractEntity {
	ParticleEmitter *portalParticleEmitter;		// Emitter used to represent the portal
	CGPoint beamLocation;						// Location to which the player is beamed on entering the portal
}

// Creates an instance of the player class with the given tilemap location.  It also takes
// a tile map location as the beam location which specifies the tile map locaiton the
// player will be beamed too.
- (id)initWithTileLocation:(CGPoint)aLocation beamLocation:(CGPoint)aBeamLocation;

@end
