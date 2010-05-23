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
#import "ParticleEmitter.h"
#import "PackedSpriteSheet.h"
#import "Shot.h"
#import "Player.h"

@implementation Alien

@synthesize position_;
@synthesize canFire_;
@synthesize fireChance_;
@synthesize alienInitialXShotPostion_;
@synthesize alienInitialYShotPostion_;

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

- (void)movementWithDelta:(float)aDelta {

    // bottom of the screen, game over
    if (pixelLocation_.y < scene_.playerBaseHeight_) {
        [scene_ aliensHaveLanded];
    }
    // change direction and move down
    if (dx_ < 0 && pixelLocation_.x < scene_.screenSidePadding_) {
        scene_.isAlienLogicNeeded_ = TRUE;
    }
    else if (dx_ > 0 && pixelLocation_.x > scene_.screenBounds_.size.width - (width_ * scaleFactor_) - scene_.screenSidePadding_) {
        scene_.isAlienLogicNeeded_ = TRUE;
    }

    pixelLocation_.x += aDelta * dx_;
}

- (id)initWithPixelLocation:(CGPoint)aLocation
                         dx:(float)dx
                         dy:(float)dy
                   position:(int)position
                    canFire:(bool)canFire
               chanceToFire:(int)chanceToFire {

    self = [super init];
	if (self != nil) {
        width_ = 45;
        height_ = 30;
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                       controlFile:@"pss_coordinates"
                                                                       imageFilter:GL_LINEAR];
		Image *SpriteSheetImage = [[pss imageForKey:@"aliens.png"] retain];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			scaleFactor_ = 1.5f;
            dyingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"dyingGhostEmitter" ofType:@"xml"];
            appearingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"portalEmitter" ofType:@"xml"];
		} else {
			scaleFactor_ = .7f;
            dyingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"dyingGhostEmitter" ofType:@"xml"];
            appearingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"portalEmitter" ofType:@"xml"];
		}
        SpriteSheetImage.scale = Scale2fMake(scaleFactor_, scaleFactor_);
        spriteSheet_ = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                               sheetKey:@"aliens.png"
                                             spriteSize:CGSizeMake(width_, height_)
                                                spacing:1
                                                 margin:0];

        animation_ = [[Animation alloc] init];
		float delay = 0.2;
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(4, 0)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(5, 0)] delay:delay];
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(6, 0)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(7, 0)] delay:delay];
        animation_.state = kAnimationState_Running;
        animation_.type = kAnimationType_PingPong;

		[SpriteSheetImage release];

        state_ = EntityState_Appearing;

        pixelLocation_.x = aLocation.x;
        pixelLocation_.y = aLocation.y;
        dx_ = dx;
        dy_ = dy;
        position_ = position;
        fireChance_ = chanceToFire;
        canFire_ = canFire;
        collisionWidth_ = scaleFactor_ * width_ * .8f;
        collisionHeight_ = scaleFactor_ * height_ *.8f;
        collisionXOffset_ = ((scaleFactor_ * width_) - collisionWidth_) / 2;
        collisionYOffset_ = ((scaleFactor_ * height_) - collisionHeight_) / 2;
        points_ = 25;
        alienInitialXShotPostion_ = scaleFactor_ * (width_ - 5)  / 2;
        alienInitialYShotPostion_ = scaleFactor_ * 13;
        middleX_ = scaleFactor_ * width_ / 2;
        middleY_ = scaleFactor_ * height_ / 2;
        appearingEmitter_.sourcePosition = Vector2fMake(pixelLocation_.x + middleX_, pixelLocation_.y + middleY_);
        [appearingEmitter_ setDuration:0.5f];
        [appearingEmitter_ setActive:TRUE];
    }
#ifdef MYDEBUG
    //NSLog(@"Alien init");
#endif
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {
    switch (state_) {
        case EntityState_Alive:
            [animation_ updateWithDelta:aDelta];
            break;
        case EntityState_Dying:
            [dyingEmitter_ updateWithDelta:aDelta];
            break;
        case EntityState_Appearing:
            [appearingEmitter_ updateWithDelta:aDelta];
            break;

        default:
            break;
    }
}

- (void)render {
    [super render];
    switch (state_) {
        case EntityState_Alive:
            [animation_ renderAtPoint:CGPointMake(pixelLocation_.x, pixelLocation_.y)];
            break;
        case EntityState_Dying:
            [dyingEmitter_ renderParticles];
            break;
        case EntityState_Appearing:
            [appearingEmitter_ renderParticles];
            break;

        default:
            break;
    }

}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {
    if ((pixelLocation_.y + collisionYOffset_ >= otherEntity.pixelLocation_.y + otherEntity.collisionYOffset_ + otherEntity.collisionHeight_) ||
        (pixelLocation_.x + collisionXOffset_ >= otherEntity.pixelLocation_.x + otherEntity.collisionXOffset_ + otherEntity.collisionWidth_) ||
        (otherEntity.pixelLocation_.y + otherEntity.collisionYOffset_ >= pixelLocation_.y + collisionYOffset_ + collisionHeight_) ||
        (otherEntity.pixelLocation_.x + otherEntity.collisionXOffset_ >= pixelLocation_.x + collisionXOffset_ + collisionWidth_)) {
        return;
    }

    if ([otherEntity isKindOfClass:[Shot class]]) {
        otherEntity.state_ = EntityState_Idle;
        state_ = EntityState_Dying;
        dyingEmitter_.sourcePosition = Vector2fMake(pixelLocation_.x + middleX_, pixelLocation_.y + middleY_);
        [dyingEmitter_ setDuration:0.0001f];
        [dyingEmitter_ setActive:TRUE];
        [scene_ alienKilledWithPosition:position_ points:points_ playerFlag:FALSE];
    } else if ([otherEntity isKindOfClass:[Player class]]) {
        state_ = EntityState_Dying;
        dyingEmitter_.sourcePosition = Vector2fMake(pixelLocation_.x + middleX_, pixelLocation_.y + middleY_);
        [dyingEmitter_ setDuration:0.0001f];
        [dyingEmitter_ setActive:TRUE];

        otherEntity.state_ = EntityState_Dying;
        otherEntity.dyingEmitter_.sourcePosition = Vector2fMake(otherEntity.pixelLocation_.x + otherEntity.middleX_,
                                                                otherEntity.pixelLocation_.y + otherEntity.middleY_);
        [otherEntity.dyingEmitter_ setDuration:1.0f];
        [otherEntity.dyingEmitter_ setActive:TRUE];
        otherEntity.appearingEmitter_.sourcePosition = Vector2fMake((scene_.screenBounds_.size.width - (otherEntity.width_*otherEntity.scaleFactor_)) / 2
                                                                    + otherEntity.middleX_, otherEntity.pixelLocation_.y + otherEntity.middleY_);
        [otherEntity.appearingEmitter_ setDuration:1.0f];
        [otherEntity.appearingEmitter_ setActive:TRUE];

        [scene_ alienKilledWithPosition:position_ points:points_ playerFlag:TRUE];
    } else {
        // otherEntity would only be ShieldPiece
        otherEntity.state_ = EntityState_Idle;
    }
}

- (void)dealloc {
    [dyingEmitter_ release];
	[appearingEmitter_ release];
    [super dealloc];
}

@end
