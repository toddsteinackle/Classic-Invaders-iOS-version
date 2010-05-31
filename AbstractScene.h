//  AbstractScene.h

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class TextureManager;
@class SoundManager;

@interface AbstractScene : NSObject {

	CGRect screenBounds_;
	uint state_;
	GLfloat alpha_;
	NSString *nextSceneKey_;
    float fadeSpeed_;
	NSString *name_;

}

#pragma mark -
#pragma mark Properties

@property (nonatomic, assign) uint state_;
@property (nonatomic, assign) GLfloat alpha_;
@property (nonatomic, retain) NSString *name_;
@property (nonatomic, assign) CGRect screenBounds_;

#pragma mark -
#pragma mark Selectors

// Selector to update the scenes logic using |aDelta| which is passe in from the game loop
- (void)updateSceneWithDelta:(float)aDelta;

// Selectors that enable touche events to be passed into a scene.
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;

// Selector which enables accelerometer data to be passed into the scene.
- (void)updateWithAccelerometer:(UIAcceleration*)aAcceleration;

// Selector that transitions from this scene to the scene with the key specified.  This allows the current
// scene to perform a transition action before the current scene within the game controller is changed.
- (void)transitionToSceneWithKey:(NSString*)aKey;

// Selector that sets off a transition into the scene
- (void)transitionIn;

// Selector which renders the scene
- (void)renderScene;

- (void)initPause;

@end
