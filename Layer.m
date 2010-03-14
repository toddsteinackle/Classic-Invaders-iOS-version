//
//  Layer.m
//  SLQTSOR
//
//  Created by Michael Daley on 05/04/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "Layer.h"

@implementation Layer

@synthesize layerID;
@synthesize layerName;
@synthesize layerWidth;
@synthesize layerHeight;
@synthesize layerProperties;

- (void)dealloc {
	NSLog(@"INFO - Layer: Deallocating");
	free(tileImages);
	[super dealloc];
}

- (id)initWithName:(NSString*)aName layerID:(int)aLayerID layerWidth:(int)aLayerWidth layerHeight:(int)aLayerHeight {
	if(self != nil) {
		layerName = aName;
		layerID = aLayerID;
		layerWidth = aLayerWidth;
		layerHeight = aLayerHeight;
		
		// Make sure that the layer being created is not beyond the maximum bounds defined in the header
        if (layerWidth > kMax_Map_Width || layerHeight > kMax_Map_Height) {
            NSLog(@"ERROR - Layer: Trying to create a layer with dimensions greater than the maximum defined in Layer.h");
            return nil;
        }
		
		// Allocate space for the layers tile images
		tileImages = calloc(layerWidth * layerHeight, sizeof(TexturedColoredQuad));
	}
	return self;
}

- (TexturedColoredQuad*)tileImageAt:(CGPoint)aPoint {

	// Wotk out the index of the image based on its location
	int index = (int)(layerWidth * aPoint.y) + (int)aPoint.x;
	
	// Return the address of the image for the index above
	return &tileImages[index];
}
			
- (int)tileIDAtTile:(CGPoint)aTileCoord {
	return layerData[(int)aTileCoord.x][(int)aTileCoord.y][1];
}


- (int)globalTileIDAtTile:(CGPoint)aTileCoord {
	return layerData[(int)aTileCoord.x][(int)aTileCoord.y][2];
}


- (int)tileSetIDAtTile:(CGPoint)aTileCoord {
	return layerData[(int)aTileCoord.x][(int)aTileCoord.y][0];
}


- (void)addTileAt:(CGPoint)aTileCoord tileSetID:(int)aTileSetID tileID:(int)aTileID globalID:(int)aGlobalID value:(int)aValue {
	layerData[(int)aTileCoord.x][(int)aTileCoord.y][0] = aTileSetID;
	layerData[(int)aTileCoord.x][(int)aTileCoord.y][1] = aTileID;
	layerData[(int)aTileCoord.x][(int)aTileCoord.y][2] = aGlobalID;
	layerData[(int)aTileCoord.x][(int)aTileCoord.y][3] = aValue;
}

- (void)addTileImageAt:(CGPoint)aPoint imageDetails:(ImageDetails*)aImageDetails {

	// Work out the index of the image based on its locaiton
	int index = (int)(layerWidth * aPoint.y) + (int)aPoint.x;
	
	// Copy the TexturedColoredQuad information from aImageDetails into the tileImages array at
	// the index calculated above
	memcpy(&tileImages[index], aImageDetails->texturedColoredQuad, sizeof(TexturedColoredQuad));
	
	// Adjust the images location in TexturedColoredQuad so that it will render at the correct 
	// location based on where it is within the tile map.
	tileImages[index].vertex1.geometryVertex.x += (aPoint.x * kTile_Width);
	tileImages[index].vertex1.geometryVertex.y += (aPoint.y * kTile_Height);
	tileImages[index].vertex2.geometryVertex.x += (aPoint.x * kTile_Width);
	tileImages[index].vertex2.geometryVertex.y += (aPoint.y * kTile_Height);
	tileImages[index].vertex3.geometryVertex.x += (aPoint.x * kTile_Width);
	tileImages[index].vertex3.geometryVertex.y += (aPoint.y * kTile_Height);
	tileImages[index].vertex4.geometryVertex.x += (aPoint.x * kTile_Width);
	tileImages[index].vertex4.geometryVertex.y += (aPoint.y * kTile_Height);
	
}

- (void)setValueAtTile:(CGPoint)aTileCoord value:(int)aValue {
	layerData[(int)aTileCoord.x][(int)aTileCoord.y][3] = aValue;
}

- (int)valueAtTile:(CGPoint)aTileCoord {
	return layerData[(int)aTileCoord.x][(int)aTileCoord.y][3];
}

@end
