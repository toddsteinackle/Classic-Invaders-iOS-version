//
//  AbstractObject.m
//  SLQTSOR
//
//  Created by Mike Daley on 25/11/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "AbstractObject.h"
#import "AbstractScene.h"
#import "AbstractEntity.h"
#import "SoundManager.h"
#import "Primatives.h"

@implementation AbstractObject

@synthesize tileLocation;
@synthesize pixelLocation;
@synthesize state;
@synthesize type;
@synthesize subType;
@synthesize energy;
@synthesize isCollectable;


- (void)dealloc {
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self != nil) {
		sharedSoundManager = [SoundManager sharedSoundManager];
	}
	return self;
}		

- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType {
	self = [self init];
	return self;
}

- (void)updateWithDelta:(float)aDelta scene:(AbstractScene*)aScene { }

- (void)render { 
// Debug code that allows us to draw bounding boxes for the entity
#ifdef SCB
		glColor4f(0, 1, 0, 1);
		drawBox([self collisionBounds]);
#endif
	
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity { }


- (CGRect)collisionBounds { 
	return CGRectZero;
}

#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	[self initWithTileLocation:[aDecoder decodeCGPointForKey:@"tileLocation"]
						  type:[aDecoder decodeIntForKey:@"state"] 
					   subType:[aDecoder decodeIntForKey:@"subType"]];
	pixelLocation = [aDecoder decodeCGPointForKey:@"pixelLocation"];
	state = [aDecoder decodeIntForKey:@"entityState"];
	energy = [aDecoder decodeIntForKey:@"energy"];
	isCollectable = [aDecoder decodeIntForKey:@"isCollectable"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	tileLocation.x;
	tileLocation.y;
	[aCoder encodeCGPoint:tileLocation forKey:@"tileLocation"];
	[aCoder encodeCGPoint:pixelLocation forKey:@"pixelLocation"];
	[aCoder encodeInt:state forKey:@"entityState"];
	[aCoder encodeInt:type forKey:@"type"];
	[aCoder encodeInt:subType forKey:@"subType"];
	[aCoder encodeInt:energy forKey:@"energy"];
	[aCoder encodeInt:isCollectable forKey:@"isCollectbale"];

}
@end
