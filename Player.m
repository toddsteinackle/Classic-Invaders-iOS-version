//
//  Player.m
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/16/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import "Player.h"
#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "PackedSpriteSheet.h"
//#import "Alien.h"
//#import "Shot.h"

@implementation Player

@synthesize playerInitialXShotPostion_;
@synthesize playerInitialYShotPostion_;

- (void)movement:(float)aDelta {

    // don't move off left hand side of the screen
    if (dx_ < 0 && pixelLocation_.x < scene_.screenSidePadding_) {
        return;
    }
    // don't move off right hand side of the screen
    if (dx_ > 0 && pixelLocation_.x > rightScreenBoundary_ - scene_.screenSidePadding_) {
        return;
    }
    pixelLocation_.x += aDelta * dx_;

}

- (id)initWithPixelLocation:(CGPoint)aLocation {

    self = [super init];
	if (self != nil) {
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png" controlFile:@"pss_coordinates" imageFilter:GL_LINEAR];
		Image *SpriteSheetImage = [[pss imageForKey:@"ship.png"] retain];
        scaleFactor_ = .85;
        SpriteSheetImage.scale = Scale2fMake(scaleFactor_, scaleFactor_);
        spriteSheet_ = [SpriteSheet spriteSheetForImage:SpriteSheetImage sheetKey:@"ship.png" spriteSize:CGSizeMake(43, 25) spacing:1 margin:0];

        animation_ = [[Animation alloc] init];
		float delay = 0.2;
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        animation_.state = kAnimationState_Running;
        animation_.type = kAnimationType_PingPong;

		[SpriteSheetImage release];

        pixelLocation_.x = aLocation.x;
        pixelLocation_.y = aLocation.y;
        playerInitialXShotPostion_ = scaleFactor_ * (43 - 5)  / 2;
        playerInitialYShotPostion_ = scaleFactor_ * 16;
        rightScreenBoundary_ = 480 - (43 * scaleFactor_);
        collisionWidth_ = scaleFactor_ * 43 * .9f;
        collisionHeight_ = scaleFactor_ * 25 *.9f;
        collisionXOffset_ = ((scaleFactor_ * 43) - collisionWidth_) / 2;
        collisionYOffset_ = ((scaleFactor_ * 25) - collisionHeight_) / 2;
        active_ = TRUE;
    }
    return self;
}


- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {
    [animation_ updateWithDelta:aDelta];
}

- (void)render {
    [super render];
    [animation_ renderAtPoint:CGPointMake(pixelLocation_.x, pixelLocation_.y)];
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {
    if ((pixelLocation_.y + collisionYOffset_ >= otherEntity.pixelLocation_.y + otherEntity.collisionYOffset_ + otherEntity.collisionHeight_) ||
        (pixelLocation_.x + collisionXOffset_ >= otherEntity.pixelLocation_.x + otherEntity.collisionXOffset_ + otherEntity.collisionWidth_) ||
        (otherEntity.pixelLocation_.y + otherEntity.collisionYOffset_ >= pixelLocation_.y + collisionYOffset_ + collisionHeight_) ||
        (otherEntity.pixelLocation_.x + otherEntity.collisionXOffset_ >= pixelLocation_.x + collisionXOffset_ + collisionWidth_)) {
        return;
    } else {
        active_ = FALSE;
        otherEntity.active_ = FALSE;
        [scene_ playerKilled];
    }

//    if ([otherEntity isKindOfClass:[Alien class]] ||
//        [otherEntity isKindOfClass:[Shot class]]) {
//        active_ = FALSE;
//        otherEntity.active_ = FALSE;
//        [scene_ playerKilled];
//    }
}

- (void)dealloc {
    [super dealloc];
}

@end
