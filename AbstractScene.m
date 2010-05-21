//
//  AbstractScene.m
//

#import "AbstractScene.h"

@implementation AbstractScene

@synthesize state_;
@synthesize alpha_;
@synthesize name_;
@synthesize screenBounds_;

- (void)updateSceneWithDelta:(GLfloat)aDelta {}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)updateWithAccelerometer:(UIAcceleration*)aAcceleration {}
- (void)transitionToSceneWithKey:(NSString*)aKey {}
- (void)transitionIn {}
- (void)renderScene {}
- (void)saveGameState {}
- (void)initPause {}

@end
