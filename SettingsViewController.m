//
//  SettingsViewController.m
//  ClassicInvaders
//
//  Created by Todd Steinackle on 7/5/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import "SettingsViewController.h"
#import "SoundManager.h"
#import "GameController.h"
#import "AbstractScene.h"

@interface SettingsViewController (Private)

// Moves the high score view into view when a showHighScore notification is received.
- (void)show;

// Update the controls on the view with the current values
- (void)updateControlValues;

@end

@implementation SettingsViewController

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
	// Remove observers that have been set up
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showSettings" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateSettingsSliders" object:nil];

    [super dealloc];
}

#pragma mark -
#pragma mark Init view

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Set up the settings view
		sharedSoundManager = [SoundManager sharedSoundManager];
		sharedGameController = [GameController sharedGameController];

		// Set up a notification observers
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:@"showSettings" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateControlValues) name:@"updateSettingsSliders" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	// Set the initial alpha of the view
	self.view.alpha = 0;

	// Make sure the controls on the view are updated with the current values
	[self updateControlValues];

	// If the orientation is in landscape then transform the view
	if (sharedGameController.interfaceOrientation_ == UIInterfaceOrientationLandscapeRight){
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
		self.view.transform = CGAffineTransformIdentity;
		self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.view.center = CGPointMake(384, 512);
        } else {
            self.view.center = CGPointMake(160, 240);
        }
	}
	if (sharedGameController.interfaceOrientation_ == UIInterfaceOrientationLandscapeLeft){
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

#pragma mark -
#pragma mark UI Actions

- (IBAction)backgroundValueChanged:(UISlider*)sender {
	sharedSoundManager.bgVolume = [sender value];
}

- (IBAction)fxValueChanged:(UISlider*)sender {
	sharedSoundManager.fxVolume = [sender value];
}

- (IBAction)buttonPositionsChanged:(UISegmentedControl*)sender {
	sharedGameController.buttonPositions_ = sender.selectedSegmentIndex;
}

- (IBAction)grahicsChoiceChanged:(UISegmentedControl*)sender {
    sharedGameController.graphicsChoice_ = sender.selectedSegmentIndex;
}


#pragma mark -
#pragma mark Rotating and hiding

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)hide:(id)sender {

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

@end

#pragma mark -
#pragma mark Private implementation

@implementation SettingsViewController (Private)

- (void)show {

	// Add this view as a subview of EAGLView
	[sharedGameController.eaglView_ addSubview:self.view];

	// ...then fade it in using core animation
	[UIView beginAnimations:nil context:NULL];
	self.view.alpha = 1.0f;
	[UIView commitAnimations];
}

- (void)updateControlValues {

	// Set the views control values based on the game controllers values
	bgVolume.value = sharedSoundManager.bgVolume;
	fxVolume.value = sharedSoundManager.fxVolume;
	buttonPositions.selectedSegmentIndex = sharedGameController.buttonPositions_;
    graphicsChoice.selectedSegmentIndex = sharedGameController.graphicsChoice_;
}

@end
