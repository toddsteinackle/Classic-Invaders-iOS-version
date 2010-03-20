//
//  Alien2.m
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/16/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import "Alien2.h"

#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "PackedSpriteSheet.h"

@implementation Alien2

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
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 4)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 5)] delay:delay];
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 6)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 7)] delay:delay];
        animation_.state = kAnimationState_Running;
        animation_.type = kAnimationType_PingPong;

		[SpriteSheetImage release];

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
    }
    //NSLog(@"Alien2 init");
    return self;
}


#pragma mark -
#pragma mark Updating

- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {
    [animation_ updateWithDelta:aDelta];
}

#pragma mark -
#pragma mark Rendering

- (void)render {
    [super render];
    [animation_ renderAtPoint:CGPointMake(pixelLocation_.x, pixelLocation_.y)];
}

- (void)dealloc {
    [animation_ release];
    [super dealloc];
}

@end
