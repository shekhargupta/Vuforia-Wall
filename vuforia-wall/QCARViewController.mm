//
//  QCARViewController.m
//  vuforia-wall
//
//  Created by Edo on 16.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QCARViewController.h"
#import "ARParentViewController.h"
#import "QCARutils.h"

@interface QCARViewController ()

@end

@implementation QCARViewController

static BOOL firstTime = YES;

- (id)init;
{
    self = [super init];
    if (self) {
        // Custom initialization
		
		self.title = NSLocalizedString(@"V-Wall", @"V-Wall");
		self.tabBarItem.image = [UIImage imageNamed:@"tabCamera"];
		
		
		QCARutils *qUtils = [QCARutils getInstance];
		
		// Provide a list of targets we're expecting - the first in the list is the default
		[qUtils addTargetName:@"Stones & Chips" atPath:@"StonesAndChips.xml"];
		[qUtils addTargetName:@"Tarmac" atPath:@"Tarmac.xml"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.	
	
	// Add the EAGLView and the overlay view to the window
	arParentViewController = [[ARParentViewController alloc] init];
	arParentViewController.arViewRect = self.view.bounds;
	[self.view addSubview:arParentViewController.view];
}

- (void)viewWillAppear:(BOOL)animated;
{
	if (firstTime) {
		[self setupSplashContinuation];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// test to see if the screen has hi-res mode
- (BOOL) isRetinaEnabled
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)]
            &&
            ([UIScreen mainScreen].scale == 2.0));
}

// Setup a continuation of the splash screen until the camera is initialised
- (void) setupSplashContinuation
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    // first get the splash screen continuation in place
    NSString *splashImageName = @"Default.png";
    if (screenBounds.size.width == 768)
        splashImageName = @"Default-Portrait~ipad.png";
    else if ((screenBounds.size.width == 320) && [self isRetinaEnabled])
        splashImageName = @"Default@2x.png";
    
    UIImage *image = [UIImage imageNamed:splashImageName];
    splashV = [[UIImageView alloc] initWithImage:image];
    splashV.frame = screenBounds;
	[self.view addSubview:splashV];
	
    // poll to see if the camera video stream has started and if so remove the splash screen.
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(removeSplash:) userInfo:nil repeats:YES];
}

- (void) removeSplash:(NSTimer *)theTimer
{
    // poll to see if the camera video stream has started and if so remove the splash screen.
    if ([QCARutils getInstance].videoStreamStarted == YES)
    {
        [splashV removeFromSuperview];
        [theTimer invalidate];
		firstTime = NO;
    }
}

@end
