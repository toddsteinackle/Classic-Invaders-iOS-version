//
//  SmallBonusShip.m
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
#import "SmallBonusShip.h"
#import "ParticleEmitter.h"


@implementation SmallBonusShip

- (id)initWithPixelLocation:(CGPoint)aLocation {

    self = [super init];
	if (self != nil) {
        width_ = 45;
        height_ = 20;
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                       controlFile:@"pss_coordinates"
                                                                       imageFilter:GL_LINEAR];
		Image *SpriteSheetImage = [[pss imageForKey:@"small_bonuses_game.png"] retain];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			scaleFactor_ = 1.5f;
            dyingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"explosion-iPad" ofType:@"xml"];
		} else {
			scaleFactor_ = .85f;
            dyingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"explosion" ofType:@"xml"];
		}
        SpriteSheetImage.scale = Scale2fMake(scaleFactor_, scaleFactor_);
        spriteSheet_ = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                               sheetKey:@"small_bonuses_game.png"
                                             spriteSize:CGSizeMake(width_, height_)
                                                spacing:2
                                                 margin:0];

        animation_ = [[Animation alloc] init];
        if (sharedGameController_.graphicsChoice_) {
            float delay = 0.06;
            [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
            [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 1)] delay:delay];
        } else {
            float delay = 0.06;
            [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 2)] delay:delay];
            [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 3)] delay:delay];
            [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 4)] delay:delay];
            [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 5)] delay:delay];
            [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 6)] delay:delay];
            [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 7)] delay:delay];
        }


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
        points_ = 2500;
    }
    return self;
}

@end
