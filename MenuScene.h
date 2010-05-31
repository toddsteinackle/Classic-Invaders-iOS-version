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
	Image *background_;					// Background image for the menu
	Image *fadeImage_;					// Full screen black image used to fade in and out
    Image *alien1_;
    Image *alien2_;
    Image *alien3_;
    Image *alien4_;
    Image *alien5_;

    Image *help1_;
    Image *help2_;
    Image *help3_;
    Image *help4_;
    Image *help5_;

	/////////////////// Button iVars
	CGRect startButtonBounds_;
	CGRect scoreButtonBounds_;
	CGRect helpButtonBounds_;
    CGRect aboutButtonBounds_;

    BitmapFont *menuFont_;
    BitmapFont *monoMenuFont_;
    BitmapFont *monoScoreHighlightFont_;
    BitmapFont *monoHelpFont_;

    NSArray *highScores_;
}

@end
