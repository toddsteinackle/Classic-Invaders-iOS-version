//
//  GeneralGrave.h
//  SLQTSOR
//
//  Created by Mike Daley on 25/11/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "Global.h"
#import "AbstractObject.h"

@class Image;
@class Animation;

@interface MapObject : AbstractObject {

	// Image to be displayed for this object
	Image *image;
	// Animation
	SpriteSheet *spriteSheet;
	Animation *animation;
	
}

// Designated initializer
- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType;


@end
