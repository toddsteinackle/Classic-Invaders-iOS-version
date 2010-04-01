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
		Image *SpriteSheetImage = [[pss imageForKey:@"small_bonus.png"] retain];
        scaleFactor_ = .85;
        SpriteSheetImage.scale = Scale2fMake(scaleFactor_, scaleFactor_);
        spriteSheet_ = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                               sheetKey:@"small_bonus.png"
                                             spriteSize:CGSizeMake(width_, height_)
                                                spacing:1 margin:0];

        animation_ = [[Animation alloc] init];
		float delay = 0.06;
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 1)] delay:delay];
        animation_.state = kAnimationState_Running;
        animation_.type = kAnimationType_Repeating;

		[SpriteSheetImage release];

        dyingEmitter_ = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"dyingGhostEmitter" ofType:@"xml"];

        pixelLocation_.x = aLocation.x;
        pixelLocation_.y = aLocation.y;
        collisionWidth_ = scaleFactor_ * width_ * .9f;
        collisionHeight_ = scaleFactor_ * height_ *.9f;
        collisionXOffset_ = ((scaleFactor_ * width_) - collisionWidth_) / 2;
        collisionYOffset_ = ((scaleFactor_ * height_) - collisionHeight_) / 2;
        //active_ = FALSE;
        middleX_ = scaleFactor_ * width_ / 2;
        middleY_ = scaleFactor_ * height_ / 2;
        points_ = 1000;
    }
    return self;
}

@end
