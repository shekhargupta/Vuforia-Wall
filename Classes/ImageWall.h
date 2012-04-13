//
//  ImageWall.h
//  vuforia-wall
//
//  Created by Edo on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImagePickerViewController.h"
#import "TouchImageView.h"

static NSString* notificationImageWallAddImage = @"ImageWallAddImageNotification";
static NSString* notificationImageWallRemoveImage = @"ImageWallRemoveImageNotification";


@interface ImageWall : NSObject
{
	NSMutableArray* images;
	int selectedImage;
	CGRect frame;
}
@property (nonatomic, retain) NSMutableArray* images;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) int selectedImage;

+ (ImageWall*)sharedInstance;


@end
