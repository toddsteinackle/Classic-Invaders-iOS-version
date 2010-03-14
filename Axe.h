//
//  Sword.h
//  GLGamev2
//
//  Created by Michael Daley on 15/07/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//
// The sword is thrown by the player to kill the monsters they come across.  The 
// sword will kill any monstores it collides with and will bounce off of objects
// for a period defined by SWORD_LIFE_SPAN.
//
#import "AbstractEntity.h"

@class GameScene;
@class GameController;

@interface Axe : AbstractEntity {

    float throwAngle;		// The angle at which the axe will be thrown
    float lifeSpanTimer;	// Accumulates the time the axe is alive.  Used as a timer
}

@property (nonatomic, assign) float throwAngle;


@end
