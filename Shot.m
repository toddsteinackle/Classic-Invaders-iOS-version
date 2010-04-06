//
//  Shot.m
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/17/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "PackedSpriteSheet.h"
#import "Shot.h"

@implementation Shot

@synthesize hit_;

- (void)movementWithDelta:(float)aDelta {
    pixelLocation_.y += aDelta * dy_;
    if (pixelLocation_.y > scene_.screenBounds_.size.height) {
        state_ = EntityState_Idle;
    }
    if (pixelLocation_.y < scene_.playerBaseHeight_) {
        state_ = EntityState_Idle;
    }
}

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super init];
	if (self != nil) {
        width_ = 5;
        height_ = 16;
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                       controlFile:@"pss_coordinates"
                                                                       imageFilter:GL_LINEAR];
		Image *SpriteSheetImage = [[pss imageForKey:@"shot.png"] retain];
        scaleFactor_ = .85;
        SpriteSheetImage.scale = Scale2fMake(scaleFactor_, scaleFactor_);
        spriteSheet_ = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                               sheetKey:@"shot.png"
                                             spriteSize:CGSizeMake(width_, height_)
                                                spacing:1
                                                 margin:0];

        animation_ = [[Animation alloc] init];
		float delay = 0.2;
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        animation_.state = kAnimationState_Running;
        animation_.type = kAnimationType_PingPong;

		[SpriteSheetImage release];

        pixelLocation_.x = aLocation.x;
        pixelLocation_.y = aLocation.y;
        collisionWidth_ = scaleFactor_ * width_;
        collisionHeight_ = scaleFactor_ * height_ *.7;
        collisionXOffset_ = ((scaleFactor_ * width_) - collisionWidth_) / 2;
        collisionYOffset_ = ((scaleFactor_ * height_) - collisionHeight_) / 2;
        dy_ = 140.0f;
        state_ = EntityState_Idle;
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
    }

    if ([otherEntity isKindOfClass:[Shot class]]) {
        [sharedSoundManager_ playSoundWithKey:@"shot_collision" gain:0.2f];
        state_ = EntityState_Idle;
        otherEntity.state_ = EntityState_Idle;
    } else {
        if (hit_) return;
        state_ = EntityState_Idle;
        otherEntity.state_ = EntityState_Idle;
        hit_ = TRUE;
    }
}

- (void)dealloc {
    [super dealloc];
}

@end
