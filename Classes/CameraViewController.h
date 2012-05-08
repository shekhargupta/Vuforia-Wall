//
//  CameraViewController.h
//  vuforia-wall
//
//  Created by Edo on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* notificationCameraImagePickerFinished = @"CameraImagePickerFinishedNotification";
static const int kVWallTargetImageSize = 1024;


@interface CameraViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
	BOOL imagePickerShown;
}
@property (nonatomic, assign) BOOL imagePickerShown;


- (IBAction)showCamera;
- (IBAction)hideCamera;


@end
