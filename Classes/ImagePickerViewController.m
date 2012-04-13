//
//  ImagePickerController.m
//  vuforia-wall
//
//  Created by Edo on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImagePickerViewController.h"

@implementation ImagePickerViewController

@synthesize imagePickerShown;



#pragma mark - Constructors

- (id)init;
{
	self = [super init];
    if (self) {
		self.title = NSLocalizedString(@"Photo Library", @"Photo Library");
		self.tabBarItem.image = [UIImage imageNamed:@"tabFolder"];
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Photo Library", @"Photo Library");
		self.tabBarItem.image = [UIImage imageNamed:@"tabFolder"];
		
    }
    return self;
}

- (IBAction)showPhotoLibrary
{
	if (imagePickerShown) {
		return;
	}
	UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.delegate = self;
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:imagePickerController animated:YES];
	imagePickerShown = YES;
//	[imagePickerController release];
}

- (IBAction)hidePhotoLibrary;
{
	if (!imagePickerShown) {
		return;
	}
	[self dismissModalViewControllerAnimated:YES];
	imagePickerShown = NO;
}


#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad;
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationImagePickerFinished object:image];
	
	[self hidePhotoLibrary];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self hidePhotoLibrary];
}






@end
