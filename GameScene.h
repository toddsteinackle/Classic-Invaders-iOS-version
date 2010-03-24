//  GameScene.h

#import "AbstractScene.h"

@class ImageRenderManager;
@class TextureManager;
@class SoundManager;
@class GameController;
@class AbstractEntity;
@class Image;
@class SpriteSheet;
@class Animation;
@class BitmapFont;
@class ParticleEmitter;
@class Primatives;
@class Alien;
@class Alien2;
@class Alien3;
@class Player;
@class Shot;

// This class is the core game scene.  It is responsible for game rendering, logic, user
// input etc.

@interface GameScene : AbstractScene {

	//////////////////////// Singleton Classes
    ImageRenderManager *sharedImageRenderManager_;	// Reference to the ImageRenderManager needed to render images
    TextureManager *sharedTextureManager_;			// Reference to the TextureManager that allows for reuse of textures
    SoundManager *sharedSoundManager_;				// Reference to the SoundManager that handles all sounds in the game
	GameController *sharedGameController_;			// Reference to the GameController which handles global game state

	//////////////////////// Fonts
	BitmapFont *smallFont_;
    BitmapFont *statusFont_;

    NSMutableArray *aliens_;
    NSMutableArray *playerShots_;
    NSMutableArray *alienShots_;
    Player *player_;
    Shot *shot_;
    Image *background_;
    CGRect leftTouchControlBounds_;
    CGRect rightTouchControlBounds_;
    CGRect fireTouchControlBounds_;
    NSUInteger numberOfPlayerShots_;
    NSUInteger numberOfAlienShots_;
    CGFloat screenSidePadding_;
    CGFloat playerBaseHeight_;
    bool isAlienLogicNeeded_;
    int score_;
    int alienCount_;
    CGFloat playerSpeed_;
    bool isLeftTouchActive_;
    bool isRightTouchActive_;
    double waveMessageInterval_;
    double lastTimeInLoop_;
    int wave_;
    int alienOddRange_;
    int playerLives_;
}

@property (nonatomic, assign) CGFloat screenSidePadding_;
@property (nonatomic, assign) CGFloat playerBaseHeight_;
@property (nonatomic, assign) bool isAlienLogicNeeded_;

- (void)saveGameState;
- (void)aliensHaveLanded;
- (void)playerKilledWithAlienFlag:(bool)killedByAlien;
- (void)alienKilledWithPosition:(int)position points:(int)points;

@end
