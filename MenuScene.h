//  MenuScene.h

#import "AbstractScene.h"

@class ImageRenderManager;
@class SoundManager;
@class TextureManager;
@class GameController;
@class Image;
@class BitmapFont;
@class PackedSpriteSheet;

@interface MenuScene : AbstractScene {

	/////////////////// Singleton Managers
	ImageRenderManager *sharedImageRenderManager_;
	GameController *sharedGameController_;
	SoundManager *sharedSoundManager_;
	TextureManager *sharedTextureManager_;

	/////////////////// Sprite sheets and images
	//PackedSpriteSheet *pss;				// Master spritesheet that contains all menu images
	Image *background_;					// Background image for the menu
	Image *fadeImage_;					// Full screen black image used to fade in and out
    Image *alien1_;

	/////////////////// Button iVars
	CGRect startButtonBounds;
	CGRect resumeButtonBounds;
	CGRect scoreButtonBounds;
	CGRect instructionButtonBounds;
}

@end
