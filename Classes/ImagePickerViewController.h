//
//  ImagePickerController.h
//  vuforia-wall
//
//  Created by Edo on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString* notificationImagePickerFinished = @"ImagePickerFinishedNotification";

@interface ImagePickerViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
	BOOL imagePickerShown;

}
@property (nonatomic, assign) BOOL imagePickerShown;


- (IBAction)showPhotoLibrary;
- (IBAction)hidePhotoLibrary;

@end
