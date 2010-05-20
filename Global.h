/*
 *  Global.h
 *  SLQTSOR
 *
 *  Created by Michael Daley on 19/04/2009.
 *  Copyright 2009 Michael Daley. All rights reserved.
 *
 */

#import <OpenGLES/ES1/gl.h>
#import "Structures.h"

#pragma mark -
#pragma mark Logging

#define MYDEBUG
#define SLQLOG(...) NSLog(__VA_ARGS__);
//#define SLQLOG(...)

//#define SCB 1

#pragma mark -
#pragma mark Macros

// Macro which returns a random value between -1 and 1
#define RANDOM_MINUS_1_TO_1() ((random() / (GLfloat)0x3fffffff )-1.0f)

// Macro which returns a random number between 0 and 1
#define RANDOM_0_TO_1() ((random() / (GLfloat)0x7fffffff ))

// Macro which converts degrees into radians
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

// Macro that allows you to clamp a value within the defined bounds
#define CLAMP(X, A, B) ((X < A) ? A : ((X > B) ? B : X))

#pragma mark -
#pragma mark Enumerators

// Scene States
enum {
	kSceneState_Idle,
	kSceneState_Credits,
	kSceneState_Loading,
	kSceneState_TransitionIn,
	kSceneState_TransitionOut,
	kSceneState_TransportingIn,
	kSceneState_TransportingOut,
	kSceneState_Running,
	kSceneState_Paused,
	kSceneState_GameOver,
	kSceneState_SaveScore,
	kSceneState_GameCompleted
};

// Entity states
enum entityState {
	EntityState_Idle,
	EntityState_Dead,
	EntityState_Dying,
	EntityState_Alive,
	EntityState_Appearing
};
// Scene States
enum {
    SceneState_WaveMessage,
    SceneState_WaveOver,
    SceneState_WaveCleanup,
    SceneState_WaveIntro,
    SceneState_PlayerDeath,
    SceneState_PlayerRebirth,
    SceneState_TransitionIn,
    SceneState_TransitionOut,
    SceneState_Running,
    SceneState_Paused,
    SceneState_GameOver,
    SceneState_Idle,
    SceneState_Scores,
    SceneState_Help,
    SceneState_Settings
};

// Object states
enum {
	kObjectState_Active,
	kObjectState_Inactive,
	kObjectState_Inventory
};

// Object types
enum  {
	kObjectType_Key,
	kObjectType_Energy,
	kObjectType_General
};

// Object subtypes
enum {
	kObjectSubType_RedKey = 0,
	kObjectSubType_GreenKey = 1,
	kObjectSubType_BlueKey = 2,
	kObjectSubType_YellowKey = 3,
	kObjectSubType_Candy = 4,
	kObjectSubType_Cake = 5,
	kObjectSubType_Chicken = 6,
	kObjectSubType_Drink = 7,
	kObjectSubType_LolliPop = 8,
	kObjectSubType_Ham = 9,
	kObjectSubType_Grave = 10,
	kObjectSubType_BottomLamp = 11,
	kObjectSubType_RightLamp = 12,
	kObjectSubType_TopLamp = 13,
	kObjectSubType_LeftLamp = 14,
	kObjectSubType_ParchmentTop = 15,
	kObjectSubType_ParchmentMiddle = 16,
	kObjectSubType_ParchmentBottom = 17,
	kObjectSubType_Exit = 18
};

enum {
    kDoorState_Open = 0,
    kDoorState_Closed = 1
};

enum {
	kDoorV_CaveGreen = 0,
	kDoorV_CavePlain = 1,
	kDoorV_WoodRed = 2,
	kDoorV_WoodGreen = 3,
	kDoorV_WoodPlain = 4,
	kDoorV_WoodBlue = 5,
	kDoorV_StoneRed = 6,
	kDoorV_CaveBlue = 7,
	kDoorV_StoneGreen = 8,
	kDoorV_StonePlain = 9,
	kDoorV_StoneBlue = 10,
	kDoorV_CaveRed = 11,
	kDoorH_CaveGreen = 12,
	KDoorH_CavePlain = 13,
	KDoorH_WoodRed = 14,
	kDoorH_WoodGreen = 15,
	kDoorH_WoodPlain = 16,
	kDoorH_WoodBlue = 17,
	kDoorH_StoneGreen = 18,
	kDoorH_StonePlain = 19,
	kDoorH_StoneBlue = 20,
	kDoorH_CaveRed = 21,
	kDoorH_CaveBlue = 22,
	kDoorH_WoodStone = 23,
	kDoorV_WoodStone = 24,
	kDoorH_StoneWood = 25,
	kDoorV_StoneWood = 26,
	kDoorH_StoneRed = 27
};

#pragma mark -
#pragma mark Constants

// Name of the scenes
#define kGame_Scene_Name @"game"
#define kMenu_Scene_Name @"menu"

// Tile map details
#define kTile_Width 40
#define kTile_Height 40
#define kMax_Map_Width 200
#define kMax_Map_Height 200

// Spawning
#define kMax_Player_Distance 6

#pragma mark -
#pragma mark Inline Functions

// Converts a tile position into a pixel position
static inline CGPoint tileMapPositionToPixelPosition(CGPoint tmp) {
	return CGPointMake((int)(tmp.x * kTile_Width), (int)(tmp.y * kTile_Height));
}

// Returns YES is the point provided is inside the closed poly defined by
// the vertices provided
static inline BOOL isPointInPoly(int sides, float *px, float *py, CGPoint point) {
	int sideCount;
	int totalSides = sides - 1;
	BOOL inside = NO;

	for (sideCount = 0; sideCount < sides; sideCount++) {
		if ((py[sideCount] < point.y && py[totalSides] >= point.y) ||
			(py[totalSides] < point.y && py[sideCount] >= point.y)) {
			if (px[sideCount] + (point.y - py[sideCount]) / (py[totalSides] - py[sideCount]) * (px[totalSides] - px[sideCount]) < point.x) {
				inside = !inside;
			}
		}
	}
	return inside;
}

// Returns YES if the rectangle and circle interset each other.  This include the circle being fulling inside
// the rectangle.
static inline BOOL RectIntersectsCircle(CGRect aRect, Circle aCircle) {

	float testX = aCircle.x;
	float testY = aCircle.y;

	if (testX < aRect.origin.x)
		testX = aRect.origin.x;
	if (testX > (aRect.origin.x + aRect.size.width))
		testX = (aRect.origin.x + aRect.size.width);
	if (testY < aRect.origin.y)
		testY = aRect.origin.y;
	if (testY > (aRect.origin.y + aRect.size.height))
		testY = (aRect.origin.y + aRect.size.height);

	return ((aCircle.x - testX) * (aCircle.x - testX) + (aCircle.y - testY) * (aCircle.y - testY)) < aCircle.radius * aCircle.radius;
}

// Returns YES if the two circles provided intersect each other
static inline BOOL CircleIntersectsCircle(Circle aCircle1, Circle aCircle2) {
	float dx = aCircle2.x - aCircle1.x;
	float dy = aCircle2.y - aCircle1.y;
	float radii = aCircle1.radius + aCircle2.radius;

	return ((dx * dx) + (dy * dy)) < radii * radii;
}

// Return a Color4f structure populated with 1.0's
static const Color4f Color4fOnes = {1.0f, 1.0f, 1.0f, 1.0f};

// Return a zero populated Vector2f
static const Vector2f Vector2fZero = {0.0f, 0.0f};

// Return a Scale2f structure populated with the provided floats
static inline Scale2f Scale2fMake(float x, float y) {
    return (Scale2f) {x, y};
}

// Return a populated Vector2d structure from the floats passed in
static inline Vector2f Vector2fMake(GLfloat x, GLfloat y) {
	return (Vector2f) {x, y};
}

static inline CGPoint vm(GLfloat x, GLfloat y) {
	return (CGPoint) {x, y};
}

// Return a Color4f structure populated with the color values passed in
static inline Color4f Color4fMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
	return (Color4f) {red, green, blue, alpha};
}

// Return a Vector2f containing v multiplied by s
static inline Vector2f Vector2fMultiply(Vector2f v, GLfloat s) {
	return (Vector2f) {v.x * s, v.y * s};
}

// Return a Vector2f containing v1 + v2
static inline Vector2f Vector2fAdd(Vector2f v1, Vector2f v2) {
	return (Vector2f) {v1.x + v2.x, v1.y + v2.y};
}

// Return a Vector2f containing v1 - v2
static inline Vector2f Vector2fSub(Vector2f v1, Vector2f v2) {
	return (Vector2f) {v1.x - v2.x, v1.y - v2.y};
}

// Return the dot product of v1 and v2
static inline GLfloat Vector2fDot(Vector2f v1, Vector2f v2) {
	return (GLfloat) v1.x * v2.x + v1.y * v2.y;
}

// Return the length of the vector v
static inline GLfloat Vector2fLength(Vector2f v) {
	return (GLfloat) sqrtf(Vector2fDot(v, v));
}

// Return a Vector2f containing a normalized vector v
static inline Vector2f Vector2fNormalize(Vector2f v) {
	return Vector2fMultiply(v, 1.0f/Vector2fLength(v));
}
