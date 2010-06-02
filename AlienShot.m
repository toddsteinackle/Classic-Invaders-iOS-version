//
//  AlienShot.m
//  ClassicInvaders
//
//  Created by Todd Steinackle on 5/22/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "PackedSpriteSheet.h"
#import "AlienShot.h"


@implementation AlienShot
- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super init];
	if (self != nil) {
        width_ = 4;
        height_ = 15;
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                       controlFile:@"pss_coordinates"
                                                                       imageFilter:GL_LINEAR];
		Image *SpriteSheetImage = [[pss imageForKey:@"alien_shots.png"] retain];
        float delay;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			scaleFactor_ = 1.5f;
            SpriteSheetImage.scale = Scale2fMake(2.5f, scaleFactor_);
            top_ = 725.0f - height_*scaleFactor_;
            delay = 0.1f;
		} else {
			scaleFactor_ = .85f;
            SpriteSheetImage.scale = Scale2fMake(1.5f, scaleFactor_);
            top_ = scene_.screenBounds_.size.height;
            delay = 0.15f;
		}

        spriteSheet_ = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                               sheetKey:@"alien_shots.png"
                                             spriteSize:CGSizeMake(width_, height_)
                                                spacing:1
                                                 margin:0];

        animation_ = [[Animation alloc] init];
		[animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        [animation_ addFrameWithImage:[spriteSheet_ spriteImageAtCoords:CGPointMake(1, 0)] delay:delay];
        animation_.state = kAnimationState_Running;
        animation_.type = kAnimationType_PingPong;

		[SpriteSheetImage release];

        pixelLocation_.x = aLocation.x;
        pixelLocation_.y = aLocation.y;
        collisionWidth_ = scaleFactor_ * width_;
        collisionHeight_ = scaleFactor_ * height_ *.7;
        collisionXOffset_ = ((scaleFactor_ * width_) - collisionWidth_) / 2;
        collisionYOffset_ = ((scaleFactor_ * height_) - collisionHeight_) / 2;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			dy_ = 250.0f;
		} else {
            dy_ = 140.0f;
		}
        state_ = EntityState_Idle;
    }
    return self;
}

@end
