//  AbstractEntity.m

#import "AbstractScene.h"
#import "Primatives.h"
#import "BitmapFont.h"
#import "AbstractEntity.h"

@implementation AbstractEntity

@synthesize state_;
@synthesize image_;
@synthesize pixelLocation_;
@synthesize active_;
@synthesize dx_;
@synthesize dy_;
@synthesize collisionWidth_;
@synthesize collisionHeight_;
@synthesize collisionXOffset_;
@synthesize collisionYOffset_;
@synthesize scaleFactor_;
@synthesize width_;

- (void)dealloc {
    [animation_ release];
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)init {
	self = [super init];
	if (self != nil) {
		// Grab references to the singleton managers
		sharedGameController_ = [GameController sharedGameController];
		sharedSoundManager_ = [SoundManager sharedSoundManager];

		// Grab a reference to the current game screne
		scene_ = (GameScene*)sharedGameController_.currentScene;
	}
	return self;
}

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [self init];
    return self;
}

#pragma mark -
#pragma mark Updating

- (void)updateWithDelta:(float)aDelta scene:(AbstractScene*)aScene {
}

#pragma mark -
#pragma mark Rendering

- (void)render {

// Debug code that allows us to draw bounding boxes for the entity
#ifdef SCB
		// Draw the collision bounds in green
		glColor4f(0, 1, 0, 1);
		drawBox([self collisionBounds]);

		// Draw the movement bounds in blue
		glColor4f(0, 0, 1, 1);
		drawBox([self movementBounds]);
#endif

}

#pragma mark -
#pragma mark Collision

- (void)checkForCollisionWithEntity:(AbstractEntity*)otherEntity {}

#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

}

@end
