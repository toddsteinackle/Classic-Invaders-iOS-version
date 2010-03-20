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
#import "Shot.h"

@implementation Alien

- (void)description {
    NSLog(@"description of alien");
    NSLog(@"position %d", position_);
    NSLog(@"fireChance %d", fireChance_);
    NSLog(@"points %d", points_);
    NSLog(@"canFire %d", canFire_);
    [super description];
}

- (void)doAlienLogic {
    dx_ = -dx_;
    pixelLocation_.y -= 8.0f;
}

- (void)movement:(float)aDelta {

    // bottom of the screen, game over
    if (pixelLocation_.y < scene_.playerBaseHeight_) {
        [scene_ aliensHaveLanded];
    }
    // change direction and move down
    if (dx_ < 0 && pixelLocation_.x < scene_.screenSidePadding_) {
        scene_.isAlienLogicNeeded_ = TRUE;
    }
    else if (dx_ > 0 && pixelLocation_.x > 480 - (45 * scaleFactor_) - scene_.screenSidePadding_) {
        scene_.isAlienLogicNeeded_ = TRUE;
    }

    pixelLocation_.x += aDelta * dx_;
}

#pragma mark -
#pragma mark Initialization

- (id)initWithPixelLocation:(CGPoint)aLocation dx:(float)dx dy:(float)dy position:(int)position canFire:(bool)canFire chanceToFire:(int)chanceToFire {

    self = [super init];
	if (self != nil) {
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png" controlFile:@"pss_coordinates" imageFilter:GL_LINEAR];
		Image *SpriteSheetImage = [[pss imageForKey:@"aliens.png"] retain];
        scaleFactor_ = .7;
        SpriteSheetImage.scale = Scale2fMake(scaleFactor_, scaleFactor_);
        spriteSheet_ = [SpriteSheet spriteSheetForImage:SpriteSheetImage sheetKey:@"aliens.png" spriteSize:CGSizeMake(45, 30) spacing:1 margin:0];

        animation_ = [[Animation alloc] init];
		float delay = 0.2;
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 1)] delay:delay];
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 2)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 3)] delay:delay];
        animation_.state = kAnimationState_Running;
        animation_.type = kAnimationType_PingPong;

		[SpriteSheetImage release];

        // Set the actors location to the CGPoint location which was passed in
//        tileLocation = aLocation;
//        angle = (int)(360 * RANDOM_0_TO_1()) % 360;
//        speed = (float)(RANDOM_0_TO_1() * MOVEMENT_SPEED);
        pixelLocation_.x = aLocation.x;
        pixelLocation_.y = aLocation.y;
        dx_ = dx;
        dy_ = dy;
        position_ = position;
        fireChance_ = chanceToFire;
        canFire_ = canFire;
        collisionWidth_ = scaleFactor_ * 45 * .8f;
        collisionHeight_ = scaleFactor_ * 30 *.8f;
        collisionXOffset_ = ((scaleFactor_ * 45) - collisionWidth_) / 2;
        collisionYOffset_ = ((scaleFactor_ * 30) - collisionHeight_) / 2;
        active_ = TRUE;

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
    [animation_ updateWithDelta:aDelta];
    //NSLog(@"Alien delta update");
}

#pragma mark -
#pragma mark Rendering

- (void)render {
    [super render];
    [animation_ renderAtPoint:CGPointMake(pixelLocation_.x, pixelLocation_.y)];
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

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {
    if ((self.pixelLocation_.y + self.collisionYOffset_ >= otherEntity.pixelLocation_.y + otherEntity.collisionYOffset_ + otherEntity.collisionHeight_) ||
        (self.pixelLocation_.x + self.collisionXOffset_ >= otherEntity.pixelLocation_.x + otherEntity.collisionXOffset_ + otherEntity.collisionWidth_) ||
        (otherEntity.pixelLocation_.y + otherEntity.collisionYOffset_ >= self.pixelLocation_.y + self.collisionYOffset_ + self.collisionHeight_) ||
        (otherEntity.pixelLocation_.x + otherEntity.collisionXOffset_ >= self.pixelLocation_.x + self.collisionXOffset_ + self.collisionWidth_)) {
        return;
    }

    if ([otherEntity isKindOfClass:[Shot class]]) {
        self.active_ = FALSE;
        otherEntity.active_ = FALSE;
    }
}

- (void)dealloc {
    [animation_ release];
	//[dyingEmitter release];
	//[appearingEmitter release];
    [super dealloc];
}

@end
