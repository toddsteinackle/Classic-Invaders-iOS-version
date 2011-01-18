//  HighScoreViewController.h

#import <UIKit/UIKit.h>

@class GameController;
@class SoundManager;

@interface LeaderboardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	//////////////////// Singleton references
	GameController *sharedGameController;	// Reference to the shared game controller
    SoundManager *sharedSoundManager;

	//////////////////// Table view
	IBOutlet UITableView *scoreTableView;	// High score table view
	UITableViewCell *highScoreCell;			// TableViewCell used within the table view to display high score information
	NSDateFormatter *dateFormatter;			// Date formatter used to define the format of dates in the table view cells

    IBOutlet UILabel *background;
    IBOutlet UILabel *playerAlias;
    IBOutlet UILabel *playerScore;
    IBOutlet UILabel *playerRank;
    IBOutlet UILabel *playerDateOfScore;
    IBOutlet UILabel *rankLable;
    IBOutlet UILabel *scoreLable;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *highScoreCell;

- (IBAction)hide:(id)aSender;

@end
