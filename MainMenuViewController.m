//
//  MainMenuViewController.m
//  ClassicInvaders
//
//  Created by Todd Steinackle on 1/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SoundManager.h"
#import "GameController.h"
#import "AbstractScene.h"
#import "ClassicInvadersAppDelegate.h"

@interface MainMenuViewController (Private)

- (void)show;

@end

@implementation MainMenuViewController

@synthesize menuScene;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Set up the settings view
		sharedSoundManager = [SoundManager sharedSoundManager];
		sharedGameController = [GameController sharedGameController];

		// Set up a notification observers
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:@"showMainMenu" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showMainMenu" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	// Set the initial alpha of the view
	self.view.alpha = 0;

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
    appDelegate = (ClassicInvadersAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainMenuViewController_ = self;
}

- (void)setScoreButton {
    if (sharedGameController.localPlayerAuthenticated_) {
        [scoreButton setTitle:@"Leaderboard" forState:UIControlStateNormal];
    } else {
        [scoreButton setTitle:@"High Scores" forState:UIControlStateNormal];
    }
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
#pragma mark Rotating and hiding

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)hide:(id)sender {

	[sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];

	// Fade out the view using core animation.  We do not want to remove this view from EAGLView
	// until the fade has ended, so we use the animation delegate and AnimationDidStopSelector
	// to call the hideFinished method when the animation is done.  This then removes this
	// view from EAGLView
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideFinished)];
	self.view.alpha = 0.0f;
	[UIView commitAnimations];
}

- (void)hideFinished {
	// Remove this view from its superview i.e. EAGLView.  This allows the next view that is added
	// to be the topmost view and therefore react to orientation events
	[self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)newGame:(id)aSender {
    [sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
    menuScene.state_ = SceneState_TransitionOut;
    menuScene.alpha_ = 0;
    [self hide:self];
}
- (IBAction)highScores:(id)aSender {
    [sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
    if (sharedGameController.localPlayerAuthenticated_) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeaderBoard" object:self];
    } else {
        menuScene.state_ = SceneState_Scores;
        [self hide:self];
    }
    menuScene.alpha_ = 0;
}
- (IBAction)showHelp:(id)aSender {
    [sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
    menuScene.state_ = SceneState_Help;
    menuScene.alpha_ = 0;
    [self hide:self];
}
- (IBAction)showAbout:(id)aSender {
    [sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
    menuScene.state_ = SceneState_About;
    menuScene.alpha_ = 0;
    [self hide:self];
}
- (IBAction)showSettings:(id)aSender {
    [sharedSoundManager playSoundWithKey:@"guiTouch" gain:0.3f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO ];
    menuScene.alpha_ = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSettings" object:self];
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation MainMenuViewController (Private)

- (void)show {
	// Add this view as a subview of EAGLView
	[sharedGameController.eaglView_ addSubview:self.view];

	// ...then fade it in using core animation
	[UIView beginAnimations:nil context:NULL];
	self.view.alpha = 1.0f;
	[UIView commitAnimations];
}

@end
