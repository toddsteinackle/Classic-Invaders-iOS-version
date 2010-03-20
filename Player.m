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

@implementation Player

@synthesize playerInitialXShotPostion_;
@synthesize playerInitialYShotPostion_;

#pragma mark -
#pragma mark Initialization

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
        //dx_ = 100;
        rightScreenBoundary_ = 480 - (43 * scaleFactor_);

    }
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

#pragma mark -
#pragma mark Collision

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity {
}

- (void)dealloc {
    [animation_ release];
    [super dealloc];
}

@end
