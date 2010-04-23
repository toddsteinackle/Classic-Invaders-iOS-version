//  Score.h

// This class is used to store a single score for the game.  A class instance
// is created when a game is completed and is then stored in the high scores
// array.  This array is then stored to disk and also used from within the
// high score view controller.

@interface Score : NSObject <NSCoding> {

	int score_;
	NSString *name_;
    int wave_;

}

@property (nonatomic, assign) int score_;
@property (nonatomic, assign) int wave_;
@property (nonatomic, retain) NSString *name_;

// Designated initializer that creates a new score instance that contains the players name
// their score and the date and time they achieved that score
- (id) initWithScore:(int)score name:(NSString*)name wave:(int)wave;

@end
