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
    Image *alien2_;
    Image *alien3_;
    Image *alien4_;
    Image *alien5_;

	/////////////////// Button iVars
	CGRect startButtonBounds_;
	CGRect resumeButtonBounds_;
	CGRect scoreButtonBounds_;
	CGRect instructionButtonBounds_;
    CGRect settingsButtonBounds_;

    BitmapFont *menuFont_;
    BitmapFont *monoMenuFont_;
    NSArray *highScores_;
}

@end
