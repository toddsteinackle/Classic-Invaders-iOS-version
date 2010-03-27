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

- (void)movementWithDelta:(float)aDelta {
    pixelLocation_.y += aDelta * dy_;
    if (pixelLocation_.y > scene_.screenBounds_.size.height) {
        active_ = FALSE;
    }
    if (pixelLocation_.y < scene_.playerBaseHeight_) {
        active_ = FALSE;
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
        active_ = FALSE;
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

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity {
}

- (void)dealloc {
    [super dealloc];
}

@end
