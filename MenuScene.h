//  MenuScene.h

#import "AbstractScene.h"

@class ImageRenderManager;
@class SoundManager;
@class TextureManager;
@class GameController;
@class Image;
@class BitmapFont;
@class PackedSpriteSheet;
@class Animation;
@class SpriteSheet;
@class MainMenuViewController;

@interface MenuScene : AbstractScene {

	/////////////////// Singleton Managers
	ImageRenderManager *sharedImageRenderManager_;
	GameController *sharedGameController_;
	SoundManager *sharedSoundManager_;
	TextureManager *sharedTextureManager_;

	/////////////////// Sprite sheets and images
    SpriteSheet *spriteSheet_;

	Image *background_;					// Background image for the menu
	Image *fadeImage_;					// Full screen black image used to fade in and out

    Animation *alien1_;
    Animation *alien2_;
    Animation *alien3_;
    Animation *alien4_;
    Animation *alien5_;
    Animation *alien6_;

    Image *help1_;
    Image *help2_;
    Image *help3_;
    Image *help4_;
    Image *help5_;
    Image *help6_;
    Image *help7_;
    Image *help8_;
    Image *help9_;
    Image *help10_;

	/////////////////// Button iVars
	CGRect startButtonBounds_;
	CGRect scoreButtonBounds_;
	CGRect helpButtonBounds_;
    CGRect aboutButtonBounds_;
    CGRect settingButtonBounds_;

    BitmapFont *menuFont_;
    BitmapFont *monoMenuFont_;
    BitmapFont *monoScoreHighlightFont_;
    BitmapFont *monoHelpFont_;

    NSArray *highScores_;

    MainMenuViewController *mainMenuViewController_;
}

@end
