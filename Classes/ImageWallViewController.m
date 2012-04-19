//
//  ImageWallViewController.m
//  vuforia-wall
//
//  Created by Edo on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageWallViewController.h"

@interface ImageWallViewController ()

@end

@implementation ImageWallViewController

#pragma mark - Constructors

- (id)init;
{
	return [self initWithNibName:@"ImageWallViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		
		self.title = NSLocalizedString(@"V-Wall", @"V-Wall");
		self.tabBarItem.image = [UIImage imageNamed:@"tabPortrait"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionImageWallAddImage:) name:notificationImageWallAddImage object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionImageWallRemoveImage:) name:notificationImageWallRemoveImage object:nil];
    }
    return self;
}

#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload;
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Event Actions

- (void)actionImageWallAddImage:(NSNotification*)notification;
{
	if (!notification.object) {
		return;
	}
	
	TouchImageView* imageView = notification.object;
	[self.view addSubview:imageView];
	imageView.currentImageTransform = imageView.transform;
}


- (void)actionImageWallRemoveImage:(NSNotification*)notification;
{
	if (!notification.object) {
		return;
	}
	
	TouchImageView* imageView = notification.object;
	[imageView removeFromSuperview];
}


@end
