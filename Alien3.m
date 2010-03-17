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

@implementation Alien3

#pragma mark -
#pragma mark Initialization

- (id)initWithLocation:(CGPoint)aLocation dx:(float)hspeed dy:(float)vspeed position:(int)pos fire_chance:(int)chance {

    self = [super init];
	if (self != nil) {
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png" controlFile:@"pss_coordinates" imageFilter:GL_LINEAR];
		Image *SpriteSheetImage = [[pss imageForKey:@"aliens.png"] retain];
        scale_factor = .85;
        SpriteSheetImage.scale = Scale2fMake(scale_factor, scale_factor);
        spriteSheet = [SpriteSheet spriteSheetForImage:SpriteSheetImage sheetKey:@"aliens.png" spriteSize:CGSizeMake(45, 30) spacing:1 margin:0];

        animation = [[Animation alloc] init];
		float delay = 0.2;
		[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 8)] delay:delay];
        [animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 9)] delay:delay];
		[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 10)] delay:delay];
        [animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 8)] delay:delay];
        animation.state = kAnimationState_Running;
        animation.type = kAnimationType_PingPong;

		[SpriteSheetImage release];

        pixelLocation.x = aLocation.x;
        pixelLocation.y = aLocation.y;
        dx = hspeed;
        dy = vspeed;
        position = pos;
        fire_chance = chance;
    }
    return self;
}


#pragma mark -
#pragma mark Updating

- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {
    [animation updateWithDelta:aDelta];
}

#pragma mark -
#pragma mark Rendering

- (void)render {
    [super render];
    [animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
}

#pragma mark -
#pragma mark Collision

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity {
}

- (void)dealloc {
    [animation release];
    [super dealloc];
}

@end
