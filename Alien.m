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
        scaleFactor_ = .7;
        SpriteSheetImage.scale = Scale2fMake(scaleFactor_, scaleFactor_);
        spriteSheet_ = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                               sheetKey:@"aliens.png"
                                             spriteSize:CGSizeMake(width_, height_)
                                                spacing:1
                                                 margin:0];

        animation_ = [[Animation alloc] init];
		float delay = 0.2;
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 1)] delay:delay];
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 2)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 3)] delay:delay];
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
        collisionWidth_ = scaleFactor_ * width_ * .8f;
        collisionHeight_ = scaleFactor_ * height_ *.8f;
        collisionXOffset_ = ((scaleFactor_ * width_) - collisionWidth_) / 2;
        collisionYOffset_ = ((scaleFactor_ * height_) - collisionHeight_) / 2;
        active_ = TRUE;
        points_ = 25;
        alienInitialXShotPostion_ = scaleFactor_ * (width_ - 5)  / 2;
        alienInitialYShotPostion_ = scaleFactor_ * 13;
    }
    //NSLog(@"Alien init");
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {

    //scene = (GameScene*)aScene;
    [animation_ updateWithDelta:aDelta];
    //NSLog(@"Alien delta update");
}

- (void)render {
    [super render];
    [animation_ renderAtPoint:CGPointMake(pixelLocation_.x, pixelLocation_.y)];
    //NSLog(@"Alien render");
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {
    if ((pixelLocation_.y + collisionYOffset_ >= otherEntity.pixelLocation_.y + otherEntity.collisionYOffset_ + otherEntity.collisionHeight_) ||
        (pixelLocation_.x + collisionXOffset_ >= otherEntity.pixelLocation_.x + otherEntity.collisionXOffset_ + otherEntity.collisionWidth_) ||
        (otherEntity.pixelLocation_.y + otherEntity.collisionYOffset_ >= pixelLocation_.y + collisionYOffset_ + collisionHeight_) ||
        (otherEntity.pixelLocation_.x + otherEntity.collisionXOffset_ >= pixelLocation_.x + collisionXOffset_ + collisionWidth_)) {
        return;
    }

    if ([otherEntity isKindOfClass:[Shot class]]) {
        active_ = FALSE;
        otherEntity.active_ = FALSE;
        [scene_ alienKilledWithPosition:position_ points:points_];
    }
}

- (void)dealloc {
    [super dealloc];
}

@end
