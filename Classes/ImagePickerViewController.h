//
//  ImagePickerController.h
//  vuforia-wall
//
//  Created by Eduard Feicho <eduard_DOT_feicho_AT_rwth-aachen_DOT_de> on 13.04.12.
//  Source: https://github.com/Duffycola/Vuforia-Wall
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString* notificationImagePickerFinished = @"LibraryImagePickerFinishedNotification";
static const int kVWallImageSize = 1024;


@interface ImagePickerViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
	BOOL imagePickerShown;

}
@property (nonatomic, assign) BOOL imagePickerShown;


- (IBAction)showPhotoLibrary;
- (IBAction)hidePhotoLibrary;

@end
