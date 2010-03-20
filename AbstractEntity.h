//  AbstractEntity.h

#import "Global.h"
#import "GameController.h"
#import "SoundManager.h"
#import "GameScene.h"

@class AbstractScene;
@class Image;
@class SpriteSheet;
@class Animation;
@class GameScene;
@class BitmapFont;
@class AbstractEntity;

@interface AbstractEntity : NSObject <NSCoding> {

	/////////////////// Singleton Managers
    SoundManager *sharedSoundManager_;			// Sound Manager
    GameController *sharedGameController_;		// Game Controller

	////////////////// Images
	Image *image_;								// Base entity image
	SpriteSheet *spriteSheet_;                   // Holds the animation frames we are going to be using for this entity
    Animation *animation_;                       // Animation for this entity

	///////////////// Entity location
	CGPoint pixelLocation_;						// Entities position in pixels

	///////////////// Entity state/ivars
	GameScene *scene_;							// Reference to the game scene
	uint state_;									// Entities state
	ParticleEmitter *dyingEmitter_;				// Particle emitter used when the entity dies
	ParticleEmitter *appearingEmitter_;			// Particle emitter used when the entity appears

    CGFloat dx_, dy_;                               // velocity -- speed in pixels/sec and direction
    CGFloat collisionWidth_, collisionHeight_, collisionXOffset_, collisionYOffset_;
    CGFloat height_, width_;
    CGFloat scaleFactor_;
    bool active_;
}

@property (nonatomic, readonly) Image *image_;
@property (nonatomic, assign) CGPoint pixelLocation_;
@property (nonatomic, assign) uint state_;
@property (nonatomic, assign) bool active_;
@property (nonatomic, assign) CGFloat dx_;
@property (nonatomic, assign) CGFloat collisionWidth_;
@property (nonatomic, assign) CGFloat collisionHeight_;
@property (nonatomic, assign) CGFloat collisionXOffset_;
@property (nonatomic, assign) CGFloat collisionYOffset_;

- (id)initWithPixelLocation:(CGPoint)aLocation;

// Selector that updates the entities logic i.e. location, collision status etc
- (void)updateWithDelta:(float)aDelta scene:(AbstractScene*)aScene;

// Selector that renders the entity
- (void)render;

// Checks to see if the entity has collided with the entity passed in.  This method is
// subclassed to provide the entity specific functions that should be carried out when
// checking for and identifying a collision with another entity
- (void)checkForCollisionWithEntity:(AbstractEntity*)otherEntity;

@end
