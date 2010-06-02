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
@class BigBonusShip;
@class SmallBonusShip;

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
    BitmapFont *iPadWaveMessageFont_;

    NSMutableArray *aliens_;
    NSMutableArray *playerShots_;
    NSMutableArray *alienShots_;
    NSMutableArray *bonusDirection_;
    NSMutableArray *bonusSelection_;
    NSMutableArray *additionalBonusDelay_;
    NSMutableArray *shields_;
    int bonusLaunchDelay_;
    Player *player_;
    Shot *shot_;
    BigBonusShip *bigBonus_;
    SmallBonusShip *smallBonus_;
    BigBonusShip *bonus_;
    Image *background_;
    CGRect leftTouchControlBounds_;
    CGRect rightTouchControlBounds_;
    CGRect fireTouchControlBounds_;
    CGRect pauseTouchControlBounds_;
    CGRect topStatus_;
    NSUInteger numberOfPlayerShots_;
    NSUInteger numberOfAlienShots_;
    NSUInteger randomListLength_;
    CGFloat screenSidePadding_;
    CGFloat playerBaseHeight_;
    CGFloat bonusSpeed_;
    CGFloat bonusShipTop_;
    bool isAlienLogicNeeded_;
    bool canPlayerFire_;
    bool nameToBeEntered_;
    int score_;
    int alienCount_;
    CGFloat playerSpeed_;
    double waveMessageInterval_;
    double lastTimeInLoop_;
    double baseLaunchDelay_;
    double lastBonusLaunch_;
    double lastAlienShot_;
    double timeOfInitialPause_;
    double totalTimePaused_;
    int wave_;
    int alienOddRange_;
    int playerLives_;
    double alienShotDelay_;
    int alienSpeed_;
    int nextFreeGuy_;
    int freeGuyValue_;
    Image *shipImage_;
}

@property (nonatomic, assign) CGFloat screenSidePadding_;
@property (nonatomic, assign) CGFloat playerBaseHeight_;
@property (nonatomic, assign) bool isAlienLogicNeeded_;

- (void)aliensHaveLanded;
- (void)playerKilled;
- (void)alienKilledWithPosition:(int)position points:(int)points playerFlag:(bool)killedByPlayer;
- (void)bonusShipDestroyedWithPoints:(int)points;

@end
