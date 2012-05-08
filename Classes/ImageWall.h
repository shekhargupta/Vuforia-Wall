//
//  ImageWall.h
//  vuforia-wall
//
//  Created by Eduard Feicho <eduard_DOT_feicho_AT_rwth-aachen_DOT_de> on 13.04.12.
//  Source: https://github.com/Duffycola/Vuforia-Wall
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImagePickerViewController.h"
#import "TouchImageView.h"

static NSString* notificationImageWallAddImage = @"ImageWallAddImageNotification";
static NSString* notificationImageWallRemoveImage = @"ImageWallRemoveImageNotification";
static NSString* notificationImageWallSetTargetImage = @"ImageWallSetTargetImageNotification";


@interface ImageWall : NSObject
{
	NSMutableArray* images;
	UIImage* targetImage;
	int selectedImage;
	CGRect frame;
}
@property (nonatomic, retain) NSMutableArray* images;
@property (nonatomic, retain) UIImage* targetImage;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) int selectedImage;

+ (ImageWall*)sharedInstance;

@end
