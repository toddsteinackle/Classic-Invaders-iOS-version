//
//  BigBonusShip.m
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/23/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "PackedSpriteSheet.h"
#import "BigBonusShip.h"
#import "SmallBonusShip.h"
#import "ParticleEmitter.h"


@implementation BigBonusShip

- (void)movementWithDelta:(float)aDelta {

    pixelLocation_.x += aDelta * dx_;
    if (dx_ > 0 && pixelLocation_.x > scene_.screenBounds_.size.width) {
        state_ = EntityState_Idle;
        [sharedSoundManager_ stopSoundWithKey:@"active_bonus"];
    } else if (dx_ < 0 && pixelLocation_.x < -width_ * scaleFactor_) {
        state_ = EntityState_Idle;
        [sharedSoundManager_ stopSoundWithKey:@"active_bonus"];
    }

}

- (id)initWithPixelLocation:(CGPoint)aLocation {

    self = [super init];
	if (self != nil) {
        width_ = 60;
        height_ = 26;
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                       controlFile:@"pss_coordinates"
                                                                       imageFilter:GL_LINEAR];
		Image *SpriteSheetImage = [[pss imageForKey:@"big_bonus.png"] retain];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			scaleFactor_ = 1.5f;
            dyingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"dyingGhostEmitter" ofType:@"xml"];
		} else {
			scaleFactor_ = .85f;
            dyingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"dyingGhostEmitter" ofType:@"xml"];
		}
        SpriteSheetImage.scale = Scale2fMake(scaleFactor_, scaleFactor_);
        spriteSheet_ = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                               sheetKey:@"big_bonus.png"
                                             spriteSize:CGSizeMake(width_, height_)
                                                spacing:1
                                                 margin:0];

        animation_ = [[Animation alloc] init];
		float delay = 0.06;
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 1)] delay:delay];
        animation_.state = kAnimationState_Running;
        animation_.type = kAnimationType_Repeating;

		[SpriteSheetImage release];

        pixelLocation_.x = aLocation.x;
        pixelLocation_.y = aLocation.y;
        collisionWidth_ = scaleFactor_ * width_ * .9f;
        collisionHeight_ = scaleFactor_ * height_ *.9f;
        collisionXOffset_ = ((scaleFactor_ * width_) - collisionWidth_) / 2;
        collisionYOffset_ = ((scaleFactor_ * height_) - collisionHeight_) / 2;
        state_ = EntityState_Idle;
        middleX_ = scaleFactor_ * width_ / 2;
        middleY_ = scaleFactor_ * height_ / 2;
        points_ = 500;
    }
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

    [sharedSoundManager_ stopSoundWithKey:@"active_bonus"];
    if ([self isKindOfClass:[SmallBonusShip class]]) {
        [sharedSoundManager_ playSoundWithKey:@"small_bonus" gain:0.25f];
    } else {
        [sharedSoundManager_ playSoundWithKey:@"big_bonus" gain:0.25f];
    }
    otherEntity.state_ = EntityState_Idle;
    state_ = EntityState_Dying;
    dyingEmitter_.sourcePosition = Vector2fMake(pixelLocation_.x + middleX_, pixelLocation_.y + middleY_);
    [dyingEmitter_ setDuration:0.25f];
    [dyingEmitter_ setActive:TRUE];
    [scene_ bonusShipDestroyedWithPoints:points_];
}

- (void)dealloc {
    [dyingEmitter_ release];
    [super dealloc];
}

@end
