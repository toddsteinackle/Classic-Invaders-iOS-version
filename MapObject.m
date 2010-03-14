//
//  GeneralGrave.m
//  SLQTSOR
//
//  Created by Mike Daley on 25/11/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "MapObject.h"
#import "PackedSpriteSheet.h"
#import "Image.h"
#import "Animation.h"
#import "SpriteSheet.h"

@implementation MapObject


- (void)dealloc {
    [animation release];
    [super dealloc];
}


- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType {
    self = [super init];
    if (self != nil) {
		
		// Add 0.5 to the tile location so that the object is in the middle of the square
		// as defined in the tile map editor
		tileLocation.x = aTileLocaiton.x;
		tileLocation.y = aTileLocaiton.y;
        pixelLocation = tileMapPositionToPixelPosition(tileLocation);
        type = aType;
		subType = aSubType;
				
        PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"atlas.png" controlFile:@"coordinates" imageFilter:GL_LINEAR];


        // Use the objects subtype to work out which image or sprite sheet is needed from the packed sprite sheet
		switch (subType) {
			case kObjectSubType_Grave:
			{
				image = [[pss imageForKey:@"object_tombstone.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_tombstone.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				break;
			}
				
			case kObjectSubType_TopLamp:
			{
				image = [[pss imageForKey:@"object_torch_top.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch_top.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];

				break;
			}
				
			case kObjectSubType_LeftLamp:
			{
				image = [[pss imageForKey:@"object_torch_left.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch_left.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				
				break;
			}

			case kObjectSubType_BottomLamp:
			{
				image = [[pss imageForKey:@"object_torch.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				
				break;
			}

			case kObjectSubType_RightLamp:
			{
				image = [[pss imageForKey:@"object_torch_right.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch_right.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				
				break;
			}

			default:
				break;
		}
		
		// Using the images defined above, create any necessary animation
		switch (subType) {
			case kObjectSubType_Grave:
			{
				animation = [[Animation alloc] init];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.75];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.75];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.75];
				animation.state = kAnimationState_Running;
				animation.type = kAnimationType_Once;
				break;
			}
				
			case kObjectSubType_LeftLamp:
			case kObjectSubType_RightLamp:
			{
				animation = [[Animation alloc] init];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				animation.type = kAnimationType_PingPong;
				animation.state = kAnimationState_Running;
				break;

			}
				
			case kObjectSubType_TopLamp:
			case kObjectSubType_BottomLamp:
			{
				animation = [[Animation alloc] init];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				animation.type = kAnimationType_PingPong;
				animation.state = kAnimationState_Running;
				break;
			}

			default:
				break;
		}
    }
    return self;
}

- (void)updateWithDelta:(float)aDelta scene:(AbstractScene *)aScene {
	[animation updateWithDelta:aDelta];
}

- (void)render {
	// Depending on the type of object, we render then at different points
	switch (subType) {
		case kObjectSubType_Grave:
			[animation renderCenteredAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
			break;
		default:
			[animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
			break;
	}
}

- (CGRect)collisionBounds { 
    return CGRectMake(pixelLocation.x - 10, pixelLocation.y - 10, 20, 20);
}

@end
