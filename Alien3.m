//
//  Alien3.m
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/16/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import "Alien3.h"
#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "PackedSpriteSheet.h"
#import "ParticleEmitter.h"

@implementation Alien3

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
            dyingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"explosion-iPad" ofType:@"xml"];
            appearingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"alienBirth-iPad" ofType:@"xml"];
            alienDropDown_ = 23.0f;
		} else {
			scaleFactor_ = .7f;
            dyingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"explosion" ofType:@"xml"];
            appearingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"alienBirth" ofType:@"xml"];
            alienDropDown_ = 8.0f;
		}
        SpriteSheetImage.scale = Scale2fMake(scaleFactor_, scaleFactor_);
        spriteSheet_ = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                               sheetKey:@"aliens.png"
                                             spriteSize:CGSizeMake(width_, height_)
                                                spacing:1
                                                 margin:0];

        animation_ = [[Animation alloc] init];
		float delay = 0.2;
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(1, 0)] delay:delay];
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(2, 0)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(3, 0)] delay:delay];
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
        collisionWidth_ = scaleFactor_ * width_ * .6f;
        collisionHeight_ = scaleFactor_ * height_ *.8f;
        collisionXOffset_ = ((scaleFactor_ * width_) - collisionWidth_) / 2;
        collisionYOffset_ = ((scaleFactor_ * height_) - collisionHeight_) / 2;
        points_ = 100;
        alienInitialXShotPostion_ = scaleFactor_ * (width_ - 5)  / 2;
        alienInitialYShotPostion_ = scaleFactor_ * 13;
        middleX_ = scaleFactor_ * width_ / 2;
        middleY_ = scaleFactor_ * height_ / 2;
        appearingEmitter_.sourcePosition = Vector2fMake(pixelLocation_.x + middleX_, pixelLocation_.y + middleY_);
        [appearingEmitter_ setDuration:0.5f];
        [appearingEmitter_ setActive:TRUE];
    }
    return self;
}

@end
