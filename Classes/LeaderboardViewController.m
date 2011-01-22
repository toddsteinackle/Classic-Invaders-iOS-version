//  HighScoreViewController.m

#import "LeaderboardViewController.h"
#import "GameController.h"
#import "SoundManager.h"
#import <GameKit/GameKit.h>

@interface LeaderboardViewController (Private)

- (void)show;

@end


@implementation LeaderboardViewController

@synthesize highScoreCell;

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
	// Remove observers that have been set up
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showLeaderBoard" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];

    [super dealloc];
}

#pragma mark -
#pragma mark Init view

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Set up a notification observers
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:@"showLeaderBoard" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

		// Game controller
		sharedGameController = [GameController sharedGameController];
        sharedSoundManager = [SoundManager sharedSoundManager];

		// Set up a date formatter so that we can display a nice looking date and time in the high score table
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {

    if ([GKLocalPlayer localPlayer].authenticated && sharedGameController.localPlayerScore_ != nil
        && sharedGameController.scoresRetrieved_ && sharedGameController.playerAliasesRetrieved_) {
        scoreTableView.hidden = FALSE;
        [background setText:@""];
        scoreLable.hidden = FALSE;
        rankLable.hidden = FALSE;
        [playerAlias setText:[GKLocalPlayer localPlayer].alias];
        [playerScore setText:sharedGameController.localPlayerScore_.formattedValue];
        [playerRank setText:[NSString stringWithFormat:@"%d", sharedGameController.localPlayerScore_.rank]];
        [playerDateOfScore setText:[dateFormatter stringFromDate:sharedGameController.localPlayerScore_.date]];
    } else {
        scoreLable.hidden = TRUE;
        rankLable.hidden = TRUE;
        [playerAlias setText:@""];
        [playerScore setText:@""];
        [playerRank setText:@""];
        [playerDateOfScore setText:@""];
        scoreTableView.hidden = TRUE;
        [background setText:@"  LEADERBOARD NOT AVAILABLE  "];
    }

	// Set the initial alpha of the view
	self.view.alpha = 0;
	scoreTableView.allowsSelection = NO;

    if (sharedGameController.interfaceOrientation_ == UIInterfaceOrientationLandscapeRight) {
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
		self.view.transform = CGAffineTransformIdentity;
		self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.view.center = CGPointMake(384, 512);
        } else {
            self.view.center = CGPointMake(160, 240);
        }
	}
	if (sharedGameController.interfaceOrientation_ == UIInterfaceOrientationLandscapeLeft) {
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
		self.view.transform = CGAffineTransformIdentity;
		self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.view.center = CGPointMake(384, 512);
        } else {
            self.view.center = CGPointMake(160, 240);
        }
	}
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void) orientationChanged:(NSNotification *)notification {

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIDeviceOrientationLandscapeLeft) {
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
		self.view.transform = CGAffineTransformIdentity;
		self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.view.center = CGPointMake(384, 512);
        } else {
            self.view.center = CGPointMake(160, 240);
        }
	}
	if (orientation == UIDeviceOrientationLandscapeRight) {
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
		self.view.transform = CGAffineTransformIdentity;
		self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.view.center = CGPointMake(384, 512);
        } else {
            self.view.center = CGPointMake(160, 240);
        }
	}
}

#pragma mark -
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // We only want one section, so we hard code 1.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows this table will contain.
    return [sharedGameController.leaderBoardScores_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"highScoreCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSBundle mainBundle] loadNibNamed:@"HighScoreCell-iPad" owner:self options:nil];
        } else {
            [[NSBundle mainBundle] loadNibNamed:@"HighScoreCell" owner:self options:nil];
        }
		cell = highScoreCell;
    }

	// Alternate the background colors of each row.  This helps the player see the different entries
	// more clearly
	if (indexPath.row % 2) {
		cell.contentView.backgroundColor = [UIColor colorWithRed:0.8 green:0.75 blue:0.6 alpha:0.1];
	} else {
		cell.contentView.backgroundColor = [UIColor colorWithRed:0.8 green:0.75 blue:0.6 alpha:0.2];
	}

    // Retrieve the score information from the game controller
    GKScore *score = [sharedGameController.leaderBoardScores_ objectAtIndex:indexPath.row];

    // Update the score label
    UILabel *label;
    label = (UILabel*)[cell viewWithTag:1];
    label.text = score.formattedValue;

    // Update the rank label
    label = (UILabel*)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%d", score.rank];

    // Update the date and time label
    label = (UILabel*)[cell viewWithTag:3];
    label.text = [dateFormatter stringFromDate:score.date];

    // Update the players name label
    label = (UILabel*)[cell viewWithTag:4];
    label.text = [sharedGameController.playerAlias_ valueForKey:score.playerID];

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// This is the pixel height of each row in the table view
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 100;
    } else {
        return 70;
    }
}

#pragma mark -
#pragma mark Rotation and hiding

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)hide:(id)sender {
    [sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideFinished)];
    self.view.alpha = 0.0f;
    [UIView commitAnimations];
}

-(void)hideFinished {
	// Remove this view from its superview i.e. EAGLView.  This allows the next view that is added
	// to be the topmost view and therefore react to orientation events
	[self.view removeFromSuperview];
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation LeaderboardViewController (Private)

- (void)show {

	[sharedGameController.eaglView_ addSubview:self.view];

	// Begin the core animation we are going to use
	[UIView beginAnimations:nil context:NULL];
	self.view.alpha = 1.0f;
	[UIView commitAnimations];
    [scoreTableView reloadData];
}

@end
